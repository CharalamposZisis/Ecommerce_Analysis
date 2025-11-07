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
		sum(rating) as total_rating,z
		count(rating) as rating_count
	from reviews
	group by 1
)
select 
	product_id,
	ROUND(total_rating::numeric / rating_count, 2) AS avg_rating_per_product
from total_rating
order by 2 desc;



--7		List all orders along with customer first and last names and order status.
select 
	o.order_id,
	o.customer_id,
	o.order_status,
	c.first_name,
	c.last_name
from orders as o
join customers as c
on c.customer_id = o.customer_id
group by 1,2,4,5;


--8		List products with average rating above 4 along with the number of reviews.
select 
	r.product_id,
	p.product_name,
	p.category,
	avg(r.rating) as avg_rating,
	count(r.review_id) as no_of_reviews
from reviews as r
join products as p
on r.product_id = p.product_id
group by 1,2,3
having	avg(r.rating) > 0
order by avg_rating desc;


--9		Get all orders where a review has been submitted (delivered) , including review_text.
select 
	o.order_status,
	r.customer_id,
	r.review_text
from orders as o
join reviews as r
on r.customer_id = o.customer_id
where o.order_status = 'Delivered'
group by 1,2,3



--10	Find the top 5 customers who spent the most in total.
select 
	c.first_name,
	c.last_name,
	c.customer_id,
	(oi.quantity*oi.unit_price) as total_revenue
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
group by 3,4
order by total_revenue desc
LIMIT 5;


--11	Calculate total sales per month.
select
	SUM(oi.quantity * oi.unit_price) AS total_sales,
	extract(month from order_date) as month,
	extract(year from order_date) as year
from orders as o
join order_items as oi
on o.order_id = oi.order_id
group by 2,3
order by 1 desc;


--12	Identify the most purchased product in each country.
-- I will use windows function RANK() 
with order_per_count as 
(
	select 
		c.country, 
		sum(oi.quantity) as total_quantity,
		p.product_name,
		RANK() OVER (PARTITION BY c.country ORDER BY sum(oi.quantity) DESC) AS rnk
	from customers as c
	join orders as o
		on c.customer_id = o.customer_id
	join order_items as oi
		on oi.order_id = o.order_id
	join products as p
	on p.product_id=oi.product_id
	group by 1,3
)
select country , product_name, total_quantity
from order_per_count
where rnk = 1
order by 1;


--13	Count how many customers made more than one order.
select 
	c.customer_id,
	c.first_name,
	c.last_name,
	count(o.order_id) as total_orders
from customers as c
join orders as o
on o.customer_id = c.customer_id
group by 1
having count(o.order_id) >1 ;


--14	List customers who wrote the most reviews.
select 
	c.customer_id,
	c.first_name,
	c.last_name,
	count(r.review_id) as total_reviews
from customers as c
join reviews as r
on c.customer_id = r.customer_id
group by 1
order by 4 desc ;


--15	Find the average rating given by customers for products in their first order.
with first_order as
(
	select
		min(o.order_date) as first_order_date,
		o.customer_id
	from orders as o 
	group by 2
)
select
	c.customer_id,
	round(AVG(r.rating),2) as avg__frst_order_rate,
	c.first_name,
	c.last_name
from first_order as f
join reviews as r
on r.customer_id = f.customer_id
join orders as o on o.customer_id = o.customer_id
join customers as c
on c.customer_id = r.customer_id
where o.order_date = (
	select min(order_date)
	from orders as o2
	where o2.customer_id = c.customer_id
)
group by c.customer_id, c.first_name, c.last_name;