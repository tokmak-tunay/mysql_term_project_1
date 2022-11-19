CREATE SCHEMA olist;
USE olist;



-- Create Tables 

CREATE TABLE customers (
	customerID VARCHAR(250),
    uniqueID   VARCHAR(250),
    zipCode	   CHAR(10),
    city	   VARCHAR(250),
    state	   VARCHAR(250),
    PRIMARY KEY(customerID)
    
    
);




CREATE TABLE orders (
	orderID VARCHAR(250),
    customerID VARCHAR(250),
    orderStatus VARCHAR(250),
	deliveryTime TIMESTAMP,
    purchaseTime TIMESTAMP,
    PRIMARY KEY(orderID),
    FOREIGN KEY(customerID) REFERENCES customers(customerID)
	
  
);






CREATE TABLE sellers (
	sellerID VARCHAR(250),
    zipCode CHAR(5),
    city VARCHAR(250),
    state VARCHAR(250),
    PRIMARY KEY (sellerID)
    
);

CREATE TABLE products (
	productID VARCHAR(250),
    category VARCHAR(250),
    nameLength INTEGER,
    descriptionLength INTEGER,
    photosQuantity INTEGER,
    weight DECIMAL(11,2),
    length DECIMAL(11,2),
    height DECIMAL(11,2),
    width DECIMAL(11,2),
    PRIMARY KEY(productID)
);

CREATE TABLE orderitems (
	orderID VARCHAR(250),
    itemID INTEGER,
    productID VARCHAR(250),
    sellerID VARCHAR(250),
    shippingLimitDate TIMESTAMP,
    price DECIMAL(11,2),
    freightValue DECIMAL(11,2),
    FOREIGN KEY(orderID) REFERENCES orders(orderID),
    FOREIGN KEY(productID) REFERENCES products(productID),
    FOREIGN KEY(sellerID) REFERENCES sellers(sellerID)

);




CREATE TABLE orderReviews (
	orderID VARCHAR(250),
	reviewID VARCHAR(250) ,
    
    score INTEGER,
    FOREIGN KEY(orderID) REFERENCES orders(orderID)
    
	
);

CREATE TABLE payments (
	orderID VARCHAR(250),
    paymentType VARCHAR(250),
    installments INTEGER,
    paymentValue DECIMAL(11,2),
    FOREIGN KEY(orderID) REFERENCES orders(orderID)
);

-- Upload Data
-- The data should be in the relevant directory
-- Adjust the path according to your server setup
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv' 
INTO TABLE customers 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(customerID,uniqueID,zipCode ,city ,state);

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv' 
INTO TABLE orders 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(orderID,customerID,orderStatus,@deliveryTime,purchaseTime
)
SET
deliveryTime = if(@deliveryTime = 'NA', NULL, @deliveryTime);

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv' 
INTO TABLE products 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(@productID,category,@nameLength, @descriptionLength, @photosQuantity,@weight ,@length ,@height ,@width )
SET
productID = replace(@productID, '"',''),
nameLength = if(@nameLength = '', NULL, @nameLength),
descriptionLength = if(@descriptionLength = '', NULL, @descriptionLength),
photosQuantity = if(@photosQuantity = '', NULL,@photosQuantity),
weight = if(@weight = '', NULL,@weight),
length = if(@length = '', NULL, @length),
height = if(@height = '', NULL, @height),
width = if(@width = '', NULL,@width);





LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sellers.csv' 
INTO TABLE sellers 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(@sellerID, @zipCode, city, @state)
SET
zipCode = replace(@zipCode, '"',''),
sellerID = replace(@sellerID, '"',''),
state = replace(@state, '"','');

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orderItems.csv' 
INTO TABLE orderItems 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(orderID, @itemID, @productID, @sellerID, @shippingLimitDate, @price, @freightValue)
SET 
productID = replace(@productID, '"',''),
sellerID = replace(@sellerID, '"',''),
shippingLimitDate = if(@shippingLimitDate = 'NA', NULL,
replace(replace(@shippingLimitDate, 'T', ' '),'Z','')),
itemID = if(@itemID = 'NA', NULL, @itemID),
price = if(@price = 'NA', NULL, @price),
freightValue = if(@freightValue = 'NA', NULL, @freightValue);



LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments.csv' 
INTO TABLE payments 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(orderID, paymentType, @installments, @paymentValue)
SET
installments = if(@installments = 'NA', NULL, @installments),
paymentValue = if(@paymentValue = 'NA', NULL, @paymentValue);


LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orderReviews.csv' 
INTO TABLE orderReviews 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(@orderID, @reviewID, @score)
SET
orderID = replace(@orderID, '"', ''),
reviewID = if(@reviewID = 'NA', NULL, @reviewID),
score = if(@score = 'NA', NULL, @score)
 ;
 
 -- Create Derived Tables 
 
 CREATE TABLE prices AS 
WITH productPrice AS (
    SELECT p.productID, o.price, o.itemID
FROM (SELECT DISTINCT productID FROM products) AS p
INNER JOIN orderitems AS o
USING(productID)
WHERE itemID = 1
) SELECT DISTINCT * FROM productPrice;

CREATE TABLE  IF NOT EXISTS messages (
	message VARCHAR(250)
);

-- Create The Analytical Layer
DROP PROCEDURE IF EXISTS sales ;

DELIMITER //

CREATE PROCEDURE sales()
BEGIN 
	DROP TABLE IF EXISTS sales;
    CREATE TABLE sales AS
    SELECT
		orders.orderID,
        orders.purchaseTime,
        orders.deliveryTime,
    
	    products.productID,
        products.category,
        orderitems.itemID,
        orderitems.price,
	    customers.customerID,
        customers.city AS customerCity,
        customers.state AS customerState,
        sellers.city AS sellerCity,
        sellers.state AS sellerState,
        orderitems.sellerID,
        orderreviews.score
	FROM orders
    INNER JOIN customers
    USING(customerID)
    INNER JOIN orderitems
    USING(orderID)
    INNER JOIN sellers
    USING(sellerID)
    INNER JOIN products
    USING(productID)
    INNER JOIN payments
    USING(orderID)
    INNER JOIN orderreviews
    USING(orderID)
    WHERE orderStatus = 'delivered'
    ORDER BY purchaseTime DESC 
;
END //

DELIMITER ;

CALL sales();

SELECT * FROM sales;

-- Create the Event

SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS salesEvent;

DELIMITER $$

CREATE EVENT salesEvent
ON SCHEDULE EVERY 5 MINUTE
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
	
		INSERT INTO messages SELECT CONCAT('sales updated at ',NOW());
    		CALL sales();
	
DELIMITER ;

-- Create the Order Placement Procedure

DROP PROCEDURE IF EXISTS placeOrder;

DELIMITER //

CREATE PROCEDURE placeOrder(
IN customerID VARCHAR(250),
IN productID VARCHAR(250),
OUT message VARCHAR(250)
)
BEGIN 
	DECLARE customer VARCHAR(250) DEFAULT '';
    
    DECLARE product VARCHAR(250) DEFAULT '';
    
	DECLARE zip CHAR(5) DEFAULT '';
    
    DECLARE city VARCHAR(250) DEFAULT '';
    
    DECLARE state VARCHAR(250) DEFAULT '';
    
    DECLARE c VARCHAR(250) DEFAULT '';
    
    DECLARE o VARCHAR(250) DEFAULT '';
     
    DECLARE p DECIMAL(11,2) DEFAULT 0;
    
    DECLARE seller VARCHAR(250) DEFAULT '';
    
	SELECT uniqueID 
    INTO customer 
    FROM customers
    WHERE uniqueID = customerID
    LIMIT 1;
    
    SELECT zipCode 
    INTO zip
    FROM customers
    WHERE uniqueID = customerID
    LIMIT 1;
    
    SELECT city 
    INTO city 
    FROM customers
    WHERE uniqueID = customerID
    LIMIT 1;
    
    SELECT state 
    INTO state 
    FROM customers
    WHERE uniqueID = customerID
    LIMIT 1;
    
    SELECT productID 
    INTO product 
    FROM products
    WHERE productID = productID
    LIMIT 1;
    
    SELECT MAX(price)
    INTO p
    FROM prices
    WHERE productID = productID;
    
    SELECT sellerID
    INTO seller
    FROM products
    INNER JOIN orderitems
    USING(productID)
    WHERE productID = productID
    LIMIT 1;
    
    IF customer = '' THEN 
		SET message = 'Customer does not exist.';
	ELSEIF product = '' THEN
		SET message = 'Product does not exist.';
	ELSE 
		
        SET c= MD5(RAND());
        SET o = MD5(RAND());
		INSERT INTO customers(customerID, uniqueID, zipCode, city,state)
        VALUES(c,customerID, zip,city,state);
        
         INSERT INTO orders(orderID,customerID,orderStatus,deliveryTime,
						   purchaseTime)
		VALUES(o, c,'created',NULL,CURRENT_TIMESTAMP());
        SET message = 'Order has been placed successfully';
        
        INSERT INTO orderitems(orderID,itemID,productID,sellerID,shippingLimitDate,
        price,freightValue)
        VALUES(o,1,product,seller, NULL, p, ROUND(RAND()*10 + 5));
        
       
			
	END IF;
    
END//

DELIMITER ;

CALL placeOrder('104bdb7e6a6cdceaa88c3ea5fa6b2b93','000d9be29b5207b54e86aa1b1ac54872',@message);

-- Create Trigger
DROP TRIGGER IF EXISTS orderDelivered;

DELIMITER //

CREATE TRIGGER orderDelivered
BEFORE UPDATE
ON orders FOR EACH ROW
BEGIN
	IF NEW.orderStatus = 'delivered' THEN
		SET NEW.deliveryTime = CURRENT_TIMESTAMP();
	END IF;
END //

DELIMITER ;

-- Create Data Marts

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

