/*
Null and Duplicates
*/

-- Null

-- Order Detail
SELECT SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_null,
		SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_null,
		SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_null,
		SUM(CASE WHEN sku_id IS NULL THEN 1 ELSE 0 END) AS sku_id_null,
		SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_null,
		SUM(CASE WHEN qty_ordered IS NULL THEN 1 ELSE 0 END) AS qty_ordered_null,
		SUM(CASE WHEN before_discount IS NULL THEN 1 ELSE 0 END) AS before_discount_null,
		SUM(CASE WHEN discount_amount IS NULL THEN 1 ELSE 0 END) AS discount_amount_null,
		SUM(CASE WHEN after_discount IS NULL THEN 1 ELSE 0 END) AS after_discount_null,
		SUM(CASE WHEN is_gross IS NULL THEN 1 ELSE 0 END) AS is_gross_null,
		SUM(CASE WHEN is_valid IS NULL THEN 1 ELSE 0 END) AS is_valid_null,
		SUM(CASE WHEN is_net IS NULL THEN 1 ELSE 0 END) AS is_net,
		SUM(CASE WHEN payment_id IS NULL THEN 1 ELSE 0 END) AS payment_id_null
FROM staging_order_detail

-- Customer Detail
SELECT SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_null,
		SUM(CASE WHEN registered_date IS NULL THEN 1 ELSE 0 END) AS registered_date_null
FROM staging_customer_detail

-- Payment Detail
SELECT SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_null,
		SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS payment_method_null
FROM staging_payment_detail


-- SKU Detail
SELECT SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_null,
		SUM(CASE WHEN sku_name IS NULL THEN 1 ELSE 0 END) AS sku_name_null,
		SUM(CASE WHEN base_price IS NULL THEN 1 ELSE 0 END) AS base_price_null,
		SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) AS cogs_null,
		SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_null
FROM staging_sku_detail



-- Duplicates

-- Order Detail
SELECT id, 
	customer_id,
	order_date, 
	sku_id, 
	price,
	qty_ordered, 
	before_discount,
	discount_amount, 
	after_discount,
	is_gross, 
	is_valid,
	is_net, 
	payment_id, 
	COUNT(*)
FROM staging_order_detail
GROUP BY id,
	customer_id,
	order_date, 
	sku_id, 
	price,
	qty_ordered, 
	before_discount,
	discount_amount, 
	after_discount,
	is_gross, 
	is_valid,
	is_net, 
	payment_id
HAVING COUNT(*) > 1;

-- Customer Detail
SELECT id,
		registered_date,
		COUNT(*)
FROM staging_customer_detail
GROUP BY id,
		registered_date
HAVING COUNT(*) > 1;

-- Payment Detail
SELECT id,
		payment_method,
		COUNT(*)
FROM staging_payment_detail
GROUP BY id,
		payment_method
HAVING COUNT(*) > 1;

-- SKU Detail
SELECT id,
		sku_name,
		base_price,
		cogs,
		category,
		COUNT(*)
FROM staging_sku_detail
GROUP BY id, 
		sku_name,
		base_price,
		cogs,
		category
HAVING COUNT(*) > 1;
