import pickle
import os
import numpy as np

# Load model once at startup (not on every request)
MODEL_PATH = os.path.join(os.path.dirname(__file__), "model.pkl")

with open(MODEL_PATH, "rb") as f:
    model = pickle.load(f)

def predict_calories(user_data: dict) -> float:
    """
    Takes user context and returns predicted daily calorie needs.
    
    The features MUST match exactly what your model was trained on,
    in the same order. Adjust the list below to match your training.
    """
    
    # Build feature array in the SAME order as training
    features = [
        user_data.get("age", 25),
        1 if user_data.get("gender") == "male" else 0,
        user_data.get("height_cm", 170),
        user_data.get("weight_kg", 70),
        encode_activity_level(user_data.get("activity_level", "sedentary")),
        user_data.get("heart_rate_bpm", 72),
        user_data.get("hrv_ms", 50),
        user_data.get("spo2", 97),
        user_data.get("steps", 5000),
        user_data.get("sleep_hours", 7),
        encode_sleep_quality(user_data.get("sleep_quality", "light")),
        user_data.get("stress_level", 3),
        user_data.get("energy_level", 3),
        encode_goal(user_data.get("goal_type", "maintenance")),
    ]

    prediction = model.predict(np.array([features]))[0]
    return round(float(prediction), 1)


def encode_activity_level(level: str) -> int:
    mapping = {
        "sedentary": 0,
        "light": 1,
        "moderate": 2,
        "active": 3,
        "very_active": 4,
    }
    return mapping.get(level, 0)


def encode_sleep_quality(quality: str) -> int:
    mapping = {
        "restless": 0,
        "light": 1,
        "mixed": 2,
        "deep": 3,
    }
    return mapping.get(quality, 1)


def encode_goal(goal: str) -> int:
    mapping = {
        "weight_loss": 0,
        "maintenance": 1,
        "muscle_gain": 2,
        "pcos_control": 3,
        "diabetes_control": 4,
        "bp_control": 5,
    }
    return mapping.get(goal, 1)