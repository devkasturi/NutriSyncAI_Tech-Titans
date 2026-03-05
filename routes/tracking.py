from fastapi import APIRouter, Depends, HTTPException
from auth import get_current_user
from config import supabase_admin
from models.meals import HydrationCreate, FastingCreate, FastingEnd
from datetime import datetime, date

router = APIRouter(prefix="/tracking", tags=["Tracking"])


# --- Hydration ---

@router.post("/hydration")
async def log_hydration(
    entry: HydrationCreate,
    user_id: str = Depends(get_current_user)
):
    """Log a water intake entry."""
    try:
        response = supabase_admin.table("hydration_log").insert({
            "user_id": user_id,
            "amount_ml": entry.amount_ml,
        }).execute()

        return {"message": f"{entry.amount_ml}ml logged", "data": response.data[0]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/hydration/today")
async def get_today_hydration(user_id: str = Depends(get_current_user)):
    """Get today's total water intake."""
    try:
        today = date.today().isoformat()

        response = supabase_admin.table("hydration_log") \
            .select("*") \
            .eq("user_id", user_id) \
            .gte("logged_at", f"{today}T00:00:00") \
            .lte("logged_at", f"{today}T23:59:59") \
            .execute()

        total_ml = sum(entry["amount_ml"] for entry in response.data)

        return {
            "total_ml": total_ml,
            "entries": response.data,
            "count": len(response.data)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Fasting ---

@router.post("/fasting/start")
async def start_fasting(
    fasting: FastingCreate,
    user_id: str = Depends(get_current_user)
):
    """Start a new fasting window."""
    try:
        # Check if there's already an active fast
        active = supabase_admin.table("fasting_windows") \
            .select("id") \
            .eq("user_id", user_id) \
            .is_("fast_end", "null") \
            .execute()

        if active.data:
            raise HTTPException(
                status_code=400,
                detail="You already have an active fasting window. End it first."
            )

        response = supabase_admin.table("fasting_windows").insert({
            "user_id": user_id,
            "fast_start": datetime.utcnow().isoformat(),
            "target_hours": fasting.target_hours,
        }).execute()

        return {"message": "Fasting started", "data": response.data[0]}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/fasting/end")
async def end_fasting(
    body: FastingEnd,
    user_id: str = Depends(get_current_user)
):
    """End the current active fasting window."""
    try:
        active = supabase_admin.table("fasting_windows") \
            .select("*") \
            .eq("user_id", user_id) \
            .is_("fast_end", "null") \
            .execute()

        if not active.data:
            raise HTTPException(status_code=404, detail="No active fasting window found")

        fasting_id = active.data[0]["id"]

        response = supabase_admin.table("fasting_windows").update({
            "fast_end": datetime.utcnow().isoformat(),
            "completed": body.completed,
        }).eq("id", fasting_id).execute()

        return {"message": "Fasting ended", "data": response.data[0]}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))