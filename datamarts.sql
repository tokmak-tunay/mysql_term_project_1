USE olist;

-- Summarize the top 10 sellers 
CREATE VIEW topSellers AS
WITH topSellers AS
 (SELECT sellerID, productID,category,SUM(price) OVER (PARTITION BY sellerID) revenue
FROM sales
WHERE sellerID IN ( SELECT sellerID FROM ( SELECT sellerID, SUM(price) AS
revenue FROM sales GROUP BY sellerID
ORDER BY revenue DESC
LIMIT 10 ) AS s)
ORDER BY revenue DESC)
SELECT DISTINCT * FROM topSellers;


-- Summarize the top 10 products 

CREATE VIEW topProducts AS 
SELECT productID, category,
COUNT(productID) AS quantity, price, price * COUNT(productID) AS revenue,
sellerID, sellerState
FROM sales
GROUP BY productID
ORDER BY quantity DESC
LIMIT 10;

-- Summarize top 10 customers 
CREATE VIEW topCustomers AS
WITH topCustomers AS
 (SELECT customerID, productID,category,price,SUM(price) OVER (PARTITION BY customerID) revenue
FROM sales
WHERE customerID IN ( SELECT customerID FROM ( SELECT customerID,
price, price * COUNT(customerID) AS revenue
FROM sales
GROUP BY customerID
ORDER BY revenue DESC
LIMIT 10 ) AS s)
ORDER BY revenue DESC)
SELECT DISTINCT * FROM topCustomers;

-- Summarize ratings

CREATE VIEW worstReviews AS
SELECT productID, sellerID, count(score) as reviewCount,
CASE ROUND(AVG(score))
	WHEN 1 THEN 'VERY BAD'
    WHEN  2 THEN 'BAD'
    WHEN 3 THEN 'MEDIOCRE'
    WHEN  4 THEN 'GOOD'
    WHEN 5 THEN 'VERY GOOD'
    ELSE 'NOT AVAILABLE'
END AS review
FROM sales
GROUP BY productID
HAVING (review = 'VERY BAD' OR 'BAD') AND (reviewCount > 5);

USE olist;
SELECT sellerID, SUM(revenue) AS revenue FROM topSellers 
GROUP BY sellerID
ORDER BY revenue;

SELECT customerID, SUM(revenue) AS revenue FROM topCustomers 
GROUP BY customerID
ORDER BY revenue;

SELECT productID, SUM(quantity) AS quantity FROM topProducts 
GROUP BY productID
ORDER BY quantity;

SELECT productID, reviewCount FROM worstReviews 
GROUP BY productID
ORDER BY reviewCount DESC
LIMIT 10;