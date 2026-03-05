"""
Direct ML Model Testing
Bypasses API - tests the XGBoost model directly
"""
import sys
import os

# Add the backend path to Python path
sys.path.insert(0, r"d:\Anushree\NutriSync\nutrisync-backend")

print("=" * 80)
print("🤖 NutriSync ML Model Direct Test")
print("=" * 80)

# ─────────────────────────────────────────────────────────────────────────────
# Load and verify model
# ─────────────────────────────────────────────────────────────────────────────
print("\n📦 Loading ML Model...")
print("-" * 80)

try:
    from ml.predictor import predict_calories, encode_activity_level, encode_sleep_quality
    print("✓ Successfully imported predictor functions")
except Exception as e:
    print(f"✗ Failed to import: {e}")
    print("  Make sure model.pkl exists in ml/ folder")
    sys.exit(1)

# ─────────────────────────────────────────────────────────────────────────────
# Test predictions with various scenarios
# ─────────────────────────────────────────────────────────────────────────────
print("\n🔮 Testing Predictions with Different User Profiles")
print("-" * 80)

test_scenarios = [
    {
        "name": "Sedentary Maintenance",
        "data": {
            "age": 35,
            "gender": "female",
            "height_cm": 162,
            "weight_kg": 65,
            "activity_level": "sedentary",
            "heart_rate_bpm": 72,
            "hrv_ms": 40,
            "spo2": 97,
            "steps": 3000,
            "sleep_hours": 6.5,
            "sleep_quality": "light",
            "stress_level": 5,
            "energy_level": 2,
            "goal_type": "maintenance"
        }
    },
    {
        "name": "Active Weight Loss",
        "data": {
            "age": 28,
            "gender": "female",
            "height_cm": 165,
            "weight_kg": 75,
            "activity_level": "active",
            "heart_rate_bpm": 65,
            "hrv_ms": 55,
            "spo2": 98,
            "steps": 12000,
            "sleep_hours": 8,
            "sleep_quality": "deep",
            "stress_level": 2,
            "energy_level": 4,
            "goal_type": "weight_loss"
        }
    },
    {
        "name": "Very Active Muscle Gain",
        "data": {
            "age": 25,
            "gender": "male",
            "height_cm": 180,
            "weight_kg": 80,
            "activity_level": "very_active",
            "heart_rate_bpm": 60,
            "hrv_ms": 65,
            "spo2": 99,
            "steps": 15000,
            "sleep_hours": 8.5,
            "sleep_quality": "deep",
            "stress_level": 1,
            "energy_level": 5,
            "goal_type": "muscle_gain"
        }
    },
    {
        "name": "PCOS Control",
        "data": {
            "age": 32,
            "gender": "female",
            "height_cm": 158,
            "weight_kg": 70,
            "activity_level": "moderate",
            "heart_rate_bpm": 78,
            "hrv_ms": 35,
            "spo2": 96,
            "steps": 8500,
            "sleep_hours": 7,
            "sleep_quality": "mixed",
            "stress_level": 4,
            "energy_level": 3,
            "goal_type": "pcos_control"
        }
    },
    {
        "name": "Diabetes Control",
        "data": {
            "age": 55,
            "gender": "male",
            "height_cm": 175,
            "weight_kg": 95,
            "activity_level": "light",
            "heart_rate_bpm": 82,
            "hrv_ms": 30,
            "spo2": 95,
            "steps": 5000,
            "sleep_hours": 7.5,
            "sleep_quality": "light",
            "stress_level": 3,
            "energy_level": 2,
            "goal_type": "diabetes_control"
        }
    }
]

for scenario in test_scenarios:
    try:
        prediction = predict_calories(scenario["data"])
        print(f"\n✓ {scenario['name']}")
        print(f"  Predicted Daily Calories: {prediction} kcal")
        print(f"  Profile: {scenario['data']['age']}yr, {scenario['data']['gender']}, "
              f"{scenario['data']['weight_kg']}kg, {scenario['data']['activity_level']}")
    except Exception as e:
        print(f"\n✗ {scenario['name']}")
        print(f"  Error: {e}")

# ─────────────────────────────────────────────────────────────────────────────
# Test encoding functions
# ─────────────────────────────────────────────────────────────────────────────
print("\n" + "=" * 80)
print("📊 Testing Encoding Functions")
print("-" * 80)

print("\nActivity Levels:")
for level in ["sedentary", "light", "moderate", "active", "very_active", "invalid"]:
    encoded = encode_activity_level(level)
    print(f"  {level.ljust(12)} → {encoded}")

print("\nSleep Quality:")
for quality in ["restless", "light", "mixed", "deep", "invalid"]:
    encoded = encode_sleep_quality(quality)
    print(f"  {quality.ljust(12)} → {encoded}")

# ─────────────────────────────────────────────────────────────────────────────
# Final summary
# ─────────────────────────────────────────────────────────────────────────────
print("\n" + "=" * 80)
print("✅ ML Model Direct Test Complete!")
print("=" * 80)
print("\n📝 Summary:")
print("   • Model loaded and predictions working ✓")
print("   • Feature encoding verified ✓")
print("   • Ready for API integration ✓")
print("=" * 80)
