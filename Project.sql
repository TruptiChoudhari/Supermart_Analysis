 --Question 1: What is the total sales amount by region?
 select c.region, sum(s.sales) as total_sales from customer as c left join sales as s on
 	c.customer_id=s.customer_id group by 1;

-- Question2 :  Which products generated the most sales?
select p.product_name, sum(s.sales) as total_sales from product as p left join sales as s 
	on p.product_id=s.product_id group by 1 order by 2 desc;

--Question3: How does the discount affect profit?
select order_id, discount, avg(profit) as avg_profit, sum(sales) as total_sales
	from sales group by 1,2 order by 3 desc;

--Question 4: How much sales does each customer segment contribute?
select c.segment, sum(s.sales) as total_sales from customer as c left join sales as s
	on c.customer_id=s.customer_id group by 1;

--Question5: What are the total sales for each product category?
select p.category, sum(s.sales) as total_sales from product as p join sales as s 
	on p.product_id = s.product_id group by 1;

--Question6: How many orders were shipped by each shipping mode?
select ship_mode, count(order_id) as total_order from sales group by 1 order by 2;

--Question7: What are the total sales for each month?
select extract('month' from order_date) as month, sum(sales) as total_sales from sales group by 1 order by 1;

--Question8: How many customers are there in each state?
select state, count(customer_id) as total_customers from customer group by 1 order by 2 desc;

--Question9: Who are the top 5 customers in terms of total sales?
select c.customer_id, c.customer_name, sum(s.sales) from customer as c join sales as s
	on c.customer_id=s.customer_id group by 1,2 order by 3 desc limit 5;

--Question10: What is the total sales for each product subcategory?
select p.sub_category, sum(s.sales) as total_sales from product as p join sales as s
	on p.product_id=s.product_id group by 1 order by 2 desc;

--Question11: How can we rank products by their total sales within each product category?
select c.category, sum(s.sales) as total_sales, 
		rank() over (order by sum(s.sales)desc) from 
		product as c left join sales as s
		on c.product_id=s.product_id group by 1;

--Question12: How can we calculate cumulative sales over time (running total) for each product?
select p.product_name, s.order_date, floor(s.sales) as sales, 
		sum(floor(s.sales)) over (order by s.order_date) as running_total_sales
		from product as p join sales as s 
		on p.product_id =s.product_id;


--Question13: How can we find the top 3 customers based on profit within each region?
select * from (
	select c.region, c.customer_name, sum(s.profit), 
	rank() over(partition by c.region order by sum(s.profit) desc) as ranks
	from customer as c join sales as s
	on c.customer_id=s.customer_id group by 1,2)where ranks<=3; 

/*Question14: How can we find the average sales for each segment and assign a row
number to each customer based on their sales?*/
select *, 
	row_number() over (partition by segment order by avg_sales desc) as row_number_for_avg_sales
	from (
	select c.segment as segment, c.customer_name,
	AVG(s.sales) over (partition by c.segment) as avg_sales
	from customer as c left join sales as s
	on c.customer_id=s.customer_id);

--Question15: How can we calculate the difference in sales between consecutive days for each product?
select p.product_name, s.order_id,s.order_date, s.sales, 
	lag(s.sales,1) over(partition by p.product_name order by s.order_date), 
	sales-lag(sales,1) over() as diff 
	from product as p join sales as s
	on p.product_id=s.product_id;

--Question16: How can we calculate the percentage of total sales contributed by each region?
select *, (region_sales * 100.0 / total_sales) AS percentage_of_total_sales 
	from (
	SELECT c.region, SUM(s.sales) AS region_sales, SUM(sum(s.sales)) OVER () AS total_sales
    FROM customer AS c JOIN sales AS s
	ON c.customer_id = s.customer_id GROUP BY c.region) as sub;

--Question17:How can we calculate the moving average of sales over the last 3 orders for each product?
select p.product_id,s.order_date, 
	avg(s.sales) over (partition by p.product_id order by order_date
	rows between 2 preceding and current row ) as avg_sales
	from product as p join sales as s 
	on p.product_id=s.product_id ;
			
--Question18: How can we find the largest and smallest order (by sales) for each customer?
select c.customer_id, 
	max(s.sales) over (partition  by c.customer_id),
	min(s.sales) over(partition by c.customer_id) 
	from customer as c join sales as s
	on c.customer_id= s.customer_id;

--Question19: How can we calculate the running total of profit for each customer?
select c.customer_id, s.order_date, 
	sum(profit) over (partition by c.customer_id
	order by s.order_date)
	from customer as c join sales as s
	on c.customer_id=s.customer_id;

--Question20: How can we assign a dense rank to each sale based on total sales, groupe by ship mode?
select order_id, ship_mode, 
	sum(sales) over (partition by ship_mode ),
	dense_rank() over(partition by ship_mode order by sales) as ranks 
	from sales;
