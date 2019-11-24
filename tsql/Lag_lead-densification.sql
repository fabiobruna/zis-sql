/** 
 *   @Source Lag_lead-densification.sql
 *   @Description 
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/
 */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

USE AdventureWorksDW
GO

SELECT * FROM EmployeeSalesByMonth
ORDER BY Employee, Year, Month
GO

-- This answer doesn't make sense
-- not all months are present!
SELECT  Employee,
        [Year] ,
        [Month] ,
        EmployeeTotal AS SalesThisMonth,
        LAG(EmployeeTotal, 1, 0.00)	OVER (PARTITION BY Employee
										  ORDER BY [Year], [Month]) AS SalesLastMonth ,
        LAG(EmployeeTotal, 3, 0.00) OVER (PARTITION BY Employee
                                          ORDER BY [Year], [Month]) AS SalesThreeMonthsAgo
FROM EmployeeSalesByMonth
WHERE Employee = 272
ORDER BY Employee, [Year], [Month];
GO

SET NOCOUNT ON;

use tempdb
go

-- GetNums function
IF OBJECT_ID('dbo.GetNums') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
    L1   AS(SELECT 1 AS c FROM L0 AS A, L0 AS B),
    L2   AS(SELECT 1 AS c FROM L1 AS A, L1 AS B),
    L3   AS(SELECT 1 AS c FROM L2 AS A, L2 AS B),
    L4   AS(SELECT 1 AS c FROM L3 AS A, L3 AS B),
    L5   AS(SELECT 1 AS c FROM L4 AS A, L4 AS B),
    Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
  SELECT TOP(@n) n FROM Nums ORDER BY n;
GO

SET NOCOUNT OFF;

use AdventureWorksDWDenali
go

DROP TABLE #allMonths

DECLARE 
 @startdt AS DATE = '20050701',
 @enddt   AS DATE = '20080731'
 
SELECT DATEADD(month, n-1, @startdt) AS dt, EmployeeKey AS Employee INTO #allMonths
FROM tempdb.dbo.GetNums(DATEDIFF(month, @startdt, @enddt) + 1) AS Nums
CROSS JOIN 
(
SELECT DISTINCT EmployeeKey 
FROM dbo.FactResellerSales 
) AS A;  
GO

select * from #allMonths

-- densified (missing months filled in with zeros using OUTER APPLY)
-- right answer
WITH SalesByMonth AS
(
SELECT Employee,
       DATEPART(yyyy,dt) as Year,
	   DATEPART(MONTH,dt) as Month,
	   ISNULL(EmployeeTotal, 0) as EmployeeTotal
FROM #allMonths m
OUTER APPLY (
SELECT  EmployeeTotal
FROM    EmployeeSalesByMonth e 
WHERE m.Employee = e.Employee   
 AND    DATEPART(yyyy,m.dt) = e.[Year]
 AND    DATEPART(mm,m.dt) = e.[Month]
) AS t
)
SELECT  Employee,
        [Year] ,
        [Month] ,
        EmployeeTotal AS SalesThisMonth,
        LAG(EmployeeTotal, 1, 0.00) OVER (PARTITION BY Employee
										  ORDER BY [Year], [Month]) AS SalesLastMonth ,
        LAG(EmployeeTotal, 3, 0.00) OVER (PARTITION BY Employee
                                          ORDER BY [Year], [Month]) AS SalesThreeMonthsAgo
FROM SalesByMonth
ORDER BY Employee,
        [Year],
        [Month];
GO

-- rolling total, average
-- wrong answer, this is the last 3 months this salesperson sold something
-- not the last three calendar months
SELECT  Employee,
        [Year] ,
        [Month] ,
        EmployeeTotal AS SalesThisMonth,
        COUNT(*) OVER (PARTITION BY Employee ORDER BY [Year], [Month] ROWS 2 PRECEDING) AS NumberOfMonths,
        SUM(EmployeeTotal) OVER (PARTITION BY Employee ORDER BY [Year], [Month] ROWS 2 PRECEDING) AS ThreeMonthTotal,
        AVG(EmployeeTotal) OVER (PARTITION BY Employee ORDER BY [Year], [Month] ROWS 2 PRECEDING) AS ThreeMonthAverage
FROM EmployeeSalesByMonth
WHERE Employee = 272
ORDER BY Employee, [Year], [Month];
GO

/*
What we really want is this, which SQL Server 2012 does not support

SELECT  Employee,
        [Year] ,
        [Month] ,
        EmployeeTotal AS SalesThisMonth,
        COUNT(*) OVER (PARTITION BY Employee ORDER BY [Year], [Month] RANGE INTERVAL '02' MONTH PRECEDING) AS NumberOfMonths,
        SUM(EmployeeTotal) OVER (PARTITION BY Employee ORDER BY [Year], [Month] RANGE INTERVAL '02' MONTH PRECEDING) AS ThreeMonthTotal,
        AVG(EmployeeTotal) OVER (PARTITION BY Employee ORDER BY [Year], [Month] RANGE INTERVAL '02' MONTH PRECEDING) AS ThreeMonthAverage
FROM EmployeeSalesByMonth
WHERE Employee = 272
ORDER BY Employee, [Year], [Month];
GO
*/

-- densified table as CTE, now you get the "right" answer with rows
-- However, if employee 272 was hired in 08/2005, the first few answers are a little low
WITH SalesByMonth AS
(
SELECT Employee,
       DATEPART(yyyy,dt) as Year,
	   DATEPART(MONTH,dt) as Month,
	   ISNULL(EmployeeTotal, 0) as EmployeeTotal
FROM #allMonths m
OUTER APPLY (
SELECT  EmployeeTotal
FROM    EmployeeSalesByMonth e 
WHERE m.Employee = e.Employee   
 AND    DATEPART(yyyy,dt) = [Year]
 AND    DATEPART(mm,dt) = [Month]
) AS t
)
SELECT  Employee,
        [Year] ,
        [Month] ,
        EmployeeTotal AS SalesThisMonth,
        COUNT(*) OVER (PARTITION BY Employee ORDER BY [Year], [Month] ROWS 2 PRECEDING) AS NumberOfMonths,
		SUM(EmployeeTotal) OVER (PARTITION BY Employee ORDER BY [Year], [Month] ROWS 2 PRECEDING) AS ThreeMonthTotal,
        AVG(EmployeeTotal) OVER (PARTITION BY Employee ORDER BY [Year], [Month] ROWS 2 PRECEDING) AS ThreeMonthAverage
FROM SalesByMonth
WHERE Employee = 272
ORDER BY Employee,
        [Year],
        [Month];
GO

-- finally, save densified table
WITH SalesByMonth AS
(
SELECT Employee,
       DATEPART(yyyy,dt) as Year,
	   DATEPART(MONTH,dt) as Month,
	   ISNULL(EmployeeTotal, 0) as EmployeeTotal
FROM #allMonths m
OUTER APPLY (
SELECT  EmployeeTotal
FROM    EmployeeSalesByMonth e 
WHERE m.Employee = e.Employee   
 AND    DATEPART(yyyy,dt) = [Year]
 AND    DATEPART(mm,dt) = [Month]
) AS t
)
select * into dbo.SalesByPersonByMonthAll from SalesByMonth

