-- Triggers – Real-Time Business Logic 
use Library
--trg_UpdateBookAvailability 
--After new loan → set book to unavailable
CREATE TRIGGER trg_UpdateBookAvailability
ON loan
AFTER INSERT
AS
BEGIN
    UPDATE b
    SET b.availability = 0
    FROM book b
    INNER JOIN inserted i ON b.bookId = i.bookId;
END;

INSERT INTO loan (loan_date, due_date, return_date, status, MemberID, paymentID, bookId)
VALUES ('2025-06-02', '2025-06-12', NULL, 'Issued', 2, 1, 1);

SELECT bookId, title, availability FROM book WHERE bookId = 1;

--trg_CalculateLibraryRevenue After new payment → update library revenue
--add revenue
ALTER TABLE libarary
ADD revenue DECIMAL(10, 2) DEFAULT 0;
--add LibararyID into pyment
ALTER TABLE payments
ADD LibararyID INT;
ALTER TABLE payments
ADD CONSTRAINT FK_payments_library FOREIGN KEY (LibararyID) REFERENCES libarary(LibararyID);

CREATE TRIGGER trg_CalculateLibraryRevenue
ON payments
AFTER INSERT
AS
BEGIN
    UPDATE l
    SET l.revenue = l.revenue + i.amount
    FROM libarary l
    JOIN inserted i ON l.LibararyID = i.LibararyID;
END;

--trg_LoanDateValidation Prevents invalid return dates on insert 
CREATE TRIGGER trg_LoanDateValidation
ON loan
INSTEAD OF INSERT
AS
BEGIN
IF EXISTS (
  SELECT 1
  FROM inserted
  where return_date IS NOT NULL
  AND return_date < loan_date
    )
    BEGIN
        RAISERROR('Invalid return_date: cannot be earlier than loan_date.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
	--insert value if the date is courrect
    INSERT INTO loan (loan_date, due_date, return_date, status, MemberID, paymentID, bookId)
    SELECT loan_date, due_date, return_date, status, MemberID, paymentID, bookId
    FROM inserted;
END;
