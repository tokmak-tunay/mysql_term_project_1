# Analyzing Brazilian E-Commerce Public Dataset by OLIST
The dataset includes data related to customers, orders, sellers, and products. 
The main aim of the analysis is to answer the following questions:

* Who are the most significant sellers based on revenue stream?
* What are the most popular products ?
* Who are the most significant customers based on revenue stream?
* What are the products with the worst reviews ? 

## Operational Layer 

The layer consists of 7 related tables . Order table is connected to orderItems , payments, orderReviews through orderID, when it is connected to customers through customerID. Sellers table 
is connected to orderItems through sellerID and. Products and orderItems are connected through productID. 

![er](https://user-images.githubusercontent.com/100707983/202511278-fc23c32f-08d9-47db-81e6-0a1da49d0b8d.png)

## Analytical Layer

The sales data warehouse constitutues the analytical layer. It consists of delivered orders.

![layers](https://user-images.githubusercontent.com/100707983/202524567-bbe8a85d-05f3-4969-8713-0162cc1382a2.png)




## Dynamic Analytical Layer

### Event to Keep Analytical Layer Updated

An event is created to ensure that the sales data warehouse is updated twice a day per one month.


```
USE olist;

SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS salesEvent;

DELIMITER $$

CREATE EVENT salesEvent
ON SCHEDULE EVERY 12 HOUR
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 MONTH
DO
	
		INSERT INTO messages SELECT CONCAT('sales updated at ',NOW());
    		CALL sales();
	
DELIMITER ;


```
### Stored Procedure to Place an Order and Preserving the Data Integrity

A stored procedure is created to place an order. The procedure takes customerID and productID as parameters. To ensure data integrity , it checks whether the customer and the product exists in the database . If they exist, it places the order and updates customers, orders, and orderItems tables.
The orderID is created randomly and encrypted using MD5 algorithm. If the order placement is successfull, the procedure returns a message.

To be able to extract the price of a product, a prices table is created using orderItems table. Price of each product is assigned based on the itemID which means only one product was sold. Therefore, it was possible to have price information for each product. 

```
USE olist;

CREATE TABLE prices AS 
WITH productPrice AS (
    SELECT p.productID, o.price, o.itemID
FROM (SELECT DISTINCT productID FROM products) AS p
INNER JOIN orderitems AS o
USING(productID)
WHERE itemID = 1
) SELECT DISTINCT * FROM productPrice;
```

```
USE olist;

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

```
### Trigger to Automate Data Entry

The data warehouse consists of delivered orders.Once the orderStatus of an order is updated as delivered, an update trigger sets delivery date automatically.

```
USE olist;

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
```

## Data Marts and Analytical Questions

* Who are the most significant sellers based on revenue stream?

By creating the topSellers view, we are able to see the most significant sellers and their products.
This knowledge may be of use for the company in case they aim to strengthen the relationship with the sellers and expand the product line. 
```
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
```
![sellers](https://user-images.githubusercontent.com/100707983/202677854-1dad7e4e-78cd-4505-a841-afb97d975fbc.png)

* What are the most popular products ?

By analyzing the most popular products , the company may develop a discount strategy or a bundling strategy to foster the sales. 

```
CREATE VIEW topProducts AS 
SELECT productID, category,
COUNT(productID) AS quantity, price, price * COUNT(productID) AS revenue,
sellerID, sellerState
FROM sales
GROUP BY productID
ORDER BY quantity DESC
LIMIT 10;
```

![products](https://user-images.githubusercontent.com/100707983/202535821-3965e1a2-f2ce-416f-a601-e8662b1e2d23.png)


* Who are the most significant customers based on revenue stream?
Analysis of the top customers based on the revenue they bring may be of use for customer relationship management. By applying a window function we can also see the products they are purchasing. 

```
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
```
![customers](https://user-images.githubusercontent.com/100707983/202677931-7ad85d46-06a3-4334-8957-5383abbc0f55.png)

* What are the products with the worst reviews ? 

The reviews are categorized for each product as very bad, bad, mediocre, good, and very good based on the average ratings. And the products are listed with very bad reviews with more than 5 reviews to avoid bias. This is quite important to enhance customer service.

```
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
```

![reviews](https://user-images.githubusercontent.com/100707983/202534901-a91b9a87-fc6b-4329-8c2e-77d21f747438.png)

