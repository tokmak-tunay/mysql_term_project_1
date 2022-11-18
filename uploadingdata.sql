USE olist;
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