SELECT *
FROM (
	SELECT 
	    c.name as client,
	    COUNT(o.id) as order_count,
	    SUM(oi.count) as total_items,
	    SUM(p.price * oi.count) as total_amount
	FROM clients c
		LEFT JOIN orders o ON c.id = o.client_id
		LEFT JOIN order_items oi ON o.id = oi.order_id
		LEFT JOIN products p ON oi.item = p.id
	GROUP BY c.id, c.name
) t
WHERE total_amount IS NOT NULL
ORDER BY total_amount DESC;