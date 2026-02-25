-- Gini Coefficient (All Users)
WITH revenue_per_user AS (
    SELECT 
        u.user_id,
        COALESCE(SUM(p.price_usd), 0) AS revenue
    FROM users u
    LEFT JOIN purchases p 
        ON u.user_id = p.user_id
    GROUP BY u.user_id
),
ordered AS (
    SELECT 
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue) AS rn,
        COUNT(*) OVER () AS n,
        SUM(revenue) OVER () AS total_revenue
    FROM revenue_per_user
),
gini_calc AS (
    SELECT 
        SUM((2 * rn - n - 1) * revenue) AS numerator,
        MAX(n) AS n,
        MAX(total_revenue) AS total_revenue
    FROM ordered
)
SELECT 
    ROUND(
        numerator::numeric / (n * total_revenue),
        4
    ) AS gini_all_users
FROM gini_calc;

-- Gini Coefficient (Payers Only)
WITH revenue_per_user AS (
    SELECT 
        user_id,
        SUM(price_usd) AS revenue
    FROM purchases
    GROUP BY user_id
),
ordered AS (
    SELECT 
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue) AS rn,
        COUNT(*) OVER () AS n,
        SUM(revenue) OVER () AS total_revenue
    FROM revenue_per_user
),
gini_calc AS (
    SELECT 
        SUM((2 * rn - n - 1) * revenue) AS numerator,
        MAX(n) AS n,
        MAX(total_revenue) AS total_revenue
    FROM ordered
)
SELECT 
    ROUND(
        numerator::numeric / (n * total_revenue),
        4
    ) AS gini_payers_only
FROM gini_calc;