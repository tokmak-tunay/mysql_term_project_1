USE olist;
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
        customers.customerID,
        customers.city AS customerCity,
        customers.state AS customerState,
        sellers.city AS sellerCity,
        sellers.state AS sellerState,
        orderitems.sellerID,
        orderitems.itemID,
        orderitems.price,
        products.productID,
        products.category,
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