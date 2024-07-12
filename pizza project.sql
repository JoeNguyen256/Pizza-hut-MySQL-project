use pizza_sales;
-- Retrieve the total number of orders placed.
select count(order_id) as total_orders
from orders;

-- Calculate the total revenue generated from pizza sales.
select Round(sum(od.quantity*p.price),2) as total_revenue
from order_details as od join pizzas as p on od.pizza_id=p.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
from pizza_types
join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.name, pizzas.price
order by pizzas.price desc
limit 1;

-- Identify the most common pizza size ordered.
select p.size, count(od.order_id)
from pizzas as p
join order_details as od on od.pizza_id=p.pizza_id
group by p.size
order by 2 desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name, count(od.quantity) as top5_ordered
from order_details as od
join pizzas as p on od.pizza_id=p.pizza_id
join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by 2 desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category, sum(od.quantity)
from order_details as od
join pizzas as p on od.pizza_id=p.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category; 

-- Determine the distribution of orders by hour of the day.
select hour(time), count(order_id)
from orders 
group by hour(time)
order by 2 desc;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name)
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(sum_quantity),2) from 
	(select o.date, sum(od.quantity) as sum_quantity
	from order_details as od
	join orders as o on o.order_id=od.order_id
    group by o.date) as sum_quan;
    
-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name, Round(sum(od.quantity*p.price),2) as revenue
from order_details as od 
join pizzas as p on od.pizza_id=p.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by 2 desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pt.category, 
(sum(od.quantity*p.price)*100 / (select sum(od.quantity*p.price) 
from order_details as od join pizzas as p on od.pizza_id=p.pizza_id)) as per_revenue
from pizza_types as pt 
join pizzas as p on pt.pizza_type_id=p.pizza_type_id
join order_details as od on od.pizza_id=p.pizza_id
group by pt.category;

-- Analyze the cumulative revenue generated over time.
select date, sum(revenue) over (order by date)as cum_rev
from (select o.date, sum(od.quantity*p.price) as revenue
from order_details as od join pizzas as p on od.pizza_id=p.pizza_id
join orders as o on o.order_id=od.order_id
group by o.date ) as total
group by date ;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, category, revenue
from
(select name, category, revenue, rank() over(partition by category order by revenue desc) as rk
from (select pt.name, pt.category, Round(sum(od.quantity*p.price),2) as revenue
from order_details as od
join pizzas as p on od.pizza_id=p.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
group by pt.name, pt.category) as sales) as a
where rk <= 3;


