SELECT * FROM df_orders;

-- top 10 highest revenue projects
select product_id as id,sum(sale_price) as sales
from df_orders
group by product_id
order by sales DESC
limit 10;

-- top 5 highest selling products in each region
SELECT *
FROM (
    SELECT 
        product_id AS id, 
        SUM(sale_price) AS sales, 
        region,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rn
    FROM df_orders
    GROUP BY region, product_id
) AS t
WHERE rn <= 5;


-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
select order_month,
sum(case when order_year=2022 then sales else 0 end),
sum(case when order_year=2023 then sales else 0 end)
from(
select year(order_date) as order_year,month(order_date) as order_month ,sum(sale_price) as sales
from df_orders
group by order_year,order_month
) as t
group by order_month
order by order_month;



-- for each categry which month had highet sales
SELECT t.category, t.order_month
FROM (
    SELECT 
        category, 
        MONTH(order_date) AS order_month, 
        SUM(sale_price) AS sales,
        MAX(SUM(sale_price)) OVER (PARTITION BY category) AS max_sale_of_month
    FROM df_orders
    GROUP BY category, MONTH(order_date)
) AS t
WHERE t.sales = t.max_sale_of_month;

-- which subcategory had the highest growth by profit in 2023 compare to 2022
select sub_category
from(
select sub_category,sum(case when year(order_date)=2023 then sale_price else 0 end) as sales_2023,
sum(case when year(order_date)=2022 then sale_price else 0 end) as sales_2022
from df_orders
group by sub_category
) as t
order by (t.sales_2023-t.sales_2022) DESC
limit 1;

