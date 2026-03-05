from fastapi import APIRouter, Depends, HTTPException
from auth import get_current_user
from config import supabase_admin
from models.health import BiometricReading, SelfReportCreate, HealthConnectSync, SleepSession


router = APIRouter(prefix="/health", tags=["Health Data"])


@router.post("/biometrics")
async def save_biometric_reading(
    reading: BiometricReading,
    user_id: str = Depends(get_current_user)
):
    """Save a biometric reading from PPG, wearable, or Health Connect."""
    try:
        data = {
            "user_id": user_id,
            "source": reading.source,
        }

        # Only include non-null fields
        if reading.heart_rate_bpm is not None:
            data["heart_rate_bpm"] = reading.heart_rate_bpm
        if reading.hrv_ms is not None:
            data["hrv_ms"] = reading.hrv_ms
        if reading.spo2 is not None:
            data["spo2"] = reading.spo2
        if reading.steps is not None:
            data["steps"] = reading.steps
        if reading.calories_burned is not None:
            data["calories_burned"] = reading.calories_burned
        if reading.sleep_hours is not None:
            data["sleep_hours"] = reading.sleep_hours
        if reading.sleep_quality is not None:
            data["sleep_quality"] = reading.sleep_quality

        response = supabase_admin.table("biometric_readings").insert(data).execute()
        return {"message": "Biometric reading saved", "data": response.data[0]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/biometrics/latest")
async def get_latest_biometrics(user_id: str = Depends(get_current_user)):
    """Get the most recent biometric reading for the user."""
    try:
        response = supabase_admin.table("biometric_readings") \
            .select("*") \
            .eq("user_id", user_id) \
            .order("recorded_at", desc=True) \
            .limit(1) \
            .execute()

        if not response.data:
            return {"data": None, "message": "No biometric readings found"}

        return {"data": response.data[0]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/self-report")
async def save_self_report(
    report: SelfReportCreate,
    user_id: str = Depends(get_current_user)
):
    """Save a daily self-report check-in."""
    try:
        response = supabase_admin.table("self_reports").insert({
            "user_id": user_id,
            "energy_level": report.energy_level,
            "mood": report.mood,
            "sleep_rating": report.sleep_rating,
            "stress_level": report.stress_level,
            "notes": report.notes,
        }).execute()

        return {"message": "Self report saved", "data": response.data[0]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/self-report/latest")
async def get_latest_self_report(user_id: str = Depends(get_current_user)):
    """Get the most recent self-report."""
    try:
        response = supabase_admin.table("self_reports") \
            .select("*") \
            .eq("user_id", user_id) \
            .order("reported_at", desc=True) \
            .limit(1) \
            .execute()

        if not response.data:
            return {"data": None, "message": "No self reports found"}

        return {"data": response.data[0]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@router.post("/sync")
async def sync_health_connect(
    data: HealthConnectSync,
    user_id: str = Depends(get_current_user)
):
    """
    Receives a batch of health data from Health Connect via Flutter.
    Called once in the morning (last night's sleep + yesterday's activity)
    and optionally during the day for updated step counts.
    """
    try:
        records_saved = []

        # 1. Save activity data (steps, calories, distance)
        if data.steps is not None or data.calories_burned is not None:
            activity_record = {
                "user_id": user_id,
                "source": "health_connect",
                "steps": data.steps,
                "calories_burned": data.calories_burned,
                "recorded_at": f"{data.sync_date}T12:00:00Z",
            }
            response = supabase_admin.table("biometric_readings").insert(activity_record).execute()
            records_saved.append("activity")

        # 2. Save sleep data
        if data.sleep is not None:
            sleep_quality = determine_sleep_quality(data.sleep)
            sleep_record = {
                "user_id": user_id,
                "source": "health_connect",
                "sleep_hours": data.sleep.total_hours,
                "sleep_quality": sleep_quality,
                "recorded_at": data.sleep.end_time,
            }
            response = supabase_admin.table("biometric_readings").insert(sleep_record).execute()
            records_saved.append("sleep")

        # 3. Save heart rate data (if wearable present)
        if data.heart_rate_samples and len(data.heart_rate_samples) > 0:
            avg_hr = sum(data.heart_rate_samples) / len(data.heart_rate_samples)
            resting_hr = min(data.heart_rate_samples)

            hr_record = {
                "user_id": user_id,
                "source": "health_connect",
                "heart_rate_bpm": round(avg_hr, 1),
                "recorded_at": f"{data.sync_date}T08:00:00Z",
            }
            response = supabase_admin.table("biometric_readings").insert(hr_record).execute()
            records_saved.append("heart_rate")

        # 4. Save HRV data (if wearable present)
        if data.hrv_samples and len(data.hrv_samples) > 0:
            avg_hrv = sum(data.hrv_samples) / len(data.hrv_samples)

            hrv_record = {
                "user_id": user_id,
                "source": "health_connect",
                "hrv_ms": round(avg_hrv, 1),
                "recorded_at": f"{data.sync_date}T08:00:00Z",
            }
            response = supabase_admin.table("biometric_readings").insert(hrv_record).execute()
            records_saved.append("hrv")

        # 5. Save SpO2 (if available)
        if data.spo2 is not None:
            spo2_record = {
                "user_id": user_id,
                "source": "health_connect",
                "spo2": data.spo2,
                "recorded_at": f"{data.sync_date}T08:00:00Z",
            }
            response = supabase_admin.table("biometric_readings").insert(spo2_record).execute()
            records_saved.append("spo2")

        return {
            "message": f"Health data synced: {', '.join(records_saved)}",
            "records_saved": len(records_saved),
            "has_wearable": data.has_wearable,
            "sync_date": data.sync_date,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def determine_sleep_quality(sleep: SleepSession) -> str:
    """
    Determine sleep quality based on available sleep stage data.
    If detailed stages aren't available (no wearable), use total hours.
    """
    if sleep.deep_sleep_hours is not None and sleep.total_hours > 0:
        deep_ratio = sleep.deep_sleep_hours / sleep.total_hours
        if deep_ratio >= 0.2:
            return "deep"
        elif deep_ratio >= 0.1:
            return "light"
        else:
            return "restless"
    else:
        # No detailed stages — estimate from total hours
        if sleep.total_hours >= 7:
            return "deep"
        elif sleep.total_hours >= 5:
            return "light"
        else:
            return "restless"


@router.get("/summary/{date}")
async def get_health_summary(date: str, user_id: str = Depends(get_current_user)):
    """
    Get a complete health summary for a specific date.
    Combines all biometric readings and self-reports for that day.
    This is what the meal engine will call to understand the user's state.
    """
    try:
        # Get all biometric readings for this date
        biometrics = supabase_admin.table("biometric_readings") \
            .select("*") \
            .eq("user_id", user_id) \
            .gte("recorded_at", f"{date}T00:00:00") \
            .lte("recorded_at", f"{date}T23:59:59") \
            .order("recorded_at", desc=True) \
            .execute()

        # Get self-report for this date if any
        self_report = supabase_admin.table("self_reports") \
            .select("*") \
            .eq("user_id", user_id) \
            .gte("reported_at", f"{date}T00:00:00") \
            .lte("reported_at", f"{date}T23:59:59") \
            .order("reported_at", desc=True) \
            .limit(1) \
            .execute()

        # Compile summary from all readings
        summary = {
            "date": date,
            "steps": None,
            "calories_burned": None,
            "sleep_hours": None,
            "sleep_quality": None,
            "heart_rate_bpm": None,
            "hrv_ms": None,
            "spo2": None,
            "energy_level": None,
            "mood": None,
            "stress_level": None,
            "data_sources": [],
        }

        for reading in biometrics.data:
            source = reading.get("source")
            if source not in summary["data_sources"]:
                summary["data_sources"].append(source)

            # Take the most recent non-null value for each metric
            if reading.get("steps") and summary["steps"] is None:
                summary["steps"] = reading["steps"]
            if reading.get("calories_burned") and summary["calories_burned"] is None:
                summary["calories_burned"] = reading["calories_burned"]
            if reading.get("sleep_hours") and summary["sleep_hours"] is None:
                summary["sleep_hours"] = reading["sleep_hours"]
                summary["sleep_quality"] = reading.get("sleep_quality")
            if reading.get("heart_rate_bpm") and summary["heart_rate_bpm"] is None:
                summary["heart_rate_bpm"] = reading["heart_rate_bpm"]
            if reading.get("hrv_ms") and summary["hrv_ms"] is None:
                summary["hrv_ms"] = reading["hrv_ms"]
            if reading.get("spo2") and summary["spo2"] is None:
                summary["spo2"] = reading["spo2"]

        # Add self-report data
        if self_report.data:
            report = self_report.data[0]
            summary["energy_level"] = report.get("energy_level")
            summary["mood"] = report.get("mood")
            summary["stress_level"] = report.get("stress_level")
            if "self_report" not in summary["data_sources"]:
                summary["data_sources"].append("self_report")

        return {"data": summary}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))