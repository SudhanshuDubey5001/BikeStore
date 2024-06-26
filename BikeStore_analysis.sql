use production;
select * from brands;

select * from production.categories;

select * from production.products;

select * from stocks;

use sales;

select * from customers;

select * from order_items;

select * from orders;

select * from staffs;

select * from stores;

use sales;

create table production_sales_products_orders as 
select 
	oi.order_id,
    oi.item_id,
    oi.product_id,
    oi.quantity,
	((oi.quantity*oi.list_price) - oi.discount) as total_amount,
    p.product_name,
    p.model_year,
    c.category_name,
    b.brand_name
from order_items oi
join production.products p
	on p.product_id = oi.product_id
join production.categories c
	on c.category_id = p.category_id
join production.brands b
	on b.brand_id = p.brand_id
order by oi.order_id;

select * from production_sales_products_orders;

create table sales_modified as
select 
	c.customer_id,
    concat(c.first_name,' ', c.last_name) as name,
    c.city,
    c.state,
    c.zip_code,
    o.order_id,
    o.order_status,
    o.order_date,
    o.required_date,
    o.shipped_date,
    ot.product_id,
    ot.quantity,
    (ot.quantity*ot.list_price)-discount as total_amount,
    st.store_name,
    concat(stf.first_name, ' ', stf.last_name) as staff_name
from customers c
join orders o
	on o.customer_id = c.customer_id
join order_items ot
	on ot.order_id = o.order_id
join stores st
	on st.store_id = o.store_id
join staffs stf
	on stf.staff_id = o.staff_id;
    
create table final_sales_product_table as
select 
	s.order_id,
    s.customer_id,
    s.product_id,
    s.name,
    s.city,
    s.state,
    s.zip_code,
    s.order_status,
    s.required_date,
    s.shipped_date,
    s.quantity,
    s.total_amount,
    s.store_name,
    s.staff_name,
    p.product_name,
    p.model_year,
    p.category_name,
    p.brand_name
from sales_modified s
join production_sales_products_orders p
	on p.order_id = s.order_id and p.product_id = s.product_id;
    
select * from final_sales_product_table;

-- Most revenue generated from which brand
select 
	brand_name,
    sum(total_amount) revenue,
    (sum(total_amount)*100)/(select sum(total_amount) from final_sales_product_table) 'percentage%'
from final_sales_product_table
group by brand_name
order by revenue desc;

-- Top 10 customers
select 
	customer_name,
    sum(total_amount),
    count(*) total_orders
from final_sales_product_table
group by customer_name
order by sum(total_amount) desc
limit 10;

-- monthy growth revenue generated
select 
	date_format(required_date, '%Y-%m') dates,
    sum(total_amount) revenue
from final_sales_product_table
group by dates
order by dates;
-- We can see that there is a missing month of May info and and very astronomical drop in revenue from April to June which seems atypical
 
-- Top states of revenue generating states
select
	state,
    city,
    store_name,
    brand_name,
    product_name,
    required_date,
    sum(total_amount) revenue
from final_sales_product_table
group by state, city, store_name, brand_name, product_name, required_date
order by revenue desc
limit 10;
-- Seems like Trek is the most revenue generating bike as all the top 10 stores around the states sold trek only
-- The most popular model is Trek Domane 2018 edition.  

-- Top 10 bikes categories and brand names 
select
	brand_name,
	category_name,
    sum(total_amount) revenue
from final_sales_product_table
group by brand_name, category_name
order by revenue desc
limit 10;

-- Time between order and shipping
select 
	required_date,
    shipped_date,
    shipped_date-required_date
from final_sales_product_table;

-- Total revenue
with x as (select 
	*,
    (list_price*quantity) - discount as total_amount
from sales.order_items)
select sum(total_amount) from x;

-- Total items sold
select sum(quantity) from final_sales_product_table;

-- Total number of customers
select count(*) from customers;







