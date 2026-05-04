-- 09_stats_and_explain.sql
-- for statistics and explain analyze

ANALYZE;

EXPLAIN ANALYZE
SELECT
    l.id,
    l.title,
    l.price,
    l.currency,
    l.status,
    c.name AS category_name,
    lc.label AS condition_label,
    p.username AS seller_username
FROM listings l
JOIN categories c ON c.id = l.category_id
JOIN listing_conditions lc ON lc.id = l.condition_id
JOIN profiles p ON p.id = l.seller_id
WHERE l.status = 'active'
ORDER BY l.created_at DESC;