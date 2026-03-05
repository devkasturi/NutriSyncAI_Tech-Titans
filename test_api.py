"""
Comprehensive testing script for NutriSync AI Backend
Tests health endpoints, database, and ML model predictions
"""
import requests
import json
import time

BASE_URL = "http://localhost:8000"

print("=" * 80)
print("🧪 NutriSync AI Backend Testing Suite")
print("=" * 80)

# ─────────────────────────────────────────────────────────────────────────────
# TEST 1: Basic Health Checks
# ─────────────────────────────────────────────────────────────────────────────
print("\n📋 TEST 1: Basic Health Checks")
print("-" * 80)

try:
    # Root endpoint
    response = requests.get(f"{BASE_URL}/")
    print(f"✓ Root endpoint: {response.status_code}")
    print(f"  Response: {response.json()}")
except Exception as e:
    print(f"✗ Root endpoint failed: {e}")

try:
    # Health check
    response = requests.get(f"{BASE_URL}/health")
    print(f"✓ Health check: {response.status_code}")
    print(f"  Response: {response.json()}")
except Exception as e:
    print(f"✗ Health check failed: {e}")

try:
    # Database connection test
    response = requests.get(f"{BASE_URL}/test-db")
    print(f"✓ Database connection test: {response.status_code}")
    print(f"  Response: {response.json()}")
except Exception as e:
    print(f"✗ Database connection failed: {e}")

# ─────────────────────────────────────────────────────────────────────────────
# TEST 2: Test ML Model (if endpoint exists)
# ─────────────────────────────────────────────────────────────────────────────
print("\n🤖 TEST 2: ML Model Prediction")
print("-" * 80)

# Test data for calorie prediction
test_user_data = {
    "age": 28,
    "gender": "female",
    "height_cm": 165,
    "weight_kg": 62,
    "activity_level": "moderate",
    "heart_rate_bpm": 68,
    "hrv_ms": 45,
    "spo2": 98,
    "steps": 8000,
    "sleep_hours": 7,
    "sleep_quality": "deep",
    "stress_level": 3,
    "energy_level": 4,
    "goal_type": "maintenance"
}

try:
    response = requests.post(
        f"{BASE_URL}/predict-calories",
        json=test_user_data,
        headers={"Content-Type": "application/json"}
    )
    print(f"✓ Calorie prediction: {response.status_code}")
    if response.status_code == 200:
        print(f"  Predicted calories: {response.json()}")
    else:
        print(f"  Response: {response.json()}")
except Exception as e:
    print(f"⚠ Calorie prediction endpoint not found or error: {e}")

# ─────────────────────────────────────────────────────────────────────────────
# TEST 3: Available Endpoints Discovery
# ─────────────────────────────────────────────────────────────────────────────
print("\n📡 TEST 3: Available Endpoints (OpenAPI Docs)")
print("-" * 80)

try:
    response = requests.get(f"{BASE_URL}/openapi.json")
    if response.status_code == 200:
        paths = response.json().get("paths", {})
        print(f"✓ Found {len(paths)} endpoints:")
        for path, methods in sorted(paths.items()):
            method_list = ", ".join([m.upper() for m in methods.keys() if m != "parameters"])
            print(f"  • {method_list.ljust(6)} {path}")
    else:
        print(f"✗ OpenAPI spec not found: {response.status_code}")
except Exception as e:
    print(f"✗ Failed to fetch OpenAPI spec: {e}")

# ─────────────────────────────────────────────────────────────────────────────
# TEST 4: Database Connection (if allowed)
# ─────────────────────────────────────────────────────────────────────────────
print("\n🗄️  TEST 4: Database Sanity Check")
print("-" * 80)

try:
    response = requests.get(f"{BASE_URL}/test-db")
    data = response.json()
    if data.get("status") == "connected":
        print(f"✓ Database connected successfully")
        print(f"  Sample data retrieved: {len(data.get('data', []))} records")
    else:
        print(f"⚠ Database status: {data.get('status')}")
        print(f"  Details: {data.get('detail', 'N/A')}")
except Exception as e:
    print(f"✗ Database test failed: {e}")

# ─────────────────────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
print("\n" + "=" * 80)
print("✅ Testing Complete!")
print("=" * 80)
print("\n📖 Next steps:")
print("   1. Check Interactive API Docs: http://localhost:8000/docs")
print("   2. Use the Swagger UI to test endpoints with authentication")
print("   3. For detailed logs, check server terminal output")
print("=" * 80)
