use Library
-- Advanced Aggregations – Analytical Insight
select genre,
AVG(price) AS AvgPrice
from book
GROUP BY genre
HAVING AVG(price) > 10;

--- Subqueries for complex logic (e.g., max price per genre)
select genre,title,price
from book b
where price = ( select MAX(price)
from book b2
where b.genre = b2.genre
    );

--Occupancy rate calculations
select l.LibararyID,l.name AS LibraryName,
  COUNT(b.bookId) as TotalBooks,
  SUM(CASE 
  when lo.status = 'Issued' AND lo.return_date IS NULL THEN 1 
  ELSE 0 
  END) as IssuedBooks,
 CAST(SUM(CASE 
 when lo.status = 'Issued' AND lo.return_date IS NULL THEN 1 
 ELSE 0 
 END) * 100.0 / COUNT(b.bookId) as DECIMAL(5,2)) as OccupancyRate
from libarary l
JOIN  book b on l.LibararyID = b.LibararyID
LEFT JOIN  loan lo on lo.bookId = b.bookId 
GROUP BY l.LibararyID, l.name;

--Members with loans but no fine 
select m.MemberID, m.Fullname
from Members m
JOIN loan l on m.MemberID = l.MemberID
LEFT JOIN payments p on l.paymentID = p.paymentID
where p.amount IS NULL
GROUP BY m.MemberID, m.Fullname;

--Genres with high average ratings
select b.genre,AVG(r.rating) as AverageRating
from book b
JOIN  review r on b.bookId = r.bookId
GROUP BY b.genre
HAVING AVG(r.rating) >= 4;
