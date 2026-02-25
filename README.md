# Gaming Monetization Fragility  
Revenue Concentration & Retention Risk Analysis in a Simulated F2P Game

---

## 1️⃣ Business Problem

Free-to-play mobile games often rely disproportionately on high-value players ("whales") for revenue. While this model can generate strong short-term returns, it may introduce structural fragility if revenue concentration and retention dynamics are not balanced.

This project evaluates how monetization inequality and retention decay interact to affect long-term revenue stability.

---

## 2️⃣ Objective

To simulate a production-style F2P game dataset and analyze:

- Revenue concentration  
- Whale dependency  
- Retention decay  
- Revenue timing distribution  
- Monetization fragility under churn scenarios  

All analysis was performed using PostgreSQL with advanced SQL (CTEs, window functions, cumulative analysis).

---

## 3️⃣ Dataset Design

A synthetic dataset of 10,000 users was generated using Python with behavioral archetypes:

- Non-Spender (65%)  
- Minnow (22%)  
- Dolphin (10%)  
- Whale (3%)  

Features simulated:

- Exponential retention decay by archetype  
- Session-level engagement tracking  
- Archetype-based purchase intensity  
- 30-day monetization window  

Tables created in PostgreSQL:

- users  
- sessions  
- purchases  

---

## 4️⃣ Key Metrics Computed (SQL-Based)

Using PostgreSQL:

- Total Revenue  
- Revenue per User  
- Top 1% Revenue Share  
- Gini Coefficient (All Users & Paying Users)  
- Revenue Contribution by Archetype  
- Whale Churn Sensitivity Simulation  
- D1 / D7 Retention  
- Cumulative Revenue Curve (LTV by day_since_install)  

Advanced SQL techniques used:

- CTEs  
- Window Functions (ROW_NUMBER, SUM OVER)  
- Running totals  
- Ranking  
- Revenue concentration modeling  

---

## 5️⃣ Key Findings

- **Top 1% of users generated 42.02% of total revenue**
- **Whales (3% of users) generated 85.08% of total revenue**
- Gini Coefficient (All Users): **0.9547**
- Gini Coefficient (Payers Only): **0.8722**
- D7 retention was near zero for non-whale segments
- 50% of total revenue accumulated by **Day 14**
- 20% reduction in whale revenue caused ~17% total revenue drop

---

## 6️⃣ Business Interpretation

The simulated economy demonstrates high structural monetization fragility:

- Revenue is heavily dependent on whale retention  
- Mid-tier monetization (dolphins/minnows) provides limited revenue buffering  
- Long-term revenue survival is directly tied to high-value player stability  
- Churn among whales would result in disproportionate revenue contraction  

This highlights the importance of diversified monetization strategies and stronger mid-tier engagement reinforcement in F2P game economies.

---

## 7️⃣ Tech Stack

- Python (Data Simulation)  
- PostgreSQL (Relational Modeling & Advanced SQL)  
- pgAdmin (Database Management)  

---

## 8️⃣ Project Structure
gaming_monetization_fragility/
│
├── data_raw/ # Simulated raw datasets
├── src/ # Python data generation scripts
├── sql/ # Analytical SQL queries
├── README.md # Project documentation


## 9️⃣ Skills Demonstrated

- Advanced SQL (CTEs, Window Functions, Running Totals)  
- Revenue Concentration Modeling  
- Retention Analysis  
- Synthetic Data Simulation  
- Monetization Sensitivity Testing  
- Business Interpretation of Analytical Results  