import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import os

# -----------------------------
# Project Path Setup (FIXED)
# -----------------------------
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_RAW_PATH = os.path.join(BASE_DIR, "data_raw")
os.makedirs(DATA_RAW_PATH, exist_ok=True)

# -----------------------------
# Reproducibility
# -----------------------------
np.random.seed(42)
random.seed(42)

NUM_USERS = 10000

# -----------------------------
# User Archetypes
# -----------------------------
archetypes = {
    "non_spender": 0.65,
    "minnow": 0.22,
    "dolphin": 0.10,
    "whale": 0.03
}

def assign_archetype():
    return np.random.choice(
        list(archetypes.keys()),
        p=list(archetypes.values())
    )

# -----------------------------
# Generate Users
# -----------------------------
def generate_users():
    users = []
    start_date = datetime(2024, 1, 1)

    for user_id in range(1, NUM_USERS + 1):
        install_date = start_date + timedelta(days=np.random.randint(0, 90))
        
        users.append({
            "user_id": user_id,
            "install_date": install_date,
            "country": random.choice(["US", "IN", "UK", "CA", "AU"]),
            "platform": random.choice(["iOS", "Android"]),
            "acquisition_channel": random.choice(["Organic", "Facebook Ads", "Google Ads", "TikTok"]),
            "device_tier": random.choice(["low", "mid", "high"]),
            "archetype": assign_archetype()
        })

    df = pd.DataFrame(users)
    df.to_csv(os.path.join(DATA_RAW_PATH, "users.csv"), index=False)

    print("Users generated successfully!")
    print("Shape:", df.shape)

# -----------------------------
# Retention Model
# -----------------------------
retention_lambda = {
    "non_spender": 0.9,
    "minnow": 0.5,
    "dolphin": 0.25,
    "whale": 0.15
}

def generate_sessions(users_df):
    sessions = []
    session_id = 1

    for _, row in users_df.iterrows():
        user_id = row["user_id"]
        install_date = pd.to_datetime(row["install_date"])
        archetype = row["archetype"]

        lam = retention_lambda[archetype]

        for day in range(30):
            active_probability = np.exp(-lam * day)

            if np.random.rand() < active_probability:
                num_sessions = np.random.randint(1, 4)

                for _ in range(num_sessions):
                    session_start = install_date + timedelta(
                        days=day,
                        hours=np.random.randint(0, 24),
                        minutes=np.random.randint(0, 60)
                    )

                    session_length = np.random.randint(5, 60)

                    sessions.append({
                        "session_id": session_id,
                        "user_id": user_id,
                        "session_start": session_start,
                        "session_end": session_start + timedelta(minutes=session_length),
                        "day_since_install": day
                    })

                    session_id += 1
            else:
                break

    sessions_df = pd.DataFrame(sessions)
    sessions_df.to_csv(os.path.join(DATA_RAW_PATH, "sessions.csv"), index=False)

    print("Sessions generated successfully!")
    print("Shape:", sessions_df.shape)

# -----------------------------
# Purchase Simulation
# -----------------------------
purchase_behavior = {
    "non_spender": (0, 0),
    "minnow": (1, 3),
    "dolphin": (3, 10),
    "whale": (10, 50)
}

def generate_purchases(users_df):
    purchases = []
    purchase_id = 1

    for _, row in users_df.iterrows():
        user_id = row["user_id"]
        archetype = row["archetype"]
        install_date = pd.to_datetime(row["install_date"])

        min_p, max_p = purchase_behavior[archetype]

        if max_p == 0:
            continue

        num_purchases = np.random.randint(min_p, max_p + 1)

        for _ in range(num_purchases):
            day = np.random.randint(0, 30)
            purchase_time = install_date + timedelta(days=day)

            if archetype == "minnow":
                price = random.choice([0.99, 1.99, 4.99])
            elif archetype == "dolphin":
                price = random.choice([4.99, 9.99, 19.99])
            else:
                price = random.choice([19.99, 49.99, 99.99])

            purchases.append({
                "purchase_id": purchase_id,
                "user_id": user_id,
                "purchase_timestamp": purchase_time,
                "price_usd": price,
                "day_since_install": day
            })

            purchase_id += 1

    purchases_df = pd.DataFrame(purchases)
    purchases_df.to_csv(os.path.join(DATA_RAW_PATH, "purchases.csv"), index=False)

    print("Purchases generated successfully!")
    print("Shape:", purchases_df.shape)

# -----------------------------
# Run Pipeline
# -----------------------------
if __name__ == "__main__":
    generate_users()
    users_df = pd.read_csv(os.path.join(DATA_RAW_PATH, "users.csv"))
    generate_sessions(users_df)
    generate_purchases(users_df)

    purchases_df = pd.read_csv(os.path.join(DATA_RAW_PATH, "purchases.csv"))

    total_revenue = purchases_df["price_usd"].sum()
    print("Total Revenue:", round(total_revenue, 2))

    revenue_per_user = purchases_df.groupby("user_id")["price_usd"].sum().reset_index()
    revenue_per_user = revenue_per_user.sort_values(by="price_usd", ascending=False)

    print("\nTop 5 Users by Revenue:")
    print(revenue_per_user.head())

    total_users = len(users_df)
    top_1_percent_count = int(total_users * 0.01)

    top_1_revenue = revenue_per_user.head(top_1_percent_count)["price_usd"].sum()
    total_revenue = revenue_per_user["price_usd"].sum()

    top_1_share = (top_1_revenue / total_revenue) * 100

    print(f"\nTop 1% Revenue Share: {round(top_1_share, 2)}%")

    print("\n--- Revenue Sensitivity Simulation ---")

    whale_users = users_df[users_df["archetype"] == "whale"]["user_id"]
    whale_revenue = revenue_per_user[
        revenue_per_user["user_id"].isin(whale_users)
    ]["price_usd"].sum()

    for shock in [0.05, 0.10, 0.20, 0.30, 0.40, 0.50]:
        revenue_loss = whale_revenue * shock
        new_total = total_revenue - revenue_loss
        drop_percent = (revenue_loss / total_revenue) * 100

        print(f"Whale Revenue Reduction: {int(shock*100)}%")
        print(f"Total Revenue Drop: {round(drop_percent,2)}%")
        print("------")