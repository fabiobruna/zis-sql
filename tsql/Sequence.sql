/** 
 *   @Source Sequence.sql
 *   @Description 
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/
 */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)


/*
|| Returns the last identity value inserted into an identity column in the same scope. 
|| A scope is a module: a stored procedure, trigger, function, or batch. 
|| Therefore, if two statements are in the same stored procedure, function, or batch, 
|| they are in the same scope.
*/

USE AdventureWorksDW

--Old school
DECLARE @OrderID INT

BEGIN TRANSACTION

INSERT Orders (CustomerID) VALUES ('ALFKI')

SET @OrderID = SCOPE_IDENTITY()

INSERT [Order Details] (OrderID, ProductID, Quantity, UnitPrice, Discount) 
VALUES (@OrderID, 1, 1, 1, 0)

COMMIT --Of Course, do error trapping























--New possibility

DECLARE @OrderID INT = NEXT VALUE FOR DemoSequence;

BEGIN TRANSACTION

INSERT Orders (OrderID, ...) VALUES (@OrderID, ...)

INSERT [Order Details] (OrderID, ProductID, Quantity, UnitPrice, Discount) VALUES (@OrderID, 1, 1, 1, 0)

COMMIT







CREATE SEQUENCE DemoSequence
START WITH 1
INCREMENT BY 1;


SELECT VALUE FOR DemoSequence; -- use system tables
SELECT NEXT VALUE FOR DemoSequence;