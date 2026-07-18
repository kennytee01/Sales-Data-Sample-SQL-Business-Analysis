-- business question 1: revenue and sales trends

-- 1. total revenue overview
select
    count(distinct ordernumber) as total_orders,
    sum(sales) as total_revenue,
    round(avg(sales), 2) as avg_order_line_value
from sales_data_sample;
/****
Finding: Toral orders = 307
         Total Revenue = 10032628.85
         Average order line value = 3553.89
****/

-- 2. yearly revenue trend
select
    year_id,
    count(distinct ordernumber) as total_orders,
    sum(sales) as total_revenue
from sales_data_sample
group by year_id
order by year_id;
-- check for quanity to proof
select round(1791486.71 / 5 * 12, 2) as annualized_2005_revenue;
/*******
Findings: Revenue grew from $3.52M (2003) to $4.72M (2004),
a 34% increase. 2005 data is partial (Jan–May only); annualized at the same pace,
2005 tracks to approximately $4.30M — a modest 9% pace decline versus 2004,
though this should be read with caution given only 5 months of actual data.
Recommend flagging this as "insufficient data to confirm a declining trend"
rather than a definitive finding.
************/


-- 3. monthly revenue trend (across all years)
select
    year_id,
    month_id,
    sum(sales) as monthly_revenue
from sales_data_sample
group by year_id, month_id
order by year_id, month_id;

select year_id, month_id, count(distinct ordernumber) as order_count, sum(sales) as revenue
from sales_data_sample
where month_id in (10, 11)
group by year_id, month_id
order by year_id, month_id;
-- Insights Documented

-- 4. quarterly revenue trend
select
    year_id,
    qtr_id,
    sum(sales) as quarterly_revenue
from sales_data_sample
group by year_id, qtr_id
order by year_id, qtr_id asc;
/******
2003 Q4: $1,860,005.09 — more than 4x Q1's $445,094.69
2004 Q4: $2,014,774.92 — nearly 2.5x Q1's $833,730.68
Q4 is the strongest quarter in both years, Q1 consistently the weakest
***/


-- 5. month over month growth rate (using window function LAG)
with monthly as (
    select
        year_id,
        month_id,
        sum(sales) as monthly_revenue
    from sales_data_sample
    group by year_id, month_id
)
select
    year_id,
    month_id,
    monthly_revenue,
    lag(monthly_revenue) over (order by year_id, month_id) as prev_month_revenue,
    round(
        (monthly_revenue - lag(monthly_revenue) over (order by year_id, month_id))
        / lag(monthly_revenue) over (order by year_id, month_id) * 100, 2
    ) as pct_growth
from monthly
order by year_id, month_id;
-- insights documented


-- 6. revenue by order status (identify cancelled/disputed impact)
select
    status,
    count(*) as order_lines,
    sum(sales) as total_revenue
from sales_data_sample
group by status
order by total_revenue desc;
-- insights documented 