use Library
-- Views – Frontend Integration Support
--ViewPopularBooks
--Books with average rating > 4.5 + total loans
create view ViewPopularBooks as
select b.bookId, b.title,
 AVG(r.rating) as average_rating,
 COUNT(DISTINCT l.loan_date) as total_loans
from book b
LEFT JOIN review r on b.bookId = r.bookId
LEFT JOIN loan l on b.bookId = l.bookId
GROUP BY  b.bookId, b.title
HAVING AVG(r.rating) > 4.5;

--ViewMemberLoanSummary Member loan count + total fines paid
create view ViewMemberLoanSummary as select 
m.MemberID, m.Fullname,
COUNT(l.loan_date) as loan_count,
ISNULL(SUM(p.amount), 0) as total_fines_paid
FROM Members m
LEFT JOIN loan l on m.MemberID = l.MemberID
LEFT JOIN payments p on l.paymentID = p.paymentID
GROUP BY m.MemberID, m.Fullname;

--ViewAvailableBooks Available books grouped by genre, ordered by price 
create view ViewAvailableBooks as 
select genre,title,price from book where availability = 1

select * 
from ViewAvailableBooks
ORDER BY genre, price;
--ViewLoanStatusSummary Loan stats (issued, returned, overdue) per library

create view  ViewLoanStatusSummary as
select  lib.LibararyID,lib.name as LibraryName,lo.status,
COUNT(*) AS TotalLoans from loan lo
JOIN book b on b.bookId = lo.bookId
JOIN  libarary lib on lib.LibararyID = b.LibararyID
GROUP BY lib.LibararyID, lib.name, lo.status;

--ViewPaymentOverview Payment info with member, book, and status
create view ViewPaymentOverview as
select p.paymentID,p.payment_date,p.amount, p.method,
m.Fullname as MemberName,
b.title as BookTitle,
l.status as LoanStatus
from payments p
JOIN loan l on p.paymentID = l.paymentID
JOIN Members m on l.MemberID = m.MemberID
JOIN book b on l.bookId = b.bookId;

--
