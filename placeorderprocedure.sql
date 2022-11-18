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
