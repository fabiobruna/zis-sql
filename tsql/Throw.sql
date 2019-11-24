/** 
 *   @Source Throw.sql
 *   @Description 
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/
 */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

--Code thanks to Henry He
--http://www.codeproject.com/Articles/265760/Using-SQL-Server-2011-T-SQL-New-Features
USE AdventureWorksDW
GO
--The old way: Note the raiserror within the Catch
BEGIN TRY
	BEGIN TRANSACTION --Start the transaction

	-- Delete the Customer
	DELETE FROM Customers
	WHERE CustomerID = 'CACTU'

	-- Commit the change
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	-- There is an error
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	-- Raise an error with the details of the exception
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
	SELECT @ErrMsg = ERROR_MESSAGE(),
		@ErrSeverity = ERROR_SEVERITY()

	RAISERROR(@ErrMsg, @ErrSeverity, 1)
END CATCH


























--The new way: Note the Throw within the Catch
BEGIN TRY
	BEGIN TRANSACTION -- Start the transaction

	-- Delete the Customer
	DELETE FROM Customers
	WHERE CustomerID = 'CACTU'

	-- Commit the change
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	-- There is an error
	ROLLBACK TRANSACTION

	-- Re throw the exception
	THROW
END CATCH


throw 51000, 'the record does not exist', 1 --severity is always 16!;

sp_addmessage 
	@msgnum=51001
	, @msgtext = 'The number of rows in $s is $i'  --parameterized message
	, @severity = 16
	, @lang = 'us-english' ;

declare @message nvarchar(100);
select @message  = FORMATMESSAGE(51001, 'table1', 5);
throw 51001, @message, 1