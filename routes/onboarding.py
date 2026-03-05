from fastapi import APIRouter, Depends, HTTPException
from auth import get_current_user
from config import supabase_admin
from models.user import (
    ProfileCreate, ProfileResponse,
    DietPreferenceCreate, AllergyCreate,
    HealthConditionCreate, HealthGoalCreate,
    MealScheduleCreate
)

router = APIRouter(prefix="/onboarding", tags=["Onboarding"])

# --- Profile ---

@router.put("/profile")
async def update_profile(profile: ProfileCreate, user_id: str = Depends(get_current_user)):
    """Update user profile during onboarding."""
    try:
        data = {
            "full_name": profile.full_name,
            "age": profile.age,
            "gender": profile.gender,
            "height_cm": profile.height_cm,
            "weight_kg": profile.weight_kg,
            "activity_level": profile.activity_level,
        }
        if profile.latitude is not None:
            data["latitude"] = profile.latitude
        if profile.longitude is not None:
            data["longitude"] = profile.longitude
        if profile.city is not None:
            data["city"] = profile.city

        response = supabase_admin.table("profiles").update(data).eq("id", user_id).execute()

        if not response.data:
            raise HTTPException(status_code=404, detail="Profile not found")

        return {"message": "Profile updated", "data": response.data[0]}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/profile")
async def get_profile(user_id: str = Depends(get_current_user)):
    """Get current user's profile."""
    try:
        response = supabase_admin.table("profiles").select("*").eq("id", user_id).single().execute()
        return {"data": response.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Diet Preferences ---

@router.post("/diet-preferences")
async def save_diet_preferences(prefs: DietPreferenceCreate, user_id: str = Depends(get_current_user)):
    """Save or update diet preferences. Uses upsert so it works for both create and update."""
    try:
        response = supabase_admin.table("diet_preferences").upsert({
            "user_id": user_id,
            "diet_type": prefs.diet_type,
            "cuisine_preferences": prefs.cuisine_preferences,
        }, on_conflict="user_id").execute()

        return {"message": "Diet preferences saved", "data": response.data[0]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Allergies ---

@router.post("/allergies")
async def save_allergies(allergies: list[AllergyCreate], user_id: str = Depends(get_current_user)):
    """Save user allergies. Accepts a list so the Flutter app can send all at once."""
    try:
        # Clear existing allergies and replace with new list
        supabase_admin.table("allergies").delete().eq("user_id", user_id).execute()

        if not allergies:
            return {"message": "Allergies cleared", "data": []}

        rows = [
            {
                "user_id": user_id,
                "allergen": a.allergen,
            }
            for a in allergies
        ]

        response = supabase_admin.table("allergies").insert(rows).execute()
        return {"message": f"{len(allergies)} allergies saved", "data": response.data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Health Conditions ---

@router.post("/health-conditions")
async def save_health_conditions(
    conditions: list[HealthConditionCreate],
    user_id: str = Depends(get_current_user)
):
    """Save health conditions. Replace-all approach like allergies."""
    try:
        supabase_admin.table("health_conditions").delete().eq("user_id", user_id).execute()

        if not conditions:
            return {"message": "Health conditions cleared", "data": []}

        rows = [
            {
                "user_id": user_id,
                "condition": c.condition,
                "diagnosed_date": c.diagnosed_date.isoformat() if c.diagnosed_date else None,
            }
            for c in conditions
        ]

        response = supabase_admin.table("health_conditions").insert(rows).execute()
        return {"message": f"{len(conditions)} conditions saved", "data": response.data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Health Goals ---

@router.post("/health-goal")
async def save_health_goal(goal: HealthGoalCreate, user_id: str = Depends(get_current_user)):
    """Save a health goal. Deactivates previous goals first so only one is active."""
    try:
        # Deactivate all existing goals
        supabase_admin.table("health_goals").update(
            {"is_active": False}
        ).eq("user_id", user_id).eq("is_active", True).execute()

        # Insert new active goal
        response = supabase_admin.table("health_goals").insert({
            "user_id": user_id,
            "goal_type": goal.goal_type,
            "target_weight_kg": goal.target_weight_kg,
            "target_date": goal.target_date.isoformat() if goal.target_date else None,
            "is_active": True,
        }).execute()

        return {"message": "Health goal saved", "data": response.data[0]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Meal Schedule ---

@router.post("/meal-schedule")
async def save_meal_schedule(schedule: MealScheduleCreate, user_id: str = Depends(get_current_user)):
    """Save meal schedule. Replaces all existing entries."""
    try:
        supabase_admin.table("meal_schedule").delete().eq("user_id", user_id).execute()

        rows = [
            {
                "user_id": user_id,
                "meal_type": item.meal_type,
                "preferred_time": item.preferred_time,
                "is_enabled": item.is_enabled,
            }
            for item in schedule.meals
        ]

        response = supabase_admin.table("meal_schedule").insert(rows).execute()
        return {"message": f"Meal schedule saved with {len(schedule.meals)} slots", "data": response.data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))