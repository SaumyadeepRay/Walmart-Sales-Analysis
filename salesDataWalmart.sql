-- Create database
CREATE DATABASE IF NOT EXISTS slaesDataWalmart;

USE slaesDataWalmart;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_iD VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    valueAddedTax FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT(11, 9) NOT NULL,
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1) NOT NULL
);

SELECT * FROM sales;

-- -----------------------------------------------------------------
-- ---------------------- Feature Engineering ----------------------

-- time_of_day --
SELECT time, (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
    END
) AS time_of_day
FROM sales;

ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20); 

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
    END
);

SELECT * FROM sales;

-- day_name --
SELECT DAYNAME(date) FROM sales;

ALTER TABLE sales
ADD COLUMN day_name VARCHAR(30);

UPDATE sales
SET day_name = DAYNAME(date);

SELECT * FROM sales;

-- month_name --
SELECT MONTHNAME(date) FROM sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(50);

UPDATE sales
SET month_name = MONTHNAME(date);

SELECT * FROM sales;

-- ------------------------------------------------------------------
-- ------------------ Business Question Answers ---------------------

-- Generic Questions --

-- 1. How many unique cities does the data have ?

SELECT DISTINCT city FROM sales;

-- 2. In which city is each branch ?

SELECT DISTINCT city, branch FROM sales;

-- Product --
-- 1. How many unique product lines does the data have ?

SELECT DISTINCT product_line FROM sales;
SELECT COUNT(DISTINCT(product_line)) FROM sales;

-- 2. What is the most common paymnet method ?

SELECT DISTINCT payment_method FROM sales;

SELECT payment_method, COUNT(payment_method) AS payment_count
FROM sales
GROUP BY payment_method
ORDER BY payment_count DESC;

-- 3. WHat is the most selling product line ?

 SELECT product_line FROM sales;
 
 SELECT product_line, COUNT(product_line) AS line_count
 FROM sales
 GROUP BY product_line
 ORDER BY line_count DESC;

-- 4. WHat is the total revenue by month ?

SELECT month_name, total FROM sales;

SELECT month_name AS month,
SUM(total) AS total_revenue 
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5. What month had the largest COGS ?

SELECT month_name, cogs FROM sales;

SELECT month_name AS month, 
SUM(cogs) AS total_cogs
FROM sales
GROUP BY month
ORDER BY total_cogs DESC;

-- 6. What product line had the largest revenue ?

SELECT product_line, total FROM sales;

SELECT product_line,
SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- 7. What is the city with the largest revenue ?

SELECT city, branch, total FROM sales;

SELECT city, branch,
SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- 8. What product line had the largest VAT ?

SELECT product_line, valueAddedTax FROM sales;

SELECT product_line,
AVG(valueAddedTax) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales.

SELECT AVG(quantity) AS avg_qnty FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

SELECT * FROM sales;

-- 10. Which branch sold more products than average product sold ?

SELECT branch, quantity FROM sales;

SELECT branch,
SUM(quantity) AS quantity
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- 11. What is the most common product line by gender ?

SELECT gender, product_line FROM sales;

SELECT gender, product_line,
COUNT(gender) AS total_gender
FROM sales
GROUP BY gender, product_line
ORDER BY total_gender DESC;

-- 12. What is the average rating of each product line ?

SELECT product_line, rating FROM sales;

SELECT product_line,
ROUND(AVG(rating), 2) AS average_rating
FROM sales
GROUP BY product_line
ORDER BY average_rating DESC;


-- Sales Questions --

-- 1. Number of sales made in each time of the day per weekday

SELECT invoice_iD, day_name, time_of_day FROM sales;

SELECT day_name, time_of_day,
COUNT(*) AS total_sales
FROM sales
GROUP BY day_name, time_of_day
ORDER BY total_sales;

-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- 2. Which of the customer types brings the most revenue?

SELECT customer_type, total FROM sales;

SELECT customer_type,
SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT city, valueAddedTax FROM sales;

SELECT city,
ROUND(AVG(valueAddedTax), 2) AS avg_tax_pct
FROM sales
GROUP BY city
ORDER BY avg_tax_pct DESC;

-- 4. Which customer type pays the most in VAT?

SELECT customer_type, valueAddedTax FROM sales;

SELECT customer_type,
AVG(valueAddedTax) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax DESC;


-- Customer Questions -- 

-- 1. How many unique customer types does the data have ?

SELECT DISTINCT customer_type FROM sales;

-- 2. How many unique payment methods does the data have ?

SELECT DISTINCT payment_method FROM sales;

-- 3. What is the most common customer type ?

SELECT customer_type,
COUNT(*) AS customer_count
FROM sales
GROUP BY customer_type
ORDER BY customer_count DESC;

-- 4. Which customer type buys the most ?

SELECT customer_type, total FROM sales;

SELECT customer_type,
COUNT(*)
FROM sales
GROUP BY customer_type;

-- 5. What is the gender of most of the customers ?

SELECT gender FROM sales;

SELECT gender,
COUNT(*) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- 6. What is the gender distribution per branch ?

SELECT branch, gender FROM sales;

SELECT branch, gender,
COUNT(*) AS gender_count
FROM sales
GROUP BY branch, gender
ORDER BY gender_count;

-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- 7. Which time of the day do customers give most ratings ?

SELECT time_of_day, rating FROM sales;

SELECT time_of_day,
AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day alter

-- 8. Which time of the day do customers give most ratings per branch ?

SELECT branch, time_of_day, rating FROM sales;

SELECT branch, time_of_day,
AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY avg_rating DESC;

-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- 9. Which day of the week has the best avg ratings ?

SELECT day_name, rating FROM sales;

SELECT day_name,
AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Monday, Tuesday and Friday are the top best days for good ratings

-- 10. Which day of the week has the best average ratings per branch ?

SELECT branch, day_name, rating FROM sales;

SELECT branch, day_name,
COUNT(day_name) AS total_sales
FROM sales
GROUP BY branch, day_name
ORDER BY total_sales DESC; 




