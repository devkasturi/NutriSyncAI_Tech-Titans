# 🧪 NutriSync AI Backend Testing Guide

## Quick Start

### Prerequisites
- Python 3.8+
- All dependencies installed from `requirements.txt`
- `.env` file configured with Supabase credentials

---

## **1. Start the Backend Server**

```bash
cd d:\Anushree\NutriSync\nutrisync-backend
python main.py
```

Expected output:
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

---

## **2. Test API Endpoints**

### Option A: Using the Test Script (Recommended)
```bash
cd d:\Anushree\NutriSync\nutrisync-backend
python test_api.py
```

This tests:
- ✓ Root endpoint `/`
- ✓ Health check `/health`
- ✓ Database connection `/test-db`
- ✓ Available endpoints from OpenAPI spec
- ✓ ML model predictions (if endpoint exists)

### Option B: Interactive API Explorer (FastAPI Docs)
Open in browser: **http://localhost:8000/docs**

This gives you:
- 📖 Full endpoint documentation
- 🧪 Try-it-out functionality
- 🔐 Authentication UI (for protected endpoints)
- 💾 Sample request/response bodies

### Option C: Using curl
```bash
# Test root
curl http://localhost:8000/

# Test health
curl http://localhost:8000/health

# Test database
curl http://localhost:8000/test-db
```

---

## **3. Test ML Model Directly**

### Run Direct Model Test
```bash
cd d:\Anushree\NutriSync\nutrisync-backend
python test_model_direct.py
```

This tests:
- ✓ Model loads successfully
- ✓ Predictions work for 5 different user profiles
- ✓ Encoding functions work correctly
- ✓ Output is reasonable

---

## **4. Test Individual Components**

### Test Model Files Exist
```bash
# Check if model files exist
dir ml\
```
Should show: `model.pkl`, `scaler.pkl` (if applicable)

### Test Database Connection
```bash
# Through the API
curl http://localhost:8000/test-db

# Response should have status="connected"
```

### Test Routes Registration
```python
# In Python terminal
from main import app
from fastapi.openapi.utils import get_openapi

for route in app.routes:
    print(f"{route.methods} {route.path}")
```

---

## **5. Manual Testing with Python**

### Example: Test with requests library
```python
import requests

BASE_URL = "http://localhost:8000"

# Test health
response = requests.get(f"{BASE_URL}/health")
print(response.json())

# Test with user data (adjust endpoint)
user_data = {
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

# Test calorie prediction (adjust route if different)
response = requests.post(
    f"{BASE_URL}/predict-calories",
    json=user_data
)
print(response.json())
```

---

## **6. Troubleshooting**

### Issue: "ModuleNotFoundError: No module named 'ml'"
**Solution:** Make sure you're in the backend directory and have `__init__.py` files:
```bash
ls ml/__init__.py
```

### Issue: "Model not found" or FileNotFoundError
**Solution:** Check if `model.pkl` exists:
```bash
dir ml\
```
If missing, run `train_model.py` in Google Colab first to generate the model.

### Issue: "Connection error to database"
**Solution:** Check `.env` file has correct Supabase credentials:
```bash
# In .env
SUPABASE_URL=your_url
SUPABASE_KEY=your_key
```

### Issue: Endpoints not showing in API docs
**Solution:** Make sure all routers are registered in `main.py`:
```python
app.include_router(onboarding_router)
app.include_router(health_data_router)
app.include_router(tracking_router)
```

---

## **7. What Endpoints Should Exist**

Based on your structure, you should have:

### Health Routes (`/health`)
- `POST /health/biometrics` - Save biometric data
- `GET /health/...` - Retrieve health data

### Tracking Routes (`/tracking`)
- Likely meal/food tracking endpoints

### Onboarding Routes (`/onboarding`)
- User setup and profile creation

### Built-in Routes
- `GET /` - Root (status check)
- `GET /health` - Health check
- `GET /test-db` - Database connection test
- `GET /docs` - API documentation
- `GET /openapi.json` - OpenAPI spec

---

## **8. Full Test Checklist**

- [ ] Backend server starts without errors
- [ ] `/health` endpoint returns `{"status": "healthy"}`
- [ ] `/test-db` shows data or connection message
- [ ] API docs page loads at `/docs`
- [ ] ML model loads successfully in `test_model_direct.py`
- [ ] Predictions are in reasonable range (1500-3500 kcal typical)
- [ ] All routes appear in OpenAPI spec
- [ ] No console errors during requests

---

## **9. Performance & Load Testing**

For simple load testing (optional):
```bash
pip install locust
# Create locustfile.py and run load tests
```

---

## **10. Next Steps**

If tests pass:
1. ✅ Your backend is working
2. ✅ Your ML model is loaded and functional
3. ✅ Database connection is verified
4. → Ready for frontend integration
5. → Ready for deployment

If tests fail:
1. Check terminal output for specific error messages
2. Verify all files are in correct locations
3. Ensure `.env` is properly configured
4. Check `requirements.txt` packages are installed

---

**Happy Testing! 🚀**
