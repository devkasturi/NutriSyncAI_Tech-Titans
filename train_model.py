# =============================================================================
# NutriSync AI — train_model.py  (Final Version)
# Google Colab — Outputs: nutrisync_v1.pkl + scaler.pkl
# =============================================================================
# Run this first if packages are missing:
# !pip install xgboost scikit-learn pandas numpy --quiet

import pandas as pd
import numpy as np
import pickle
import os
import warnings
warnings.filterwarnings("ignore")

from xgboost import XGBRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.metrics import mean_absolute_error, r2_score, mean_squared_error

np.random.seed(42)

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Upload CSVs
# ─────────────────────────────────────────────────────────────────────────────
from google.colab import files

print("📂 Please upload exercise.csv and calories.csv")
uploaded = files.upload()   # file picker appears — select BOTH files

# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — Load & Merge
# ─────────────────────────────────────────────────────────────────────────────
print("\n📂 Loading & merging datasets...")

exercise_df = pd.read_csv("exercise.csv")
calories_df = pd.read_csv("calories.csv")

df = pd.merge(exercise_df, calories_df, on="User_ID")
df.dropna(inplace=True)
df.drop_duplicates(inplace=True)

print(f"   Shape after merge & clean : {df.shape}")
print(f"   Columns                   : {list(df.columns)}")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Feature Engineering
# ─────────────────────────────────────────────────────────────────────────────
print("\n🔬 Engineering features...")

# BMI from Height (cm) and Weight (kg)
df["BMI"] = (df["Weight"] / ((df["Height"] / 100) ** 2)).round(2)

# Synthetic HRV — mirrors the formula used in Flutter PPG computation
# HRV = 100 - (0.5 × Age) - (0.3 × Heart_Rate) + Gaussian noise
hrv_raw = (
    100
    - (0.5 * df["Age"])
    - (0.3 * df["Heart_Rate"])
    + np.random.normal(0, 6, size=len(df))
)
df["HRV"]         = hrv_raw.clip(15, 80).round(2)
df["Is_Stressed"] = (df["HRV"] < 40).astype(int)

print(f"   HRV range  : {df['HRV'].min():.1f} – {df['HRV'].max():.1f} ms")
print(f"   Stressed % : {df['Is_Stressed'].mean()*100:.1f}%  "
      f"({df['Is_Stressed'].sum()} / {len(df)} samples)")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — Synthetic Goal (biologically plausible distribution)
# ─────────────────────────────────────────────────────────────────────────────
def assign_goal(bmi: float) -> str:
    if bmi >= 27.5:
        # Overweight — likely wants weight loss
        return np.random.choice(
            ["Weight_Loss", "Maintenance", "Muscle_Gain"], p=[0.65, 0.25, 0.10]
        )
    elif bmi <= 20.0:
        # Underweight — likely wants muscle gain
        return np.random.choice(
            ["Muscle_Gain", "Maintenance", "Weight_Loss"], p=[0.60, 0.30, 0.10]
        )
    else:
        # Normal BMI — balanced distribution
        return np.random.choice(
            ["Maintenance", "Weight_Loss", "Muscle_Gain"], p=[0.45, 0.30, 0.25]
        )

df["Goal"] = df["BMI"].apply(assign_goal)

# Adjust calorie target based on goal
GOAL_MODIFIERS = {"Weight_Loss": 0.88, "Maintenance": 1.00, "Muscle_Gain": 1.15}
df["Calories_Adjusted"] = df.apply(
    lambda r: r["Calories"] * GOAL_MODIFIERS[r["Goal"]], axis=1
).round(2)

print(f"\n   Goal distribution:\n{df['Goal'].value_counts().to_string()}")
print(f"\n   Calorie target by goal (mean):")
print(df.groupby("Goal")[["Calories", "Calories_Adjusted"]].mean().round(1).to_string())

# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 — Encode Categoricals
# ─────────────────────────────────────────────────────────────────────────────
print("\n🔡 Encoding categoricals...")

gender_encoder = LabelEncoder()
df["Gender_enc"] = gender_encoder.fit_transform(df["Gender"])  # female=0, male=1

GOAL_ORDER   = {"Weight_Loss": 0, "Maintenance": 1, "Muscle_Gain": 2}
df["Goal_enc"] = df["Goal"].map(GOAL_ORDER)

print(f"   Gender : {dict(zip(gender_encoder.classes_, gender_encoder.transform(gender_encoder.classes_)))}")
print(f"   Goal   : {GOAL_ORDER}")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 6 — Features & Target
# ─────────────────────────────────────────────────────────────────────────────
# These MUST match exactly what the Flutter app sends to FastAPI
FEATURES = [
    "Gender_enc",    # 0=Female, 1=Male        — from user profile
    "Age",           # years                   — from user profile
    "BMI",           # kg/m²                   — derived Height + Weight
    "Heart_Rate",    # bpm                     — from PPG
    "HRV",           # RMSSD ms                — from PPG
    "Goal_enc",      # 0/1/2                   — from questionnaire
    "Duration",      # minutes                 — from questionnaire
    "Is_Stressed",   # 0 or 1 (HRV < 40)      — derived
]
TARGET = "Calories_Adjusted"

X = df[FEATURES]
y = df[TARGET]

print(f"\n✅ Feature matrix : {X.shape}")
print(f"   Features      : {FEATURES}")
print(f"   Target        : {TARGET}")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 7 — Train/Test Split + Normalise
# ─────────────────────────────────────────────────────────────────────────────
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.20, random_state=42
)

scaler     = StandardScaler()
X_train_sc = pd.DataFrame(scaler.fit_transform(X_train), columns=FEATURES)
X_test_sc  = pd.DataFrame(scaler.transform(X_test),      columns=FEATURES)

print(f"\n   Train : {X_train_sc.shape}  |  Test : {X_test_sc.shape}")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 8 — Train XGBoost
# ─────────────────────────────────────────────────────────────────────────────
print("\n🚀 Training XGBoost Regressor...")

model = XGBRegressor(
    n_estimators          = 1000,
    learning_rate         = 0.05,
    max_depth             = 6,
    min_child_weight      = 3,
    subsample             = 0.85,
    colsample_bytree      = 0.80,
    reg_alpha             = 0.1,
    reg_lambda            = 1.5,
    gamma                 = 0.1,
    early_stopping_rounds = 50,
    eval_metric           = "rmse",
    random_state          = 42,
    n_jobs                = -1,
    verbosity             = 0,
)

model.fit(
    X_train_sc, y_train,
    eval_set = [(X_test_sc, y_test)],
    verbose  = 100,
)

print(f"\n   Best iteration : {model.best_iteration}")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 9 — Evaluate
# ─────────────────────────────────────────────────────────────────────────────
preds = model.predict(X_test_sc)
mae   = mean_absolute_error(y_test, preds)
rmse  = mean_squared_error(y_test, preds) ** 0.5
r2    = r2_score(y_test, preds)

print(f"\n📊 Evaluation Results")
print(f"   MAE  : {mae:.2f} kcal  ← avg prediction error")
print(f"   RMSE : {rmse:.2f} kcal")
print(f"   R²   : {r2:.4f}        ← 1.0 = perfect")

fi = pd.Series(model.feature_importances_, index=FEATURES).sort_values(ascending=False)
print(f"\n🔑 Feature Importances:\n{fi.round(4).to_string()}")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 10 — Export nutrisync_v1.pkl + scaler.pkl
# ─────────────────────────────────────────────────────────────────────────────
model_bundle = {
    "model"               : model,
    "feature_names"       : FEATURES,
    "gender_encoder"      : gender_encoder,
    "goal_order"          : GOAL_ORDER,
    "goal_modifiers"      : GOAL_MODIFIERS,
    "hrv_stress_threshold": 40,
    "model_version"       : "nutrisync_v1",
    "training_r2"         : round(r2, 4),
    "training_mae"        : round(mae, 2),
}

scaler_bundle = {
    "scaler"       : scaler,
    "feature_names": FEATURES,
}

with open("nutrisync_v1.pkl", "wb") as f:
    pickle.dump(model_bundle, f)

with open("scaler.pkl", "wb") as f:
    pickle.dump(scaler_bundle, f)

print(f"\n✅ nutrisync_v1.pkl : {os.path.getsize('nutrisync_v1.pkl') / 1024:.1f} KB")
print(f"✅ scaler.pkl       : {os.path.getsize('scaler.pkl') / 1024:.1f} KB")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 11 — Sanity Tests (simulated app inputs)
# ─────────────────────────────────────────────────────────────────────────────
print("\n🧪 Sanity Tests — Simulated App Inputs")
print("=" * 55)

GOAL_LABELS          = {0: "Weight Loss", 1: "Maintenance", 2: "Muscle Gain"}
ACTIVITY_MULTIPLIERS = {1: 1.2, 2: 1.375, 3: 1.55, 4: 1.725, 5: 1.9}

test_cases = [
    {
        "label": "22yr Male | BMI 22 | Weight Loss | Relaxed PPG",
        "Gender_enc": 1, "Age": 22,  "BMI": 22.0,
        "Heart_Rate": 118, "HRV": 55.0, "Goal_enc": 0,
        "Duration": 45, "Is_Stressed": 0, "activity_level": 3,
    },
    {
        "label": "35yr Female | BMI 28 | Muscle Gain | Stressed PPG",
        "Gender_enc": 0, "Age": 35, "BMI": 28.0,
        "Heart_Rate": 152, "HRV": 26.0, "Goal_enc": 2,
        "Duration": 60, "Is_Stressed": 1, "activity_level": 4,
    },
    {
        "label": "50yr Male | BMI 30 | Maintenance | Neutral",
        "Gender_enc": 1, "Age": 50, "BMI": 30.0,
        "Heart_Rate": 95, "HRV": 42.0, "Goal_enc": 1,
        "Duration": 30, "Is_Stressed": 0, "activity_level": 2,
    },
]

for case in test_cases:
    label          = case.pop("label")
    activity_level = case.pop("activity_level")
    row_df         = pd.DataFrame([case], columns=FEATURES)
    row_sc         = pd.DataFrame(scaler.transform(row_df), columns=FEATURES)
    base_cals      = model.predict(row_sc)[0]
    tdee_cals      = base_cals * ACTIVITY_MULTIPLIERS[activity_level]
    stress         = "🔴 Stressed" if case["Is_Stressed"] else "🟢 Relaxed"
    goal_name      = GOAL_LABELS[case["Goal_enc"]]

    print(f"\n   {label}")
    print(f"   Goal : {goal_name}  |  State : {stress}")
    print(f"   Base calories  → {base_cals:.1f} kcal")
    print(f"   TDEE (×{ACTIVITY_MULTIPLIERS[activity_level]}) → {tdee_cals:.1f} kcal  ← this goes to Gemini")

print("\n" + "=" * 55)
print("🎉 Done!")
print("   In the Colab sidebar (📁), right-click each file → Download:")
print("   • nutrisync_v1.pkl")
print("   • scaler.pkl")
print("   Place both in your nutrisync_backend/ folder next to main.py")
