USE product_trader;

-- CREATE DATA MARTS WHICH HELP TO ANSWER ANALYTICS QUESTIONS
-- -------------------------------------------------------------------------------------
-- 1. Top 10 Countries with the highest sales in 1998
-- -------------------------------------------------------------------------------------
DROP VIEW IF EXISTS Top10Countries1998;
CREATE VIEW Top10Countries1998 AS
SELECT Country, SUM(TotalSales) AS Revenue
FROM AnalyticalSales
WHERE Year = 1998
GROUP BY Country
ORDER BY Revenue DESC
LIMIT 10;

-- Check view:
SELECT * from Top10Countries1998;

-- -------------------------------------------------------------------------------------
-- 2. Top 20 Countries with the highest sales through years and most comsumed products & categories
-- -------------------------------------------------------------------------------------
DROP VIEW IF EXISTS Top20CountriesAllTime;
CREATE VIEW Top20CountriesAllTime AS
SELECT Country, SUM(TotalSales) AS Revenue, ProductName, CategoryName
FROM AnalyticalSales
GROUP BY Country, ProductName, CategoryName
ORDER BY Revenue DESC
LIMIT 20;

-- Check views:
SELECT * FROM Top20CountriesAllTime;

-- -------------------------------------------------------------------------------------
-- 3. Top 3 categories by last quater
-- -------------------------------------------------------------------------------------
DROP VIEW IF EXISTS TopSellingCategoryLastQuarter;
CREATE VIEW TopSellingCategoryLastQuarter AS
SELECT
    Year,
    Quarter,
    CategoryName,
    SUM(TotalSales) AS TotalSales
FROM AnalyticalSales
GROUP BY Year, Quarter, CategoryName
ORDER BY Year DESC, Quarter DESC, TotalSales DESC
LIMIT 3;

-- Check views:
SELECT * FROM TopSellingCategoryLastQuarter;

-- -------------------------------------------------------------------------------------
-- 4. Catergory Sales comparision between Quarter2-1997 and Quarter2-1998
-- -------------------------------------------------------------------------------------
DROP VIEW IF EXISTS CategorySalesChange;

CREATE VIEW CategorySalesChange AS
SELECT
    CategoryName,
    'Q2-1997' AS PreviousYear,
    'Q2-1998' AS CurrentYear,
    SUM(IF(Year = 1997 AND Quarter = 2, TotalSales, 0)) AS PreviousYearSales,
    SUM(IF(Year = 1998 AND Quarter = 2, TotalSales, 0)) AS CurrentYearSales,
    SUM(IF(Year = 1998 AND Quarter = 2, TotalSales, 0)) - SUM(IF(Year = 1997 AND Quarter = 2, TotalSales, 0)) AS SalesChange
FROM AnalyticalSales
GROUP BY CategoryName;

-- Check views:
SELECT * FROM CategorySalesChange ;

-- -------------------------------------------------------------------------------------
-- 5. Top 5 Employees with the best sales of the month
-- -------------------------------------------------------------------------------------
DROP VIEW IF EXISTS Top5EmployeesOfMonth;
CREATE VIEW Top5EmployeesOfMonth AS
SELECT
	Year,
    Month,
    EmployeeID,
    CONCAT(FirstName, ' ', LastName) AS EmployeeName,
    SUM(TotalSales) AS TotalSales
FROM AnalyticalSales
GROUP BY Year, Month, EmployeeID, EmployeeName, TotalSales
ORDER BY Year DESC, Month DESC, TotalSales DESC
LIMIT 5;

-- Check views:
SELECT * FROM Top5EmployeesOfMonth;