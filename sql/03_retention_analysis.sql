-- Overall D1 / D7 / D30 Retention
SELECT
    ROUND(
        COUNT(DISTINCT user_id) FILTER (WHERE day_since_install = 1)::numeric 
        / (SELECT COUNT(*) FROM users) * 100,
        2
    ) AS d1_retention_percent,

    ROUND(
        COUNT(DISTINCT user_id) FILTER (WHERE day_since_install = 7)::numeric 
        / (SELECT COUNT(*) FROM users) * 100,
        2
    ) AS d7_retention_percent,

    ROUND(
        COUNT(DISTINCT user_id) FILTER (WHERE day_since_install = 30)::numeric 
        / (SELECT COUNT(*) FROM users) * 100,
        2
    ) AS d30_retention_percent
FROM sessions;

-- D7 Retention by Archetype
WITH archetype_counts AS (
    SELECT 
        archetype,
        COUNT(*) AS total_users
    FROM users
    GROUP BY archetype
),
d7_counts AS (
    SELECT 
        u.archetype,
        COUNT(DISTINCT s.user_id) AS retained_users
    FROM users u
    JOIN sessions s
        ON u.user_id = s.user_id
    WHERE s.day_since_install = 7
    GROUP BY u.archetype
)
SELECT 
    a.archetype,
    ROUND(
        COALESCE(d.retained_users, 0)::numeric 
        / a.total_users * 100,
        2
    ) AS d7_retention_percent
FROM archetype_counts a
LEFT JOIN d7_counts d
    ON a.archetype = d.archetype
ORDER BY a.archetype;