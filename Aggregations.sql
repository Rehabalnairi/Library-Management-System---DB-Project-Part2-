use Library
-- Aggregation Functions – Dashboard Reports
-- Total fines per member 
select m.MemberID,m.Fullname,
SUM(DATEDIFF(DAY, l.due_date, l.return_date) * 0.5) as TotalFines
from Members m
JOIN loan l on m.MemberID = l.MemberID
where l.return_date > l.due_date
GROUP BY m.MemberID, m.Fullname;

--Most active libraries (by loan count)
select lib.LibararyID,lib.name AS LibraryName,
COUNT(l.loan_date) as TotalLoans
from libarary lib
JOIN book b on lib.LibararyID = b.LibararyID
JOIN loan l on l.bookId = b.bookId
GROUP BY lib.LibararyID, lib.name
ORDER BY TotalLoans DESC;

--Avg book price per genre 
select genre,AVG(price) AS AvgPrice
from book
GROUP BY genre;

--Top 3 most reviewed books
select TOP 3 b.title,
COUNT(r.rating) as ReviewCount
from book b
JOIN review r on b.bookId = r.bookId
GROUP BY b.title
ORDER BY ReviewCount DESC;

--Library revenue report
select l.LibararyID,l.name as LibraryName,
SUM(p.amount) as TotalRevenue
from libarary l
JOIN book b on l.LibararyID = b.LibararyID
JOIN loan lo on lo.MemberID IS NOT NULL
JOIN  payments p on p.paymentID = lo.paymentID
where b.bookId = lo.bookId
GROUP BY l.LibararyID, l.name
ORDER BY TotalRevenue DESC;

--Member activity summary (loan + fines) 
select m.MemberID,m.Fullname,
 COUNT(lo.loan_date) as LoanCount,
 ISNULL(SUM(p.amount), 0) as TotalFines
from Members m
LEFT JOIN loan lo on m.MemberID = lo.MemberID
LEFT JOIN payments p on lo.paymentID = p.paymentID
GROUP BY m.MemberID, m.Fullname
ORDER BY LoanCount DESC, TotalFines DESC;
