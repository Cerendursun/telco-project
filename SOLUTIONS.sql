/*  
 -----1.TARIFF-BASED CUSTOMER QUERIES-----
 
--1.1 List customers subscribed to 'Kobiye Destek' tariff
--This query ertrieves customers who are subscribed to a specific tariff plan named 'Kobiye Destek'.
--It uses a JOIN between CUSTOMERS and TARIFFS tables based on TARIFF_ID.
--The WHERE clause filters only the required tariff name.*/

SELECT c.CUSTOMER_ID, c.NAME, c.CITY 
FROM CUSTOMERS c 
JOIN TARIFFS t ON c.TARIFF_ID=t.TARIFF_ID 
WHERE t.NAME='Kobiye Destek';







/*
   -----1.2 Find the newest customer subscribed to this tariff----
   
   --This query identifies the most recently registered customer under the 'Kobiye Destek'tarrif.
   --It uses ORDER BY on SIGNUP_DATE in descending order.
   -- FETCH FIRST 1 ROW ONLY ensures only the latest customer is returned.*/

SELECT c.*
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID=t.TARIFF_ID 
WHERE t.NAME='Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROW ONLY;






/* ---------2. Tariff-Based Customer Queries---------
  
  --2.1 Find the distribution of tariffs among the customers.
  --This query calculates how many customers are subscribed to each tariff.
  --It joins CUSTOMERS and TARIFFS tables using TARIFF_ID.
  --Then it groups the results by tariff name to show distribution.*/

SELECT t.NAME AS TARIFF_NAME,
COUNT(*) AS CUSTOMER_COUNT 
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID=t.TARIFF_ID 
GROUP BY t.NAME;





/* ---------------- 3.Customer Signup Analysis-----------------------------

--3.1 Identify the earliest customers to sign up.
--This query finds the earliest registered customers in the system.
--It uses the minimum SIGNUP_DATE to identify the oldest records.
--Customers with the same earliest date are all included.*/

SELECT * 
FROM CUSTOMERS
WHERE SIGNUP_DATE =(SELECT 
MIN(SIGNUP_DATE) FROM CUSTOMERS);




/* ----- 3.2 Find the distribution of these earliest customers across different cities,including the total count for each city.----
-- This query analyzes how earliest customers are distributed across cities.
--First it finds the earliest signup date.
--Then it groups customers by city and counts them.   */

SELECT CITY,COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS 
WHERE SIGNUP_DATE=(SELECT MIN(SIGNUP_DATE)FROM CUSTOMERS)
GROUP BY CITY;





/* -------------4.Missing Monthly Records--------------------

--4.1 This Query identifies customers who do not have a corresponding record in the monthly usage table.
A LEFT JOIN is used to include all customers,even those without a matching monthly record.
If no match is found in MONTHLY_STATS, the result will be NULL, which indicates missing data. */

SELECT c.CUSTOMER_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID=m.CUSTOMER_ID 
WHERE m.CUSTOMER_ID IS NULL;





/* ----------------4.2 Find the distribution of these missing customers across different cities.-----------

-- This query analyzes the geographical distribution of customers who have missing monthly records.
First, customers without usage data are identified using a LEFT JOIN condition.
Then,the results are grouped by city to show how missing records are distributed acroess locations. */

SELECT c.CITY,COUNT(*)AS MISSING_CUSTOMERS
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID=m.CUSTOMER_ID 
WHERE m.CUSTOMER_ID IS NULL
GROUP BY c.CITY;






/* -------------------- 5.Usage Analysis----------------------------------------

--5.1 This query identifies customers who have used at least 75% of their data limit.
It joins CUSTOMERS,TARIFFS  and MONTHLY_STATS tables to compare usage and limits.
The condition checks whether the data usage is greater than or equal to 75% of the defined data limit. */

SELECT c.CUSTOMER_ID, c.NAME, m.DATA_USAGE, t.DATA_LIMIT
FROM CUSTOMERS c 
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID=m.CUSTOMER_ID 
JOIN TARIFFS t ON c.TARIFF_ID=t.TARIFF_ID 
WHERE m.DATA_USAGE >=(t.DATA_LIMIT * 0.75);






/*--------5.2 This query identifies customers who have fully exhausted all their package limits.
 
  It compares data,minute and SMS usage with their respective limits from the tariff.
  Only customers who meet or exceed all limits are included in the result.
  This query may return no results if no customers have fully exhausted all their package limits.
  This is expected behavior depending on the dataset.*/

SELECT c.CUSTOMER_ID, c.NAME
FROM CUSTOMERS c 
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID=m.CUSTOMER_ID 
JOIN TARIFFS t ON c.TARIFF_ID=t.TARIFF_ID 
WHERE m.DATA_USAGE >= t.DATA_LIMIT 
AND m.MINUTE_USAGE >= t.MINUTE_LIMIT 
AND m.SMS_USAGE >=t.SMS_LIMIT;







/* ---------------6.PAYMENT ANALYSIS-----------------------
 --6.1 This query retrieves customers who have unpaid fees based on their monthly records.
 It filters the MONTHLY_STATS table using the PAYMENT_STATUS column.
 Only records marked as 'UNPAID' are included in the result. */

SELECT c.CUSTOMER_ID, c.NAME,m.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID=m.CUSTOMER_ID 
WHERE m.PAYMENT_STATUS='UNPAID';







 /*-------6.2 This query analyzes how different payment statuses are distributed across tariffs.
  It joins CUSTOMERS,MONTHLY_STATS, and TARIFFS tables.
  The results are grouped by tariff name and payment status th show their distribution.*/

SELECT t.NAME AS TARIFF_NAME, m.PAYMENT_STATUS, COUNT(*) AS
TOTAL_COUNT
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID=m.CUSTOMER_ID 
JOIN TARIFFS t ON c.TARIFF_ID =t.TARIFF_ID 
GROUP BY t.NAME , m.PAYMENT_STATUS;

