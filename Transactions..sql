use Library
--Transactions – Ensuring Consistency
--Real-world transactional flows: 
--Borrowing a book (loan insert + update availability)
DECLARE @MemberID INT = 1;  
DECLARE @BookID INT = 3;     
DECLARE @PaymentID INT = 2;    
BEGIN TRANSACTION;
BEGIN TRY
 INSERT INTO loan (loan_date, due_date, return_date, status, MemberID, paymentID)
 VALUES (GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, 'Issued', @MemberID, @PaymentID);
UPDATE book
SET availability = 0
WHERE bookId = @BookID;
COMMIT TRANSACTION;
PRINT 'Book borrowed successfully.';
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
PRINT 'Error occurred while borrowing the book.';
END CATCH;

-- Returning a book (update status, return date, availability)
ALTER TABLE loan
ADD loanID INT IDENTITY(1,1) PRIMARY KEY;

DECLARE @LoanID INT = 1;   
DECLARE @BookID INT = 3;   
BEGIN TRANSACTION;
BEGIN TRY
UPDATE loan
SET return_date = GETDATE(),
status = 'Returned'
WHERE loan_date IS NOT NULL
AND return_date IS NULL
AND loanID = @LoanID;
UPDATE book
SET availability = 1
WHERE bookId = @BookID;
COMMIT TRANSACTION;
PRINT 'Book returned successfully.';
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
PRINT 'Error occurred while returning the book.';
END CATCH;

--Registering a payment (with validation) 
select* from payments
CREATE PROCEDURE sp_RegisterPayment
@MemberID INT,
 @Amount DECIMAL(10,2)
as BEGIN
IF @Amount <= 0
BEGIN
PRINT 'Error: Payment amount must be greater than 0.';
RETURN;
END
BEGIN TRANSACTION;
BEGIN TRY
INSERT INTO payment (MemberID, amount, payment_date)
VALUES (@MemberID, @Amount, GETDATE());
COMMIT TRANSACTION;
PRINT 'Payment registered successfully.';
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
PRINT 'Error occurred while registering payment.';
 END CATCH;
END;

-- Batch loan insert with rollback on failure
select* from loan
CREATE TYPE LoanTableType AS TABLE (
    MemberID INT,
    BookID INT,
    PaymentID INT
);

IF TYPE_ID('LoanTableType') IS NULL
BEGIN
    CREATE TYPE LoanTableType AS TABLE (
        MemberID INT,
        BookID INT,
        PaymentID INT
    );
END
GO
CREATE PROCEDURE sp_BatchLoanInsert
@Loans LoanTableType READONLY
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY
insert into  loan (loan_date, due_date, return_date, status, MemberID, paymentID)
select GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, 'Issued', MemberID, PaymentID
from @Loans;
UPDATE b
SET availability = 0
from book b
INNER JOIN @Loans l ON b.bookId = l.BookID;
COMMIT TRANSACTION;
PRINT 'Batch loan insert completed successfully.';
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
PRINT 'Error occurred. Transaction rolled back.';
THROW;
END CATCH
END;




