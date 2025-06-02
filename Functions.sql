use Library
--Functions – Reusable Logic
--GetBookAverageRating(BookID) Returns average rating of a book 
create Function  GetBookAverageRating (
    @BookID INT
)
RETURNS DECIMAL(4,2)
as
BEGIN
DECLARE @AvgRating DECIMAL(4,2);
SELECT @AvgRating = AVG(CAST(Rating AS DECIMAL(4,2)))
from Review
where BookID = @BookID;
RETURN @AvgRating;
END;
select dbo.GetBookAverageRating(101) as AverageRating;

--GetNextAvailableBook(Genre, Title, LibraryID) Fetches the next available book
CREATE FUNCTION GetNextAvailableBook (
@Genre VARCHAR(20),
@Title VARCHAR(100),
@LibraryID INT
)
RETURNS INT
as BEGIN
DECLARE @NextBookID INT;
select TOP 1 @NextBookID = bookId
from book
where genre = @Genre
AND title = @Title
AND LibararyID = @LibraryID
AND availability = 1
AND status = 'Available'
ORDER BY bookId RETURN @NextBookID;
END;

--CalculateLibraryOccupancyRate(LibraryID) Returns % of books currently issued
CREATE FUNCTION CalculateLibraryOccupancyRate (
    @LibraryID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
DECLARE @TotalBooks INT;
DECLARE @IssuedBooks INT;
DECLARE @Rate DECIMAL(5,2);
SELECT @TotalBooks = COUNT(*)from book
where LibararyID = @LibraryID;
select @IssuedBooks = COUNT(*)
from book b
JOIN loan l on l.bookId = b.bookId
where b.LibararyID = @LibraryID AND l.status = 'Issued';
IF @TotalBooks = 0
SET @Rate = 0; ELSE
SET @Rate = (CAST(@IssuedBooks AS DECIMAL(5,2)) / @TotalBooks) * 100;
RETURN @Rate;
END;

--fn_GetMemberLoanCount Return the total number of loans made by a given member. 
CREATE FUNCTION fn_GetMemberLoanCount (
  @MemberID INT
)
RETURNS INT
AS BEGIN
DECLARE @LoanCount INT;
select @LoanCount = COUNT(*)
from Loans 
where MemberID = @MemberID;
RETURN @LoanCount;
END;

--fn_GetLateReturnDays Return the number of late days for a loan (0 if not 
--late). 
CREATE FUNCTION fn_GetLateReturnDays (
 @LoanID INT
)
RETURNS INT
as BEGIN
DECLARE @LateDays INT;
select @LateDays = 
CASE 
when ReturnDate IS NULL THEN 0
when ReturnDate > DueDate THEN DATEDIFF(DAY, DueDate, ReturnDate)
ELSE 0
END
from Loans
where LoanID = @LoanID;
RETURN ISNULL(@LateDays, 0);
END;

---
--fn_ListAvailableBooksByLibrary Returns a table of available books from a specific 
--library. 
CREATE OR ALTER FUNCTION dbo.fn_ListAvailableBooksByLibrary
(
    @LibraryID INT
)
RETURNS TABLE
AS
RETURN
(
select bookId, ISBN, title, genre, price, availability, status
from dbo.book where LibararyID = @LibraryID
 AND availability = 1  
);

--fn_GetTopRatedBooks Returns books with average rating ≥ 4.5 
CREATE OR ALTER FUNCTION fn_GetTopRatedBooks()
RETURNS TABLE as
RETURN
select b.bookId, b.title, 
ISNULL(AVG(r.rating), 0) as Average
from book b
LEFT JOIN review r ON b.bookId = r.bookId
GROUP BY b.bookId, b.title
HAVING ISNULL(AVG(r.rating), 0) >= 4.5;

--fn_FormatMemberName Returns the full name formatted as "LastName, firstName"CREATE OR ALTER FUNCTION dbo.fn_FormatMemberName
CREATE FUNCTION dbo.fn_FormatMemberName
(
    @MemberID INT
)
RETURNS VARCHAR(200)
as BEGIN
DECLARE @FullName NVARCHAR(100);
DECLARE @FirstName NVARCHAR(100);
DECLARE @LastName NVARCHAR(100);
DECLARE @FormattedName NVARCHAR(200);
select @FullName = Fullname
from dbo.Members where MemberID = @MemberID;
SET @FirstName = LEFT(@FullName, CHARINDEX(' ', @FullName) - 1);
SET @LastName = RIGHT(@FullName, LEN(@FullName) - CHARINDEX(' ', @FullName));
SET @FormattedName = @LastName + ', ' + @FirstName;
RETURN @FormattedName;
END;

select dbo.fn_FormatMemberName(1) as FormattedName;
