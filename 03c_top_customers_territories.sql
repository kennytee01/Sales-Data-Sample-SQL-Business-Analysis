-- business question 3: top customers and territories

-- 1. top 10 customers by revenue
select
    customername,
    country,
    count(distinct ordernumber) as total_orders,
    sum(sales) as total_revenue
from sales_data_sample
group by customername, country
order by total_revenue desc
limit 10;


-- 2. revenue by territory
select
    territory,
    count(distinct customername) as num_customers,
    count(distinct ordernumber) as total_orders,
    sum(sales) as total_revenue,
    round(sum(sales) * 100.0 / (select sum(sales) from sales_data_sample), 2) as pct_of_total_revenue
from sales_data_sample
group by territory
order by total_revenue desc;


-- 3. revenue by country (top 10)
select
    country,
    territory,
    count(distinct customername) as num_customers,
    sum(sales) as total_revenue
from sales_data_sample
group by country, territory
order by total_revenue desc
limit 10;


-- 4. customer concentration check (revenue share of top 10 vs rest)
with customer_revenue as (
    select
        customername,
        sum(sales) as revenue,
        rank() over (order by sum(sales) desc) as revenue_rank
    from sales_data_sample
    group by customername
)
select
    case when revenue_rank <= 10 then 'Top 10 Customers' else 'All Other Customers' end as customer_group,
    count(*) as num_customers,
    sum(revenue) as total_revenue,
    round(sum(revenue) * 100.0 / (select sum(sales) from sales_data_sample), 2) as pct_of_total_revenue
from customer_revenue
group by customer_group;