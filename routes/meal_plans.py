from fastapi import APIRouter, Depends, HTTPException
from auth import get_current_user
from config import supabase_admin
from models.meals import MealPlanStatusUpdate, MealFeedbackCreate
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date

router = APIRouter(prefix="/meal-plan", tags=["Meal Plans"])


# --- Pydantic models ---

class MealRecommendation(BaseModel):
    meal_id: str
    meal_type: str
    predicted_calories: float
    confidence_score: Optional[float] = None

class GeneratePlanRequest(BaseModel):
    plan_date: str
    total_predicted_calories: float
    recommendations: List[MealRecommendation]


# --- Endpoint 1: User context for ML pipeline ---

@router.get("/context")
async def get_user_context(user_id: str = Depends(get_current_user)):
    """
    Returns everything the ML pipeline needs about a user:
    profile, diet prefs, allergies, conditions, goals, latest health data.
    Your XGBoost + Gemini system calls this first.
    """
    try:
        context = supabase_admin.table("user_nutrition_context") \
            .select("*") \
            .eq("user_id", user_id) \
            .execute()

        biometrics = supabase_admin.table("biometric_readings") \
            .select("*") \
            .eq("user_id", user_id) \
            .order("recorded_at", desc=True) \
            .limit(5) \
            .execute()

        self_report = supabase_admin.table("self_reports") \
            .select("*") \
            .eq("user_id", user_id) \
            .order("reported_at", desc=True) \
            .limit(1) \
            .execute()

        schedule = supabase_admin.table("meal_schedule") \
            .select("*") \
            .eq("user_id", user_id) \
            .execute()

        recent_feedback = supabase_admin.table("meal_feedback") \
            .select("*, daily_meal_plans(meal_id)") \
            .eq("user_id", user_id) \
            .order("created_at", desc=True) \
            .limit(10) \
            .execute()

        return {
            "user_context": context.data[0] if context.data else None,
            "biometrics": biometrics.data,
            "self_report": self_report.data[0] if self_report.data else None,
            "meal_schedule": schedule.data,
            "recent_feedback": recent_feedback.data,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Endpoint 2: Save generated plan ---

@router.post("/generate")
async def save_generated_plan(
    plan: GeneratePlanRequest,
    user_id: str = Depends(get_current_user)
):
    """
    Receives the output from XGBoost + Gemini pipeline and saves it.
    Called after the ML system has generated recommendations.
    """
    try:
        supabase_admin.table("daily_meal_plans") \
            .delete() \
            .eq("user_id", user_id) \
            .eq("plan_date", plan.plan_date) \
            .execute()

        rows = [
            {
                "user_id": user_id,
                "meal_id": rec.meal_id,
                "meal_type": rec.meal_type,
                "plan_date": plan.plan_date,
                "predicted_calories": rec.predicted_calories,
                "confidence_score": rec.confidence_score,
                "status": "pending",
            }
            for rec in plan.recommendations
        ]

        response = supabase_admin.table("daily_meal_plans").insert(rows).execute()

        return {
            "message": f"Meal plan saved for {plan.plan_date}",
            "total_predicted_calories": plan.total_predicted_calories,
            "meals_count": len(plan.recommendations),
            "data": response.data,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Endpoint 3: Predict calories ---

@router.get("/predict-calories")
async def get_predicted_calories(user_id: str = Depends(get_current_user)):
    """
    Runs XGBoost model to predict daily calorie needs.
    Gathers all user data, feeds it to the model, returns prediction.
    """
    try:
        from ml.predictor import predict_calories

        profile = supabase_admin.table("profiles") \
            .select("*") \
            .eq("id", user_id) \
            .single() \
            .execute()

        goal = supabase_admin.table("health_goals") \
            .select("*") \
            .eq("user_id", user_id) \
            .eq("is_active", True) \
            .limit(1) \
            .execute()

        biometrics = supabase_admin.table("biometric_readings") \
            .select("*") \
            .eq("user_id", user_id) \
            .order("recorded_at", desc=True) \
            .limit(5) \
            .execute()

        self_report = supabase_admin.table("self_reports") \
            .select("*") \
            .eq("user_id", user_id) \
            .order("reported_at", desc=True) \
            .limit(1) \
            .execute()

        user_data = {
            "age": profile.data.get("age"),
            "gender": profile.data.get("gender"),
            "height_cm": profile.data.get("height_cm"),
            "weight_kg": profile.data.get("weight_kg"),
            "activity_level": profile.data.get("activity_level"),
            "goal_type": goal.data[0]["goal_type"] if goal.data else "maintenance",
        }

        for reading in biometrics.data:
            if reading.get("heart_rate_bpm") and "heart_rate_bpm" not in user_data:
                user_data["heart_rate_bpm"] = reading["heart_rate_bpm"]
            if reading.get("hrv_ms") and "hrv_ms" not in user_data:
                user_data["hrv_ms"] = reading["hrv_ms"]
            if reading.get("spo2") and "spo2" not in user_data:
                user_data["spo2"] = reading["spo2"]
            if reading.get("steps") and "steps" not in user_data:
                user_data["steps"] = reading["steps"]
            if reading.get("sleep_hours") and "sleep_hours" not in user_data:
                user_data["sleep_hours"] = reading["sleep_hours"]
            if reading.get("sleep_quality") and "sleep_quality" not in user_data:
                user_data["sleep_quality"] = reading["sleep_quality"]

        if self_report.data:
            user_data["stress_level"] = self_report.data[0].get("stress_level")
            user_data["energy_level"] = self_report.data[0].get("energy_level")

        predicted_calories = predict_calories(user_data)

        return {
            "predicted_calories": predicted_calories,
            "input_data": user_data,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Endpoint 4: Meals catalog ---

@router.get("/meals/catalog")
async def get_meals_catalog(
    diet_type: Optional[str] = None,
    cuisine: Optional[str] = None,
    meal_type: Optional[str] = None
):
    """
    Fetch meals from the catalog with optional filters.
    Your Gemini pipeline calls this to get candidate meals.
    """
    try:
        query = supabase_admin.table("meals").select("*").eq("is_active", True)

        if meal_type:
            query = query.eq("meal_type", meal_type)
        if cuisine:
            query = query.eq("cuisine", cuisine)

        response = query.execute()
        return {"data": response.data, "count": len(response.data)}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Endpoint 5: Feedback ---

@router.post("/feedback")
async def save_meal_feedback(
    feedback: MealFeedbackCreate,
    user_id: str = Depends(get_current_user)
):
    """Save user feedback on a meal recommendation. Powers model retraining."""
    try:
        response = supabase_admin.table("meal_feedback").insert({
            "user_id": user_id,
            "plan_id": feedback.plan_id,
            "rating": feedback.rating,
            "feedback_tags": feedback.feedback_tags,
            "comment": feedback.comment,
        }).execute()

        return {"message": "Feedback saved", "data": response.data[0]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Endpoint 6: Update meal status ---

@router.patch("/{plan_id}/status")
async def update_plan_status(
    plan_id: str,
    update: MealPlanStatusUpdate,
    user_id: str = Depends(get_current_user)
):
    """Update meal plan status — accepted, skipped, swapped, completed."""
    try:
        response = supabase_admin.table("daily_meal_plans") \
            .update({"status": update.status}) \
            .eq("id", plan_id) \
            .eq("user_id", user_id) \
            .execute()

        if not response.data:
            raise HTTPException(status_code=404, detail="Plan not found")

        return {"message": f"Status updated to {update.status}", "data": response.data[0]}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Endpoint 7: Get meal plan (KEEP THIS LAST — catches /{anything}) ---

@router.get("/{plan_date}")
async def get_meal_plan(plan_date: str, user_id: str = Depends(get_current_user)):
    """
    Fetch today's meal plan with full meal details.
    Flutter calls this to display the daily recommendations.
    """
    try:
        response = supabase_admin.table("daily_meal_plans") \
            .select("*, meals(name, description, calories, protein_g, carbs_g, fat_g, cuisine, diet_type, prep_time_min, image_url, recipe)") \
            .eq("user_id", user_id) \
            .eq("plan_date", plan_date) \
            .order("meal_type") \
            .execute()

        if not response.data:
            return {"data": [], "message": "No meal plan found for this date"}

        return {"data": response.data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))