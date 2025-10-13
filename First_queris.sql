select * from order_items;

SELECT * FROM products;

SELECT * FROM reviews;

SELECT * FROM customers;

SELECT * FROM orders;

-- How many distinct order statuses are there in the orders table?
SELECT order_status 

FROM orders
GROUP BY order_status;


-- 1.	Get all orders that are 'Completed'.
SELECT * FROM orders
WHERE order_status = 'Delivered' or order_status = 'Shipped';


-- 2.   Calculate total revenue (quantity * unit_price) for each product.
select 
    quantity, unit_price, (quantity*unit_price) as total_revenue
from order_items;


--3.   	Count how many orders each customer has placed.
SELECT
    customer_id, count(customer_id) as orders_per_customer
from orders
group by 1
order by 2 desc;


--4     Calculate the average total amount spent per customer.
WITH order_totals AS (
    SELECT 
        o.order_id,
        o.customer_id,
        SUM(i.quantity * i.unit_price) AS order_total
    FROM orders AS o
    JOIN order_items AS i
        ON o.order_id = i.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT 
    customer_id,
    ROUND(AVG(order_total), 2) AS avg_total_spent
FROM order_totals
GROUP BY customer_id
ORDER BY avg_total_spent DESC;



--5		Count the number of orders for each country.
select 
	c.country, 
	count(distinct c.customer_id) as unique_customers,
	count(c.country) as order_per_country
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1
order by 3 desc; -- On this query i found how many unique customers are in every country too


--6		Find the average rating for each product.
with total_rating as 
(
	select 
		product_id,
		sum(rating) as total_rating,
		count(rating) as rating_count
	from reviews
	group by 1
)
select 
	product_id,
	ROUND(total_rating::numeric / rating_count, 2) AS avg_rating_per_product
from total_rating
order by 2 desc;

