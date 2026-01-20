SELECT COUNT(id)
	FROM product_catalog
WHERE parent = 0
GROUP BY parent;