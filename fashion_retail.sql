create view products_cleaned as
select product_id,
category,
brand,
season,
size,
color,
original_price,
markdown_percentage / 100 as markdown_percentage,
current_price,
purchase_date,
stock_quantity,
customer_rating,
is_returned,
return_reason,
item,
fit,
material,
target_gender,
case
	when season = 'Winter' and extract(month from purchase_date::date) in (12,1,2) then 'in-season'
	when season = 'Spring' and extract(month from purchase_date::date) in (3,4,5) then 'in-season'
	when season = 'Summer' and extract(month from purchase_date::date) in (6,7,8) then 'in-season'
	when season = 'Fall' and extract(month from purchase_date::date) in (9,10,11) then 'in-season'
	else 'out-of-season'
end as season_purchased
from products

select COUNT(*) from products ;

select *
from products
limit 10;

select distinct item
from products;

select fit, count(*)
from products p
group by fit;

select is_returned, count(*)
from products
group by is_returned

select
    item,
    min(original_price) as min_original_price, 
    max(original_price) as max_original_price, 
    avg(original_price) as avg_original_price
from products
group by item;

select
    item,
    min(current_price) as min_current_price,
    max(current_price) as max_current_price,
    avg(current_price) as avg_current_price
from products
group by item;

select
item,
min(customer_rating) as min_rating,
max(customer_rating) as max_rating,
avg(customer_rating) as avg_rating
from products
group by item;

select 
    item, avg(markdown_percentage)
from products_cleaned p
where p.markdown_percentage <> 0
group by item
order by avg(markdown_percentage) desc;

select fit, 
avg(stock_quantity) as avg_quantity, 
avg(markdown_percentage) as avg_markdown, 
count(*) as units_sold
from products_cleaned p
group by fit;

select material, avg(customer_rating)
from products p 
group by material;

select item, count(*)
from products p
where markdown_percentage = 0
group by item;

create view category_metrics(item, avg_stock, avg_markdown) as 
  select
    distinct item,
    AVG(stock_quantity) over (partition by item) as avg_stock,
    AVG(markdown_percentage) over(partition by item) as avg_markdown   
  from products_cleaned
  
select p.item, count(*)
from category_metrics c, products p
where p.item = c.item 
and p.stock_quantity > c.avg_stock 
and p.markdown_percentage > c.avg_markdown
group by p.item
order by count(*) desc;

select c.item
from category_metrics c
where not exists(
select p.item
from products p
where p.item = c.item 
and p.stock_quantity > c.avg_stock 
and p.markdown_percentage > c.avg_markdown
)

select item, season as release_season, season_purchased,
count(*) as units_sold,
avg(markdown_percentage) as avg_markdown
from products_cleaned
group by item, season, season_purchased;

select item, brand, 
min(original_price) as min_original_price,
max(original_price) as max_original_price,
avg(original_price) as avg_original_price,
avg(markdown_percentage) as avg_markdown
from products_clean
group by item, brand

with avg_stock_rating as(
select avg(customer_rating) as rating,
avg(stock_quantity) as stock
from products
)
select item, p.stock_quantity, p.customer_rating, fit, material, target_gender
from products p, avg_stock_rating asr
where stock_quantity < asr.stock
and customer_rating > asr.rating

with avg_stock_rating as(
select avg(customer_rating) as rating,
avg(stock_quantity) as stock
from products
)
select item, p.stock_quantity, p.customer_rating, fit, material, target_gender
from products p, avg_stock_rating asr
where stock_quantity > asr.stock
and customer_rating < asr.rating

select * from products_cleaned