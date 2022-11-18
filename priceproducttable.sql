USE olist;

CREATE TABLE prices AS 
WITH productPrice AS (
    SELECT p.productID, o.price, o.itemID
FROM (SELECT DISTINCT productID FROM products) AS p
INNER JOIN orderitems AS o
USING(productID)
WHERE itemID = 1
) SELECT DISTINCT * FROM productPrice;


