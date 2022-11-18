USE olist;

-- When an order is updated as 'delivered' insert the delivery time automatically

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


