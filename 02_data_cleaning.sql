--DATA CLENAING
--1. Missing Values
select
    count(*) - count(addressline2) as missing_addressline2,
    count(*) - count(state) as missing_state,
    count(*) - count(postalcode) as missing_postalcode
from sales_data_sample;
-- handledin the data auditing

--2. Duplicate check
select ordernumber, orderlinenumber, count(*)
from sales_data_sample
group by ordernumber, orderlinenumber
having count(*) > 1;
-- no duplicate

--3. Standardization
--a. Date format check
select data_type
from information_schema.columns
where table_name = 'sales_data_sample' and column_name = 'orderdate';
--b. Text Correction
update sales_data_sample
set customername = initcap(customername),
    city = initcap(city),
    contactfirstname = initcap(contactfirstname),
    contactlastname = initcap(contactlastname);
--c. Category field consistency check
select distinct status from sales_data_sample order by 1;
select distinct productline from sales_data_sample order by 1;
select distinct dealsize from sales_data_sample order by 1;
select distinct country from sales_data_sample order by 1;
select distinct territory from sales_data_sample order by 1;
--d. Phone standardization
update sales_data_sample
set phone = regexp_replace(phone, '[^0-9+]', '', 'g');
select phone from sales_data_sample;

--4. Data Validation
--a. fix PRICEEACH invalid values
alter table sales_data_sample
add column priceeach_corrected decimal(10,2);

update sales_data_sample
set priceeach_corrected = round(sales / quantityordered, 2);

--b. correction check
select ordernumber, orderlinenumber, quantityordered, priceeach,
       priceeach_corrected, sales
from sales_data_sample
where priceeach = 100.00
limit 10;
-- now corrected

--c. outliers check
select ordernumber, orderlinenumber, quantityordered, sales
from sales_data_sample
where sales > (
    select percentile_cont(0.75) within group (order by sales) +
           1.5 * (percentile_cont(0.75) within group (order by sales) -
                  percentile_cont(0.25) within group (order by sales))
    from sales_data_sample
)
order by sales desc;
