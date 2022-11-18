CREATE SCHEMA olist;
USE olist;





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



