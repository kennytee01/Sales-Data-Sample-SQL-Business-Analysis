create table sales_data_sample(
ORDERNUMBER varchar(20),
QUANTITYORDERED int,
PRICEEACH DECIMAL(10,2),
ORDERLINENUMBER int,
SALES DECIMAL(10,2),
ORDERDATE date,
STATUS varchar(50),
QTR_ID int,
MONTH_ID int,
YEAR_ID int,
PRODUCTLINE varchar(100),
MSRP int,
PRODUCTCODE varchar(50),
CUSTOMERNAME varchar(100),
PHONE varchar(30),
ADDRESSLINE1 varchar(100),
ADDRESSLINE2 varchar(100),
CITY varchar(50),
STATE varchar(50),
POSTALCODE varchar(50),
COUNTRY varchar(50),
TERRITORY varchar(50),
CONTACTLASTNAME varchar(50),
CONTACTFIRSTNAME varchar(50),
DEALSIZE varchar(50),
primary key (ORDERNUMBER,ORDERLINENUMBER ));

/***** DATA AUDITNG ******/

SELECT current_database();
-- 1. structural overview
select count(*) as total_rows from sales_data_sample;
-- i have 2823 records of data
select * from sales_data_sample;
-- i have 25 columns


select column_name, data_type, is_nullable
from information_schema.columns
where table_name = 'sales_data_sample'
order by ordinal_position;


-- 2. null / missing value audit
select
    count(*) as total_rows,
    count(*) - count(ordernumber) as missing_ordernumber,
    count(*) - count(quantityordered) as missing_quantityordered,
    count(*) - count(priceeach) as missing_priceeach,
    count(*) - count(orderlinenumber) as missing_orderlinenumber,
    count(*) - count(sales) as missing_sales,
    count(*) - count(orderdate) as missing_orderdate,
    count(*) - count(status) as missing_status,
    count(*) - count(qtr_id) as missing_qtr_id,
    count(*) - count(month_id) as missing_month_id,
    count(*) - count(year_id) as missing_year_id,
    count(*) - count(productline) as missing_productline,
    count(*) - count(msrp) as missing_msrp,
    count(*) - count(productcode) as missing_productcode,
    count(*) - count(customername) as missing_customername,
    count(*) - count(phone) as missing_phone,
    count(*) - count(addressline1) as missing_addressline1,
    count(*) - count(addressline2) as missing_addressline2,
    count(*) - count(city) as missing_city,
    count(*) - count(state) as missing_state,
    count(*) - count(postalcode) as missing_postalcode,
    count(*) - count(country) as missing_country,
    count(*) - count(territory) as missing_territory,
    count(*) - count(contactlastname) as missing_contactlastname,
    count(*) - count(contactfirstname) as missing_contactfirstname,
    count(*) - count(dealsize) as missing_dealsize
from sales_data_sample;
-- Adressline2 have 2521 missing data
-- state have 1486 missing data
-- postalcode have 76 missing data


--Problem 1. Adressline2 have 2521 missing data
-- checking the issue
select country, count(*) as total, count(addressline2) as has_addressline2, count(*) - count(addressline2) as missing_addressline2
from sales_data_sample
group by country
order by missing_addressline2 desc;
/*****
FINDINGS: ADDRESSLINE2 is null in 2,521 of 2,823 rows (89%).
Unlike STATE, this is not a country-driven structural pattern population varies
by country in a way consistent with real address complexity 
(like., Ireland 100% populated, Australia 79%, USA only 10%), 
suggesting the field is populated only when a genuine second address line exists 
for example apartment/suite/building.
This is expected behavior for an optional field, not a data quality defect.
No cleaning action required; field is not relevant to core business analysis.
*****/


--Problem 2. state have 1486 missing data
-- checking the issue
select country, count(*) as total, count(state) as has_state, count(*) - count(state) as missing_state
from sales_data_sample
group by country
order by missing_state desc;


select distinct state
from sales_data_sample
where country = 'UK' and state is not null;
/****
Findings: STATE is null for 1,819 of 2,823 rows (64%) — structurally expected,
since only USA, Australia, Canada, and Japan use this field in their address format.
UK shows minor inconsistency: 26/144 rows have a populated state/county value
(which is e"Isle of Wight", 
the rest are blank — reflects inconsistent data capture, not corruption.
No cleaning action required; field is not relevant to core business analysis 
(revenue, product performance, customer segmentation).
*************/

--problem 3: postalcode have 76 missing data
-- checking the issue
select country, count(*) as missing_postal
from sales_data_sample
where postalcode is null
group by country
order by missing_postal desc;

select customername, city, state, count(*) as missing_rows
from sales_data_sample
where postalcode is null and country = 'USA'
group by customername, city, state
order by missing_rows desc;
/*********
FINDINGS:
POSTALCODE is missing in 76 of 2,823 rows (2.7%), concentrated in USA.
Root cause identified: all 76 missing rows trace to exactly 3 customers
(Corporate Gift Ideas Co., Mini Wheels Co., Men 'R' US Retailers Ltd.)
are all California-based.
This is a customer-record-level gap, not a scattered data entry error. 
Since city + state are present for all affected rows, geographic analysis 
at the state/regional level remains unaffected.
Postal code is not required for any planned business question 
(revenue, product, customer segmentation) — recommend leaving as null with this 
documented, rather than imputing.
*******/



-- 3. duplicate check
select ordernumber, orderlinenumber, count(*)
from sales_data_sample
group by ordernumber, orderlinenumber
having count(*) > 1;
-- Zero duplicate


-- 4. cardinality / distinct value counts
select
    count(distinct ordernumber) as unique_orders,
    count(distinct customername) as unique_customers,
    count(distinct productcode) as unique_products,
    count(distinct productline) as unique_productlines,
    count(distinct country) as unique_countries,
    count(distinct territory) as unique_territories,
    count(distinct status) as unique_statuses,
    count(distinct dealsize) as unique_dealsizes
from sales_data_sample;
-- unique_Orders = 307
-- unique customer = 92
-- unique products = 109
-- unique productlines = 7
-- unique countries = 19
-- unique territories = 4
-- unique statuses = 6
-- unique dealsizes = 3


-- 5. category value lists (to spot inconsistent formatting)
select distinct status from sales_data_sample order by 1;
select distinct productline from sales_data_sample order by 1;
select distinct dealsize from sales_data_sample order by 1;
select distinct country from sales_data_sample order by 1;
select distinct territory from sales_data_sample order by 1;
-- All consistent, no inconsistency

-- 6. range checks on numeric fields
select
    min(quantityordered) as min_qty, max(quantityordered) as max_qty,
    min(priceeach) as min_price, max(priceeach) as max_price,
    min(sales) as min_sales, max(sales) as max_sales,
    min(orderdate) as earliest_date, max(orderdate) as latest_date,
    min(msrp) as min_msrp, max(msrp) as max_msrp
from sales_data_sample;
-- min qty = 6
-- max qty = 97
-- min price = 26.88
-- max price = 100.00
-- min sales = 482.13
-- max sales = 14082.80
-- earliest date = 2003-01-06
-- latest date = 2005-05-31
-- min msrp = 33
-- max msrp = 214
/** business meaning; it helps us know the range of data we are working with
and help to make assumptions in cleaning processv***/


-- 7. cross-field validation (sales vs quantityordered x priceeach)
select ordernumber, orderlinenumber, quantityordered, priceeach, sales,
       round(quantityordered * priceeach, 2) as expected_sales,
       sales - round(quantityordered * priceeach, 2) as variance
from sales_data_sample
where abs(sales - (quantityordered * priceeach)) > 1
order by variance desc;

select priceeach, count(*) 
from sales_data_sample
group by priceeach
order by count(*) desc
limit 20;

select productline, status, count(*) 
from sales_data_sample
where priceeach = 100.00
group by productline, status
order by count(*) desc;

select min(orderdate), max(orderdate)
from sales_data_sample
where priceeach = 100.00;

/*****************
Finding: PRICEEACH contains a flat placeholder value of 100.00 in 1,304 of 2,823 rows
(46%), confirmed present in the raw source CSV. 
Cross-referencing against MSRP and SALES for the same PRODUCTCODE shows 
genuine transactions have varied, MSRP-adjacent prices, while affected rows show an 
implausible flat value. 
This field should not be trusted at face value for pricing/profitability analysis.
*****/
