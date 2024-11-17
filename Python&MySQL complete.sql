
create table orders (
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code varchar(20),
region varchar(20),
category varchar(20),
sub_category varchar(20),
product_id varchar(50),
quantity int,
discount decimal (7,2),
sales_price decimal (7,2),
profit decimal (7,2) 
) 

select * from orders;
-- a.	Find top 10 highest revenue generating products"
with cte1 as (
select product_id,quantity * sales_price as total_sales from orders
)
select product_id, sum(total_sales) as revenue from cte1
group by product_id 
order by sum(total_sales) desc 
limit 10;

-- b.	Find top 5 highest selling  products in each region
select distinct region from orders;
with cte1 as 
(
select region,
	   product_id,
       sum(sales_price) as sales from orders
group by region, product_id 
)
select * from 
(select *, 
		row_number() over (partition by region order by sales desc) as rn from cte1
order by region, sales desc) as SQ 
where rn <=5 ;
-- c.	Find sales growth comparison MoM for 2022 and 2023 eg : jan 2022 vs jan 2023

	with cte as 
    (
    select year(order_date) as yr,
    month(order_date) as mnt,
    sum(sales_price) as sales from orders
    group by yr,mnt
    -- order by yr,mnt;
   )
   select mnt,
   sum(case when yr=2022 then sales else 0 end) as sales_2022,
   sum(case when yr=2023 then sales else 0 end) as sales_2023
   from cte
   group by mnt
   order by mnt;
   
   
   
-- d.	For each category which month has the highest sales
with cte as
(
select category,
date_format(order_date,'%Y%m') as yr_m, 
sum(sales_price) as sales
 from orders
group by category,yr_m
)
select * from
(
select *, 
row_number() over (partition by category order by sales desc) as rn from cte
 order by category,rn) as SQ 
where rn =1;


-- which sub category have the highest profit by growth in 2023 compare to 2022
with cte as
(
select sub_category,
year(order_date) as yr, 
profit from orders
),
cte2 as 
(
select sub_category,
sum(case when yr=2022 then profit else null end) as profit_22,
sum(case when yr= 2023 then profit else null end) as profit_23
from cte
group by sub_category
)
select *, (profit_23 - profit_22) as growth from cte2
order by growth desc limit 1;