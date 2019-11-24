/** 
 *   @Source Windowing.sql
 *   @Description 
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/
 */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

-- Thanks to Bob Beauchemin!
USE AdventureWorksDW
GO

-- Average sales over last three months by sales territory
SELECT Sh.SalesTerritoryKey as Territory
     , Sh.Year
     , Sh.Month
	 , Sh.Sales
	 , AVG (Sh.Sales) OVER ( PARTITION BY Sh.SalesTerritoryKey
                             ORDER BY Sh.Year, Sh.Month ASC
                             ROWS 2 PRECEDING ) AS Moving_average
FROM dbo.SalesHistoryTerritory AS Sh
ORDER BY Sh.SalesTerritoryKey, Sh.Year, Sh.Month

-- Average of current, previous and next month
SELECT Sh.SalesTerritoryKey as Territory
     , Sh.Year
     , Sh.Month
	 , Sh.Sales
	 , AVG (Sh.Sales) OVER ( PARTITION BY Sh.SalesTerritoryKey
                             ORDER BY Sh.Year, Sh.Month ASC
                             ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS Moving_average
FROM dbo.SalesHistoryTerritory AS Sh
ORDER BY Sh.SalesTerritoryKey, Sh.Year, Sh.Month

-- -- Cumulative sum
SELECT Sh.SalesTerritoryKey as Territory
     , Sh.Year
     , Sh.Month
	 , Sh.Sales
	 , SUM (Sh.Sales) OVER ( PARTITION BY Sh.SalesTerritoryKey
                             ORDER BY Sh.Year, Sh.Month ASC
                             ROWS UNBOUNDED PRECEDING ) AS Cumulative_sum
FROM dbo.SalesHistoryTerritory AS Sh
ORDER BY Sh.SalesTerritoryKey, Sh.Year, Sh.Month

-- Suppose they are not already totaled by territory
-- Average sales over last three months
-- Grouped, windowed query
SELECT Sh.SalesTerritoryKey as Territory
     , Sh.Year
     , Sh.Month
	 , SUM (Sh.Sales) as Sales
	 , AVG (SUM (Sh.Sales)) OVER ( PARTITION BY Sh.SalesTerritoryKey
                             ORDER BY Sh.Year, Sh.Month ASC
                             ROWS 2 PRECEDING ) AS Cumulative_sum
FROM dbo.SalesHistory AS Sh
GROUP BY Sh.SalesTerritoryKey, Sh.Year, Sh.Month
ORDER BY Sh.SalesTerritoryKey, Sh.Year, Sh.Month

-- Last Month's Sales
SELECT Sh.SalesTerritoryKey as Territory
     , Sh.Year
     , Sh.Month
	 , Sh.Sales
	 , SUM (Sh.Sales) OVER ( PARTITION BY Sh.SalesTerritoryKey
                             ORDER BY Sh.Year, Sh.Month ASC
                             ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) AS Last_Month
FROM dbo.SalesHistoryTerritory AS Sh
ORDER BY Sh.SalesTerritoryKey, Sh.Year, Sh.Month

-- Same as LAG
SELECT Sh.SalesTerritoryKey as Territory
     , Sh.Year
     , Sh.Month
	 , Sh.Sales
	 , LAG (Sh.Sales, 1, NULL) OVER ( PARTITION BY Sh.SalesTerritoryKey
                             ORDER BY Sh.Year, Sh.Month ASC) AS Last_Month
FROM dbo.SalesHistoryTerritory AS Sh
ORDER BY Sh.SalesTerritoryKey, Sh.Year, Sh.Month
GO

-- Difference between this month and first month per-territory
SELECT Sh.SalesTerritoryKey as Territory
     , Sh.Year
     , Sh.Month
	 , Sh.Sales
	 , Sh.Sales - (FIRST_VALUE (Sh.Sales) OVER ( PARTITION BY Sh.SalesTerritoryKey
                             ORDER BY Sh.Year, Sh.Month ASC)) AS Difference_With_FirstMonth
FROM dbo.SalesHistoryTerritory AS Sh
ORDER BY Sh.SalesTerritoryKey, Sh.Year, Sh.Month
GO
