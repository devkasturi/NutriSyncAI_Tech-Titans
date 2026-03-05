from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class BiometricReading(BaseModel):
    source: str = Field(..., pattern="^(ppg|health_connect|wearable|manual)$")
    heart_rate_bpm: Optional[float] = Field(default=None, ge=30, le=250)
    hrv_ms: Optional[float] = Field(default=None, ge=0, le=500)
    spo2: Optional[float] = Field(default=None, ge=50, le=100)
    steps: Optional[int] = Field(default=None, ge=0)
    calories_burned: Optional[float] = Field(default=None, ge=0)
    sleep_hours: Optional[float] = Field(default=None, ge=0, le=24)
    sleep_quality: Optional[str] = Field(
        default=None,
        pattern="^(deep|light|restless|mixed)$"
    )

class SelfReportCreate(BaseModel):
    energy_level: int = Field(..., ge=1, le=5)
    mood: str = Field(
        ...,
        pattern="^(happy|calm|neutral|stressed|anxious|tired|sad)$"
    )
    sleep_rating: int = Field(..., ge=1, le=5)
    stress_level: int = Field(..., ge=1, le=5)
    notes: Optional[str] = None

class SleepSession(BaseModel):
    start_time: str  # ISO format
    end_time: str
    total_hours: float = Field(..., ge=0, le=24)
    deep_sleep_hours: Optional[float] = Field(default=None, ge=0)
    light_sleep_hours: Optional[float] = Field(default=None, ge=0)
    rem_sleep_hours: Optional[float] = Field(default=None, ge=0)
    awake_hours: Optional[float] = Field(default=None, ge=0)

class HealthConnectSync(BaseModel):
    """
    Batch payload that Flutter sends after reading Health Connect.
    All fields optional because not every device provides every metric.
    Flutter collects whatever is available and sends it all at once.
    """
    # Activity data (available from phone)
    steps: Optional[int] = Field(default=None, ge=0)
    calories_burned: Optional[float] = Field(default=None, ge=0)
    distance_meters: Optional[float] = Field(default=None, ge=0)
    active_minutes: Optional[int] = Field(default=None, ge=0)

    # Sleep data (basic from phone, detailed from wearable)
    sleep: Optional[SleepSession] = None

    # Heart data (wearable only)
    heart_rate_samples: Optional[List[float]] = None  # multiple readings
    hrv_samples: Optional[List[float]] = None
    spo2: Optional[float] = Field(default=None, ge=50, le=100)

    # Metadata
    sync_date: str  # "2026-03-05" — which day this data is for
    has_wearable: bool = False  # tells backend what tier this user is