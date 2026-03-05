from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date

class MealPlanResponse(BaseModel):
    id: str
    meal_id: str
    meal_type: str
    plan_date: str
    confidence_score: Optional[float]
    status: str
    meal_name: Optional[str] = None
    calories: Optional[float] = None

class MealPlanStatusUpdate(BaseModel):
    status: str = Field(..., pattern="^(accepted|swapped|skipped|completed)$")

class MealFeedbackCreate(BaseModel):
    plan_id: str
    rating: int = Field(..., ge=1, le=5)
    feedback_tags: List[str] = []
    comment: Optional[str] = None

class HydrationCreate(BaseModel):
    amount_ml: float = Field(..., gt=0, le=5000)

class FastingCreate(BaseModel):
    target_hours: float = Field(..., gt=0, le=72)

class FastingEnd(BaseModel):
    completed: bool