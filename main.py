from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import supabase_admin
from routes.onboarding import router as onboarding_router
from routes.health_data import router as health_data_router
from routes.tracking import router as tracking_router

app = FastAPI(
    title="NutriSync AI",
    description="Intelligent Nutrition Operating System API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register route groups — MUST come AFTER app is created
app.include_router(onboarding_router)
app.include_router(health_data_router)
app.include_router(tracking_router)

@app.get("/")
def root():
    return {"message": "NutriSync AI is running"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/test-db")
def test_database():
    try:
        response = supabase_admin.table("profiles").select("*").limit(1).execute()
        return {"status": "connected", "data": response.data}
    except Exception as e:
        return {"status": "error", "detail": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)