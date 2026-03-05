# =============================================================================
# NutriSync AI — main.py  (Final Version)
# FastAPI + XGBoost + Scaler + Gemini 1.5 Flash
#
# Local dev:
#   set GEMINI_API_KEY=your-key   (Windows)
#   export GEMINI_API_KEY=your-key (Mac/Linux)
#   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
#
# Deploy (Render/Railway):
#   uvicorn main:app --host 0.0.0.0 --port $PORT
# =============================================================================
from dotenv import load_dotenv
load_dotenv()
import os
import re
import json
import pickle
import logging
from contextlib import asynccontextmanager
from typing import Optional

import numpy as np
import pandas as pd
import google.generativeai as genai

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, field_validator

# ── Logging ───────────────────────────────────────────────────────────────────
logging.basicConfig(
    level  = logging.INFO,
    format = "%(asctime)s [%(levelname)s] %(name)s — %(message)s",
)
log = logging.getLogger("nutrisync")

# ── Config ────────────────────────────────────────────────────────────────────
MODEL_PATH      = os.getenv("MODEL_PATH",  "nutrisync_v1.pkl")
SCALER_PATH     = os.getenv("SCALER_PATH", "scaler.pkl")
GEMINI_API_KEY  = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL    = "gemini-1.5-flash"

# ── Global State ──────────────────────────────────────────────────────────────
_model_bundle : dict = {}
_scaler_bundle: dict = {}
_gemini_model        = None

# ── Lifespan ──────────────────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    global _model_bundle, _scaler_bundle, _gemini_model

    # Load model
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(
            f"'{MODEL_PATH}' not found. Run train_model.py in Colab first."
        )
    with open(MODEL_PATH, "rb") as f:
        _model_bundle = pickle.load(f)
    log.info("✅ Model loaded  — version: %s | R²: %s | MAE: %s kcal",
             _model_bundle.get("model_version", "unknown"),
             _model_bundle.get("training_r2",   "?"),
             _model_bundle.get("training_mae",   "?"))

    # Load scaler
    if not os.path.exists(SCALER_PATH):
        raise FileNotFoundError(
            f"'{SCALER_PATH}' not found. Run train_model.py in Colab first."
        )
    with open(SCALER_PATH, "rb") as f:
        _scaler_bundle = pickle.load(f)
    log.info("✅ Scaler loaded — features: %s", _scaler_bundle["feature_names"])

    # Init Gemini
    if not GEMINI_API_KEY:
        log.warning("⚠️  GEMINI_API_KEY not set — meal recommendations disabled.")
    else:
        genai.configure(api_key=GEMINI_API_KEY)
        _gemini_model = genai.GenerativeModel(GEMINI_MODEL)
        log.info("✅ Gemini %s initialised.", GEMINI_MODEL)

    yield
    log.info("🛑 NutriSync AI shutting down.")

# ── App ───────────────────────────────────────────────────────────────────────
app = FastAPI(
    title       = "NutriSync AI",
    description = "Physiology-driven nutrition OS — PPG × XGBoost × Gemini",
    version     = "2.0.0",
    lifespan    = lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins  = ["*"],
    allow_methods  = ["*"],
    allow_headers  = ["*"],
)

# ── Constants ─────────────────────────────────────────────────────────────────
_ACTIVITY_MULTIPLIERS = {1: 1.2, 2: 1.375, 3: 1.55, 4: 1.725, 5: 1.9}
_ACTIVITY_LABELS      = {
    1: "Sedentary",
    2: "Lightly Active",
    3: "Moderately Active",
    4: "Very Active",
    5: "Athlete",
}
_GOAL_ENC = {"Weight_Loss": 0, "Maintenance": 1, "Muscle_Gain": 2}
_GOAL_LABELS = {v: k.replace("_", " ") for k, v in _GOAL_ENC.items()}

# ── Request Schema ────────────────────────────────────────────────────────────
class HealthPayload(BaseModel):
    # PPG inputs (from Flutter)
    hr  : float = Field(..., ge=30,  le=220, description="Mean Heart Rate (bpm)")
    hrv : float = Field(..., ge=5,   le=120, description="HRV — RMSSD (ms)")

    # User profile (from onboarding)
    age    : int   = Field(..., ge=10, le=110, description="Age in years")
    height : float = Field(..., ge=100, le=250, description="Height in cm")
    weight : float = Field(..., ge=20,  le=300, description="Weight in kg")
    gender : int   = Field(1,   ge=0,   le=1,   description="0=Female, 1=Male")

    # Questionnaire inputs
    goal           : str = Field("Maintenance", description="Weight_Loss | Maintenance | Muscle_Gain")
    activity_level : int = Field(3, ge=1, le=5,   description="1=Sedentary … 5=Athlete")
    duration_min   : float = Field(30, ge=1, le=300, description="Session duration (min)")

    # Optional extras
    allergies      : Optional[list[str]] = Field(default=[], description="e.g. ['peanuts','dairy']")
    cuisine_pref   : Optional[str]       = Field(default="Any", description="e.g. Indian, Mediterranean")
    feedback_score : Optional[int]       = Field(None, ge=1, le=5, description="Last meal rating 1–5")

    @field_validator("goal")
    @classmethod
    def validate_goal(cls, v):
        if v not in _GOAL_ENC:
            raise ValueError(f"goal must be one of {list(_GOAL_ENC.keys())}")
        return v

# ── Response Schema ───────────────────────────────────────────────────────────
class HealthResponse(BaseModel):
    calorie_target       : float
    bmi                  : float
    stress_state         : str
    hrv_ms               : float
    goal                 : str
    activity_label       : str
    meals                : list[dict]
    daily_tip            : str
    model_feature_values : dict

# ── Helpers ───────────────────────────────────────────────────────────────────
def _compute_bmi(height_cm: float, weight_kg: float) -> float:
    return round(weight_kg / ((height_cm / 100) ** 2), 2)

def _build_feature_vector(payload: HealthPayload, bmi: float) -> tuple[pd.DataFrame, dict]:
    feature_names = _model_bundle["feature_names"]
    hrv_thresh    = _model_bundle.get("hrv_stress_threshold", 40)
    is_stressed   = int(payload.hrv < hrv_thresh)
    goal_enc      = _GOAL_ENC[payload.goal]

    raw = {
        "Gender_enc" : payload.gender,
        "Age"        : payload.age,
        "BMI"        : bmi,
        "Heart_Rate" : payload.hr,
        "HRV"        : payload.hrv,
        "Goal_enc"   : goal_enc,
        "Duration"   : payload.duration_min,
        "Is_Stressed": is_stressed,
    }

    df = pd.DataFrame([[raw[f] for f in feature_names]], columns=feature_names)
    return df, raw, is_stressed

def _scale_features(feature_df: pd.DataFrame) -> pd.DataFrame:
    scaler        = _scaler_bundle["scaler"]
    feature_names = _scaler_bundle["feature_names"]
    scaled        = scaler.transform(feature_df)
    return pd.DataFrame(scaled, columns=feature_names)

def _build_gemini_prompt(
    calorie_target : float,
    stress_state   : str,
    age            : int,
    bmi            : float,
    goal           : str,
    activity_label : str,
    allergies      : list[str],
    cuisine_pref   : str,
    feedback_score : Optional[int],
) -> str:

    # Allergy clause
    allergy_clause = (
        f"ALLERGIES / INTOLERANCES: {', '.join(allergies)}. "
        "Never include these ingredients in any meal."
        if allergies else
        "No known allergies."
    )

    # Stress-based clinical context
    if stress_state == "Stressed":
        clinical = (
            "HIGH STRESS detected (Low HRV). Cortisol is elevated — "
            "prioritise anti-inflammatory foods, magnesium-rich ingredients, "
            "complex carbs, and HPA-axis supporting foods "
            "(dark leafy greens, fatty fish, nuts, seeds, dark chocolate)."
        )
    else:
        clinical = (
            "RELAXED state (High HRV). Good parasympathetic tone — "
            "optimise for performance and recovery with higher protein, "
            "balanced macros, and antioxidant-rich produce."
        )

    # Goal context
    goal_context = {
        "Weight_Loss" : "Caloric deficit — keep meals low-GI, high fibre, high satiety.",
        "Maintenance" : "Maintain current weight — balanced macros across all meals.",
        "Muscle_Gain" : "Caloric surplus — prioritise protein timing, complex carbs post-workout.",
    }[goal]

    # One-Tap Feedback clause
    feedback_clause = ""
    if feedback_score is not None:
        weight_map = {
            1: "User rated last meal 1/5 — very dissatisfied. Use completely different ingredients and cuisine.",
            2: "User rated last meal 2/5 — somewhat dissatisfied. Introduce new cuisine style.",
            3: "User rated last meal 3/5 — neutral. Keep same macro balance, vary ingredients.",
            4: "User rated last meal 4/5 — satisfied. Minor variation in same cuisine style.",
            5: "User rated last meal 5/5 — very satisfied. Keep same macro profile and cuisine.",
        }
        feedback_clause = f"\nFEEDBACK SIGNAL: {weight_map[feedback_score]}"

    return f"""You are a clinical precision nutritionist and culinary scientist.

PATIENT PROFILE:
  • Age            : {age} years
  • BMI            : {bmi}
  • Goal           : {goal.replace('_', ' ')}
  • Activity Level : {activity_label}
  • Calorie Target : {calorie_target:.0f} kcal (daily total, scientifically computed)
  • Stress State   : {stress_state} (measured via real-time Heart Rate Variability)
  • Cuisine Pref   : {cuisine_pref}

CLINICAL RULES:
  • {clinical}
  • {goal_context}
  • {allergy_clause}
{feedback_clause}

MEAL DISTRIBUTION:
  • Breakfast : 25% = {calorie_target * 0.25:.0f} kcal
  • Lunch     : 40% = {calorie_target * 0.40:.0f} kcal
  • Dinner    : 35% = {calorie_target * 0.35:.0f} kcal

TASK:
Recommend exactly 3 meals (Breakfast, Lunch, Dinner) that together total {calorie_target:.0f} kcal.
Each meal must be biologically optimised for the patient's stress state and goal.

STRICT RESPONSE FORMAT — return ONLY valid JSON, no markdown, no extra text:
{{
  "meals": [
    {{
      "meal_type"       : "Breakfast",
      "name"            : "...",
      "calories"        : 0,
      "protein_g"       : 0.0,
      "carbs_g"         : 0.0,
      "fat_g"           : 0.0,
      "fibre_g"         : 0.0,
      "key_ingredients" : ["...", "...", "..."],
      "prep_time_min"   : 0,
      "bio_reasoning"   : "One sentence: why this meal suits the patient's HRV state and goal."
    }},
    {{
      "meal_type"       : "Lunch",
      "name"            : "...",
      "calories"        : 0,
      "protein_g"       : 0.0,
      "carbs_g"         : 0.0,
      "fat_g"           : 0.0,
      "fibre_g"         : 0.0,
      "key_ingredients" : ["...", "...", "..."],
      "prep_time_min"   : 0,
      "bio_reasoning"   : "..."
    }},
    {{
      "meal_type"       : "Dinner",
      "name"            : "...",
      "calories"        : 0,
      "protein_g"       : 0.0,
      "carbs_g"         : 0.0,
      "fat_g"           : 0.0,
      "fibre_g"         : 0.0,
      "key_ingredients" : ["...", "...", "..."],
      "prep_time_min"   : 0,
      "bio_reasoning"   : "..."
    }}
  ],
  "total_calories" : 0,
  "daily_tip"      : "One actionable tip based on stress state and goal."
}}"""

# ── Main Endpoint ─────────────────────────────────────────────────────────────
@app.post("/analyze_health", response_model=HealthResponse, tags=["Core"])
async def analyze_health(payload: HealthPayload):
    """
    Full NutriSync pipeline:
    1. Compute BMI from height + weight.
    2. Build + scale feature vector.
    3. XGBoost predicts base calories.
    4. Apply TDEE activity multiplier.
    5. Gemini generates 3 personalised meals.
    """

    # ── 1. BMI
    bmi = _compute_bmi(payload.height, payload.weight)

    # ── 2. Feature vector + scale
    feature_df, raw_features, is_stressed = _build_feature_vector(payload, bmi)
    feature_scaled = _scale_features(feature_df)

    # ── 3. Predict base calories
    model     = _model_bundle["model"]
    base_cals = float(model.predict(feature_scaled)[0])

    # ── 4. TDEE multiplier
    multiplier     = _ACTIVITY_MULTIPLIERS.get(payload.activity_level, 1.55)
    calorie_target = round(base_cals * multiplier, 1)
    stress_state   = "Stressed" if is_stressed else "Relaxed"
    activity_label = _ACTIVITY_LABELS[payload.activity_level]

    log.info("Prediction → base: %.1f kcal | TDEE: %.1f kcal | BMI: %.1f | state: %s",
             base_cals, calorie_target, bmi, stress_state)

    # ── 5. Gemini meals
    meals     : list[dict] = []
    daily_tip : str        = ""

    if _gemini_model:
        prompt = _build_gemini_prompt(
            calorie_target = calorie_target,
            stress_state   = stress_state,
            age            = payload.age,
            bmi            = bmi,
            goal           = payload.goal,
            activity_label = activity_label,
            allergies      = payload.allergies or [],
            cuisine_pref   = payload.cuisine_pref or "Any",
            feedback_score = payload.feedback_score,
        )
        try:
            response = _gemini_model.generate_content(prompt)
            clean    = re.sub(r"```(?:json)?|```", "", response.text).strip()
            parsed   = json.loads(clean)
            meals    = parsed.get("meals",     [])
            daily_tip = parsed.get("daily_tip", "")
            log.info("Gemini returned %d meals.", len(meals))
        except Exception as exc:
            log.error("Gemini error: %s", exc)
            meals     = [{"error": "Meal generation unavailable.", "detail": str(exc)}]
            daily_tip = ""
    else:
        meals     = [{"error": "GEMINI_API_KEY not configured."}]
        daily_tip = ""

    return HealthResponse(
        calorie_target       = calorie_target,
        bmi                  = bmi,
        stress_state         = stress_state,
        hrv_ms               = payload.hrv,
        goal                 = payload.goal.replace("_", " "),
        activity_label       = activity_label,
        meals                = meals,
        daily_tip            = daily_tip,
        model_feature_values = raw_features,
    )

# ── Health Check ──────────────────────────────────────────────────────────────
@app.get("/health", tags=["Ops"])
async def health_check():
    return {
        "status"        : "ok",
        "model_loaded"  : bool(_model_bundle),
        "scaler_loaded" : bool(_scaler_bundle),
        "gemini_ready"  : _gemini_model is not None,
        "model_version" : _model_bundle.get("model_version", "unknown"),
        "api_version"   : app.version,
    }

@app.get("/", tags=["Ops"])
async def root():
    return {"message": "NutriSync AI v2 is alive. POST /analyze_health to begin."}

# ── Dev runner ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host   = "0.0.0.0",
        port   = int(os.getenv("PORT", 8000)),
        reload = True,
    )
