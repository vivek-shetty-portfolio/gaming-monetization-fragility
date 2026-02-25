
-- Total Revenue
SELECT SUM(price_usd) AS total_revenue
FROM purchases;

-- Revenue Per User
SELECT 
    user_id,
    SUM(price_usd) AS total_revenue
FROM purchases
GROUP BY user_id
ORDER BY total_revenue DESC;

-- Top 1% Revenue Share (All Users)
WITH revenue_per_user AS (
    SELECT 
        u.user_id,
        COALESCE(SUM(p.price_usd), 0) AS total_revenue
    FROM users u
    LEFT JOIN purchases p 
        ON u.user_id = p.user_id
    GROUP BY u.user_id
),
ranked_users AS (
    SELECT 
        user_id,
        total_revenue,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        COUNT(*) OVER () AS total_users
    FROM revenue_per_user
)
SELECT 
    ROUND(
        SUM(total_revenue) 
        / (SELECT SUM(price_usd) FROM purchases) * 100,
        2
    ) AS top_1_share_percent
FROM ranked_users
WHERE revenue_rank <= total_users * 0.01;

-- Revenue Contribution by Archetype
SELECT
    u.archetype,
    ROUND(SUM(p.price_usd), 2) AS total_revenue,
    ROUND(
        SUM(p.price_usd) 
        / (SELECT SUM(price_usd) FROM purchases) * 100,
        2
    ) AS revenue_share_percent
FROM users u
JOIN purchases p
    ON u.user_id = p.user_id
GROUP BY u.archetype
ORDER BY revenue_share_percent DESC;

-- Cumulative Revenue Curve
WITH revenue_by_day AS (
    SELECT 
        day_since_install,
        SUM(price_usd) AS revenue
    FROM purchases
    GROUP BY day_since_install
),
ordered_days AS (
    SELECT 
        day_since_install,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (
            ORDER BY day_since_install
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM revenue_by_day
)
SELECT 
    day_since_install,
    ROUND(
        cumulative_revenue / total_revenue * 100,
        2
    ) AS cumulative_revenue_percent
FROM ordered_days
ORDER BY day_since_install;