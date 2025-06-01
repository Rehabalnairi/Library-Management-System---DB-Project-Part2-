use Library
--List all overdue loans with member name, book title, due date
ALTER TABLE loan
ADD bookId INT;

ALTER TABLE loan
ADD CONSTRAINT FK_loan_book
FOREIGN KEY (bookId) REFERENCES book(bookId);

select m.Fullname As 
MemberName,
b.title as BookTitle,
l.due_date 
from loan l join Members m on l.MemberID = m.MemberID
join book b on b.bookId = l.bookId
where l.status = 'Overdue';

---List books not available 
select * from book
select  bookId,title,genre, status from book where availability=0;

-- Members who borrowed >2 books
select m.MemberID,m.Fullname,
COUNT (l.loan_date) as TotalBooksBorrowed
from Members m 
JOIN loan l ON m.MemberID = l.MemberID
GROUP BY 
    m.MemberID, m.Fullname
HAVING 
 COUNT(l.loan_date) > 2;

 ---Show average rating per book 
 select b.title as BookTitle,
 AVG (r.rating) as AverageRating from book b
 join review r on b.bookId = r.bookId
 group by b.title

 -- Count books by genre  
 select genre,COUNT(*) as BookCount from book
 group by genre;

 --List members with no loans  
select m.MemberID, m.Fullname, m.email, m.membership_date
from 
Members m
LEFT JOIN loan l on m.MemberID = l.MemberID
where 
    l.MemberID IS NULL;
--→ Total fine paid per member  
select m.MemberID,m.Fullname,
SUM(p.amount) as TotalFinePaid
from Members m
JOIN loan l on m.MemberID = l.MemberID
JOIN 
payments p on l.paymentID = p.paymentID
group by m.MemberID, m.Fullname;

-- Reviews with member and book info  
ALTER TABLE review
ADD MemberID INT;

ALTER TABLE review
ADD CONSTRAINT FK_review_member
FOREIGN KEY (MemberID) REFERENCES Members(MemberID);

select r.rating,r.rating,r.comments,
m.Fullname as Reviewer,b.title as BookTitle  from review r
JOIN Members m on r.MemberID = m.MemberID
JOIN book b on r.bookId =b.bookId;

-- List top 3 books by number of times they were loaned 

ALTER TABLE loan
ALTER COLUMN bookId INT;

ALTER TABLE loan
ADD CONSTRAINT FK_loan_book
FOREIGN KEY (bookId) REFERENCES book(bookId);

select b.title,
COUNT(*) as LoanCount
from loan l
JOIN book b on l.bookId = b.bookId
GROUP BY b.title
ORDER BY LoanCount DESC

--Retrieve full loan history of a specific member including book title, 
--loan & return dates
select b.title as BookTitle,l.loan_date,l.return_date
from  loan l
JOIN book b on l.bookId = b.bookId
where l.MemberID = 1
ORDER BY l.loan_date DESC;
--Show all reviews for a book with member name and comments
select * from review
select m.Fullname as MemberName,r.comments,r.rating,r.review_date
from review r
JOIN Members m on r.MemberID = m.MemberID
where r.bookId = 3
ORDER BY r.review_date DESC;

--List all staff working in a given library 
select s.staffID,s.Fullname,s.Fullname,l.name as LibraryName 
from libarary l 
join staff s on l.staff_ID =s.staffID
where l.LibararyID =1;

--Show books whose prices fall within a given range 
--(8-10)
select bookId,title,genre,price from book
where price between 8 and 10;
--List all currently active loans (not yet returned) with member and book info 
select l.loan_date,l.due_date,
m.Fullname as MemberName,
b.title as BookTitle,l.status
from loan l
JOIN  Members m on l.MemberID = m.MemberID
JOIN book b on l.bookId = b.bookId
where l.return_date IS NULL
ORDER BY l.due_date ASC;

-- List members who have paid any fine 
select m.MemberID,m.Fullname,m.email
from Members m
where m.MemberID IN (
SELECT DISTINCT l.MemberID
from loan l JOIN payments p on l.paymentID = p.paymentID
where p.amount > 0);

--List books that have never been reviewed 
select b.bookId,b.title,b.genre,b.price
from book b
LEFT JOIN review r on b.bookId = r.bookId
where r.bookId IS NULL;

--Show a member’s loan history with book titles and loan status.
select * from Members
select m.Fullname as MemberName,b.title as BookTitle,
l.loan_date,l.due_date,l.return_date,l.status
from loan l
JOIN Members m on l.MemberID = m.MemberID
JOIN book b on l.bookId = b.bookId
where m.MemberID = 3
ORDER BY l.loan_date DESC;

--→List all members who have never borrowed any book. 
select m.MemberID, m.Fullname, m.email,m.membership_date
from Members m
LEFT JOIN loan l on m.MemberID = l.MemberID
where l.MemberID IS NULL;

--List books that were never loaned. 
select b.bookId,b.title,b.genre,b.price,b.status
from book b
LEFT JOIN 
loan l on b.bookId = l.bookId
where l.bookId IS NULL;
--List all payments with member name and book title.
select  
p.paymentID,p.payment_date, p.amount,p.method,
m.Fullname as MemberName, b.title as BookTitle
from payments p
JOIN loan l on p.paymentID = l.paymentID
JOIN  Members m on l.MemberID = m.MemberID
JOIN book b on l.bookId = b.bookId;

-- List all overdue loans with member and book details. 
select l.loan_date,l.due_date,l.return_date,l.status,
m.Fullname as MemberName,
b.title as BookTitle
from loan l
JOIN  Members m on l.MemberID = m.MemberID
JOIN book b on l.bookId = b.bookId
where l.status = 'Overdue';
--Show how many times a book has been loaned.
select b.bookId,b.title,
COUNT(l.loan_date) as TimesLoaned
from  book b
LEFT JOIN loan l on b.bookId = l.bookId
GROUP BY b.bookId, b.title
ORDER BY TimesLoaned DESC;

--Get total fines paid by a member across all loans. 
select m.MemberID, m.Fullname,
SUM(p.amount) as TotalFinesPaid
from Members m
JOIN  loan l on m.MemberID = l.MemberID
JOIN payments p on l.paymentID = p.paymentID
GROUP BY m.MemberID, m.Fullname
ORDER BY TotalFinesPaid DESC;

-- Show count of available and unavailable books in a library. 
select  l.name as LibraryName, b.availability,
COUNT(*) as BookCount
from libarary l
JOIN  book b on l.LibararyID = b.LibararyID
GROUP BY l.name, b.availability
ORDER BY l.name;

-- Return books with more than 5 reviews and average rating > 4.5.
select b.title,
COUNT(r.rating) as ReviewCount,
AVG(r.rating) as AverageRating
from book b
JOIN review r on b.bookId = r.bookId
GROUP BY  b.bookId, b.title
HAVING COUNT(r.rating) > 5 AND AVG(r.rating) > 4.5
ORDER BY AverageRating DESC;

