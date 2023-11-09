USE product_trader;
-- -------------------------------------------------------------------------------------
-- Create Analytical Data Layer
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS AnalyticalSales;
CREATE TABLE AnalyticalSales (
    Year INT,
    Quarter INT,
    Month INT,
    Country VARCHAR(255),
    ProductID INT,
    ProductName VARCHAR(255),
    CategoryName VARCHAR(255),
    TotalSales DECIMAL(10, 2),
    EmployeeID INT,
    FirstName VARCHAR(255),
    LastName VARCHAR(255)
);

-- -------------------------------------------------------------------------------------
-- Create Trigger CheckChangesBeforeLoad
-- -------------------------------------------------------------------------------------
DROP TRIGGER IF EXISTS CheckChangesBeforeLoad;

DELIMITER //
CREATE TRIGGER CheckChangesBeforeLoad
BEFORE INSERT ON AnalyticalSales
FOR EACH ROW
BEGIN
    IF NEW.TotalSales < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TotalSales must be non-negative';
    END IF;
END;
//

DELIMITER ;

-- -------------------------------------------------------------------------------------
-- Store Procedure and Load data into AnalcalSales table:
-- -------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS LoadAnalyticalSales;
DELIMITER //
CREATE PROCEDURE LoadAnalyticalSales()
BEGIN

    INSERT INTO AnalyticalSales (Year, Quarter, Month, ProductID, ProductName, CategoryName, TotalSales, Country, EmployeeID, LastName, FirstName)
    SELECT 
        YEAR(o.OrderDate) AS Year,
        QUARTER(o.OrderDate) AS Quarter,
        MONTH(o.OrderDate) AS Month,
        p.ProductID,
        p.ProductName,
        cat.CategoryName,
        SUM(od.Quantity * od.UnitPrice) AS TotalSales,
        c.Country,
        em.EmployeeID,
        em.LastName,
        em.FirstName
    FROM Products p
    INNER JOIN Categories cat ON p.CategoryID = cat.CategoryID 
    INNER JOIN OrderDetails od ON p.ProductID = od.ProductID
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID
    INNER JOIN Employees em ON em.EmployeeID = o.EmployeeID
    GROUP BY YEAR(o.OrderDate), QUARTER(o.OrderDate), MONTH(o.OrderDate), p.ProductID, c.Country, em.EmployeeID, em.LastName, em.FirstName;


END //

DELIMITER ;

-- Test Procedure:
CALL LoadAnalyticalSales();
SELECT * FROM AnalyticalSales;

-- -------------------------------------------------------------------------------------
-- Create an event which updates the AnalyticalSales every hour and the event will be ended after 12hour
-- -------------------------------------------------------------------------------------
SET GLOBAL event_scheduler = ON;
DROP EVENT IF EXISTS UpdateAnalyticalSales;

DELIMITER $$

CREATE EVENT UpdateAnalyticalSales
ON SCHEDULE EVERY 1 HOUR 
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 12 HOUR
DO
	BEGIN
		INSERT INTO messages SELECT CONCAT('event:',NOW());
    		CALL LoadAnalyticalSales();
	END$$
DELIMITER ;

-- Show event
SHOW EVENTS;



