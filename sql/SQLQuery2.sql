SELECT *
FROM staging_order_detail
;

SELECT *
FROM staging_customer_detail;

SELECT std.id,
		std.customer_id,
		scd.registered_date,
		std.qty_ordered
FROM staging_order_detail std
LEFT JOIN staging_customer_detail scd
ON std.customer_id=scd.id;


/*
1. In 2021, in which month was the highest total transaction value (after_discount) recorded? Use is_valid = 1 to filter transactions. Source: order_detail
2. In 2022, which category generated the highest transaction value? Use is_valid = 1 to filter transactions. Source: order_detail, sku_detail
3. Compare transaction values for each category in 2021 and 2022. Identify categories with increased or decreased transaction values from 2021 to 2022. Use is_valid = 1 to filter transactions. Source: order_detail, sku_detail
4. Show the top 5 most popular payment methods used in 2022 (based on total unique orders). Use is_valid = 1 to filter transactions. Source: order_detail, payment_method
5. Rank the following 5 products by transaction value: Samsung, Apple, Sony, Huawei, Lenovo. Use is_valid = 1 to filter transactions. Source: order_detail, sku_detail
*/



-- 1. In 2021, in which month was the highest total transaction value (after_discount) recorded?

SELECT MONTH(order_date) AS month_num,
		SUM(after_discount) AS total_after_discount
FROM staging_order_detail
WHERE YEAR(order_date) = 2021 AND is_valid = 1
GROUP BY MONTH(order_date)
ORDER BY SUM(after_discount) DESC;

-- 2. In 2022, which category generated the highest transaction value?

SELECT sd.category,
		SUM(od.after_discount) AS total_transaction
FROM staging_order_detail od
LEFT JOIN staging_sku_detail sd
ON od.sku_id=sd.id
WHERE YEAR(order_date) = 2022 AND is_valid = 1
GROUP BY sd.category
ORDER BY SUM(od.after_discount) DESC

-- 3. Compare transaction values for each category in 2021 and 2022. 
-- Identify categories with increased or decreased transaction values from 2021 to 2022.
WITH transaction_2022 AS 
(
SELECT sd.category,
		SUM(od.after_discount) AS total_transaction_2022
FROM staging_order_detail od
LEFT JOIN staging_sku_detail sd
ON od.sku_id=sd.id
WHERE YEAR(order_date) = 2022 AND is_valid = 1
GROUP BY sd.category
), transaction_2021 AS
(
SELECT sd.category,
		SUM(od.after_discount) AS total_transaction_2021
FROM staging_order_detail od
LEFT JOIN staging_sku_detail sd
ON od.sku_id=sd.id
WHERE YEAR(order_date) = 2021 AND is_valid = 1
GROUP BY sd.category
)
SELECT t1.category,
		t1.total_transaction_2021,
		t2.total_transaction_2022,
		(t2.total_transaction_2022 - t1.total_transaction_2021) AS difference_value,
		CASE
			WHEN t2.total_transaction_2022 - t1.total_transaction_2021 > 0 THEN 'Increased'
			ELSE 'Decreased'
		END AS status
FROM transaction_2021 t1
LEFT JOIN transaction_2022 t2
ON t1.category=t2.category


-- 4. Show the top 5 most popular payment methods used in 2022 (based on total unique orders)
SELECT TOP 5 pd.payment_method,
		COUNT(DISTINCT od.id) AS total_order
FROM staging_order_detail od
LEFT JOIN staging_payment_detail pd
ON od.payment_id=pd.id
WHERE YEAR(order_date) = 2022 AND is_valid = 1
GROUP BY pd.payment_method
ORDER BY SUM(od.qty_ordered) DESC


-- 5.Rank the following 5 products by transaction value: Samsung, Apple, Sony, Huawei, Lenovo.

WITH product_sales AS
(
SELECT 	CASE
			WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'samsung'
			WHEN LOWER(sd.sku_name) LIKE '%apple%' 
			OR LOWER(sd.sku_name) LIKE '%iphone%' 
			OR LOWER(sd.sku_name) LIKE '%macbook%' THEN 'apple'
			WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'sony'
			WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'huawei'
			WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'lenovo'
			ELSE 'other'
		END AS product_name,
		SUM(od.after_discount) AS transaction_value
FROM staging_order_detail od
LEFT JOIN staging_sku_detail sd
ON od.sku_id=sd.id
WHERE od.is_valid = 1
GROUP BY CASE
			WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'samsung'
			WHEN LOWER(sd.sku_name) LIKE '%apple%' 
			OR LOWER(sd.sku_name) LIKE '%iphone%' 
			OR LOWER(sd.sku_name) LIKE '%macbook%' THEN 'apple'
			WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'sony'
			WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'huawei'
			WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'lenovo'
			ELSE 'other'
		END
)
SELECT *
FROM product_sales
WHERE product_name <> 'other'
ORDER BY transaction_value DESC