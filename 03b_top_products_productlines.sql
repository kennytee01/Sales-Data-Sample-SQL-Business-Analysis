-- business question 2: top products and product lines

-- 1. top 10 best-selling products by revenue
select
    productcode,
    productline,
    sum(sales) as total_revenue,
    sum(quantityordered) as total_units_sold
from sales_data_sample
group by productcode, productline
order by total_revenue desc
limit 10;
-- insights documented

-- 2. revenue by product line (which category drives the business)
select
    productline,
    count(distinct productcode) as num_products,
    sum(quantityordered) as total_units_sold,
    sum(sales) as total_revenue,
    round(sum(sales) * 100.0 / (select sum(sales) from sales_data_sample), 2) as pct_of_total_revenue
from sales_data_sample
group by productline
order by total_revenue desc;
-- insights documented

-- 3. deal size distribution by product line (using window function for rank)
select
    productline,
    dealsize,
    count(*) as order_lines,
    sum(sales) as revenue,
    rank() over (partition by productline order by sum(sales) desc) as revenue_rank
from sales_data_sample
group by productline, dealsize
order by productline, revenue_rank;
-- insgihts documented


-- 4. average selling price vs msrp by product line (using corrected price)
select
    productline,
    round(avg(msrp), 2) as avg_msrp,
    round(avg(priceeach_corrected), 2) as avg_actual_price,
    round(avg(priceeach_corrected) - avg(msrp), 2) as avg_price_gap
from sales_data_sample
group by productline
order by avg_price_gap;
-- insights documented