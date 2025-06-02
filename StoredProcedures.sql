--4. Stored Procedures – Backend Automation \
use Library
--sp_MarkBookUnavailable(BookID) Updates availability after issuing
create procedure sp_MarkBookUnavailable
@BookID int
as begin
update book
set availability = 0
WHERE bookId = @BookID;
END;

EXEC sp_MarkBookUnavailable @BookID = 1;

--sp_UpdateLoanStatus() Checks dates and updates loan statuses
create procedure  sp_UpdateLoanStatus
as begin
UPDATE loan
set status = 'Returned'
where return_date IS NOT NULL AND return_date <= due_date; UPDATE loan
set status = 'Overdue'
where return_date IS NOT NULL AND return_date > due_date;
UPDATE loan
set status = 'Overdue'
where return_date IS NULL AND due_date < GETDATE();
UPDATE loan
set status = 'Issued'
where return_date IS NULL AND due_date >= GETDATE();
END;

--sp_RankMembersByFines() Ranks members by total fines paid
ALTER TABLE payments
ADD MemberID INT;

ALTER TABLE payments
ADD CONSTRAINT FK_Payments_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID);
-------------------------------
create procedure sp_RankMembersByFines
as begin
select m.MemberID,m.Fullname,
SUM(p.amount) AS TotalFinesPaid,
RANK() OVER (ORDER BY SUM(p.amount) DESC) as RankByFines --rank ترتب 
from Members m
JOIN payments p ON m.MemberID = p.MemberID
GROUP BY m.MemberID, m.Fullname
ORDER BY TotalFinesPaid DESC;
END;

EXEC sp_RankMembersByFines;
