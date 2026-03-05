from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, time

# --- Onboarding Models ---

class ProfileCreate(BaseModel):
    full_name: str = Field(..., min_length=1, max_length=100)
    age: int = Field(..., ge=13, le=120)
    gender: str = Field(..., pattern="^(male|female|other)$")
    height_cm: float = Field(..., gt=0, le=300)
    weight_kg: float = Field(..., gt=0, le=500)
    activity_level: str = Field(
        default="sedentary",
        pattern="^(sedentary|light|moderate|active|very_active)$"
    )
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    city: Optional[str] = None

class ProfileResponse(BaseModel):
    id: str
    full_name: str
    age: int
    gender: str
    height_cm: float
    weight_kg: float
    activity_level: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    city: Optional[str] = None

class DietPreferenceCreate(BaseModel):
    diet_type: List[str]  # e.g. ["veg", "eggetarian"]
    cuisine_preferences: List[str] = []

class AllergyCreate(BaseModel):
    allergen: str = Field(..., min_length=1)

class HealthConditionCreate(BaseModel):
    condition: str = Field(..., min_length=1)
    diagnosed_date: Optional[date] = None

class HealthGoalCreate(BaseModel):
    goal_type: str = Field(
        ...,
        pattern="^(weight_loss|muscle_gain|maintenance|pcos_control|diabetes_control|bp_control)$"
    )
    target_weight_kg: Optional[float] = Field(default=None, gt=0, le=500)
    target_date: Optional[date] = None

class MealScheduleItem(BaseModel):
    meal_type: str = Field(
        ...,
        pattern="^(breakfast|lunch|dinner|morning_snack|evening_snack)$"
    )
    preferred_time: str = Field(...)  # "08:00", "13:00" etc.
    is_enabled: bool = True

class MealScheduleCreate(BaseModel):
    meals: List[MealScheduleItem]