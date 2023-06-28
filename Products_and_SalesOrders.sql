CREATE DATABASE TestCompany;
USE TestCompany;
CREATE TABLE SalesOrders (
    OrderNumber INT NOT NULL AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Customer_Address VARCHAR(255) NOT NULL,
    Customer_Name VARCHAR(255) NOT NULL,
    OrderDate DATE NOT NULL,
    Product_ID INT NOT NULL,
    quantity INT,
    finalcost FLOAT(8,2) NOT NULL,
    PRIMARY KEY (OrderNumber)
);

CREATE TABLE ShipmentVessels (
    VesselName VARCHAR(255) NOT NULL,
    NextDepartureDate DATE NOT NULL,
    Carrier VARCHAR(255) NOT NULL,
    MinimumContainersNeeded INT,
    PRIMARY KEY (VesselName)
);

CREATE TABLE ShippedContainers(
     Container_ID INT NOT NULL AUTO_INCREMENT,
     ShipmentDate DATE NOT NULL,
     Destination VARCHAR(255) NOT NULL,
     OrderNumber INT NOT NULL,
     VesselName VARCHAR(255) NOT NULL,
     quantity INT,
     totalcost FLOAT(8,2),
     PRIMARY KEY (Container_ID),
     FOREIGN KEY (OrderNumber) REFERENCES SalesOrders(OrderNumber),
     FOREIGN KEY (VesselName) REFERENCES ShipmentVessels(VesselName)
);



DELIMITER // --How many Containers did they sell on a year?
CREATE PROCEDURE GetContainersSoldOnYear(YearRequested INT)
    BEGIN
        SELECT COUNT(Container_ID)
        FROM ShippedContainers
        WHERE ShipmentDate > date_sub(YearRequested, INTERVAL 1 YEAR);
    END //
DELIMITER ;

DELIMITER // -- Total Sales by Customer for a period of time.
CREATE PROCEDURE GetSalesOrdersPerCustomer(TimePeriod_1 DATE, TimePeriod_2 DATE)
    BEGIN
        SELECT Customer_ID, COUNT(OrderNumber) as TotalSales
        FROM SalesOrders
        WHERE OrderDate BETWEEN TimePeriod_1 AND TimePeriod_2
        GROUP BY Customer_ID;
    END //
DELIMITER ;

DELIMITER // -- How much of each product we sold in general
CREATE PROCEDURE GetTotalProductsSold()
        SELECT Product_ID, SUM(quantity) as TotalProducts
        FROM SalesOrders
        GROUP BY Product_ID;
    END //
DELIMITER ;

DELIMITER // -- How much of each product we sold to each vessel.
CREATE PROCEDURE GetTotalProductsSoldToEachVessel()
    BEGIN
        SELECT SalesOrders.Product_ID, sc.VesselName, SUM(SalesOrders.quantity) as TotalProducts  
        FROM SalesOrders
        JOIN ShippedContainers sc ON SalesOrders.OrderNumber = sc.OrderNumber
        WHERE sc.Destination IN ('*')
        GROUP BY sc.VesselName, Product_ID;
    END //
DELIMITER ;

DELIMITER // -- How much of each product we sold to each destination.
CREATE PROCEDURE GetTotalProductsSoldToEachDestination()
        SELECT SalesOrders.Product_ID, sc.Destination, SUM(SalesOrders.quantity) as TotalProducts 
        FROM SalesOrders
        JOIN ShippedContainers sc ON SalesOrders.quantity = sc.OrderNumber
        WHERE sc.Destination IN ('*')
        GROUP BY SalesOrders.Product_ID,sc.Destination;
    END //
DELIMITER ;

DELIMITER // -- How much of each product we sold to each address.
CREATE PROCEDURE GetTotalProductsSoldToEachAddress()
        SELECT Product_ID, Customer_Address, SUM(quantity) as TotalProducts 
        FROM SalesOrders
        WHERE Customer_Address IN ('*')
        GROUP BY Customer_Address, Product_ID;
    END //
DELIMITER ;
    


CALL GetContainersSoldOnYear(2022); --How many Containers did they sell on a year?
CALL GetSalesOrdersPerCustomer(now(), date_sub(now(), INTERVAL 3 YEAR)); -- Total Sales by Customer for a period of time. Example does 3 years
CALL GetTotalProductsSold(); -- How much of each product we sold overall.
CALL GetTotalProductsSoldToEachVessel(); -- How much of each product we sold to each vessel.
CALL GetTotalProductsSoldToEachDestination(); -- How much of each product we sold to each destination.
CALL GetTotalProductsSoldToEachAddress(); -- How much of each product we sold to each address.
SHOW TABLES;    -- What are the tables I created?
