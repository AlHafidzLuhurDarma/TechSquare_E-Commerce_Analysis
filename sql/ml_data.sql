/*Customer Segmentation data:
customer_id, total_spend(sum_revenue), total_unit, range between register and 1st day order, 
range of first and last day
*/


WITH selected_data AS
(
SELECT esd.customer_id,
		cd.registered_date,
		esd.order_date,
		esd.qty_ordered,
		esd.after_discount
FROM ecommerce_sales_data esd
LEFT JOIN staging_customer_detail cd
ON esd.customer_id=cd.id
WHERE esd.is_valid=1
)
SELECT customer_id,
		DATEDIFF(DAY,MIN(registered_date), MIN(order_date)) AS register_to_order,
		DATEDIFF(DAY,MIN(order_date), MAX(order_date)) AS first_to_last_order,
		SUM(qty_ordered) AS total_unit,
		SUM(after_discount) AS total_spent
INTO [ml_data]
FROM selected_data
GROUP BY customer_id

/*
1. Guest checkout / soft identity (MOST LIKELY)
This is very common in e-commerce.
Flow:
Customer orders without registering (guest checkout)
Later:
- creates an account or customer service creates it
Orders get retroactively linked to the customer_id

Result: Orders exist before registered_date.

This is not a marketing miracle, just normal UX behavior.

2. Account created after first transaction (voucher / offline flows)
I have things like:
marketingexpense
productcredit
voucher
cashatdoorstep
interbanking

These strongly suggest:
manual entries
marketing campaigns
internal credits
reconciliation after the fact

Example:
Customer receives voucher
Order recorded first
Account formalized later

Again: order before registration

3. Data entry or migration issue
Also very plausible:
historical data imported
registered_date filled later
default dates / wrong timezone
backfilled customer table

Classic symptom:
large negative values (-150, -248 days)
This is data ops, not marketing.
*/

SELECT *
FROM ml_data