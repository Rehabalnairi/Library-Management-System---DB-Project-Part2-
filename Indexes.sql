use Library
-- Indexing Strategy – Performance Optimization
--Apply indexes to speed up commonly-used queries:
--Library Table

--Non-clustered on Name → Search by name 
CREATE NONCLUSTERED INDEX idx_library_name
ON libarary (name);

--Non-clustered on Location → Filter by location
CREATE NONCLUSTERED INDEX idx_library_location
ON libarary (location);

SELECT * FROM libarary WHERE name = 'Central Library';
SELECT * FROM libarary WHERE location = 'Muscat';


--Book Table 
-- Clustered on LibraryID, ISBN → Lookup by book in specific library
CREATE CLUSTERED INDEX idx_book_library_isbn
ON book (LibararyID, ISBN);

SELECT * FROM book WHERE LibararyID = 1 AND ISBN = '9780140449136';

--Non-clustered on Genre → Filter by genre 
CREATE NONCLUSTERED INDEX idx_book_genre
ON book (genre);
SELECT * FROM book WHERE genre = 'Fiction';

--Loan Table 
-- Non-clustered on MemberID → Loan history 
CREATE NONCLUSTERED INDEX idx_loan_member
ON loan (MemberID);

-- Non-clustered on Status → Filter by status 
CREATE NONCLUSTERED INDEX idx_loan_status
ON loan (status);

-- Composite index on BookID, LoanDate, ReturnDate → Optimize overdue checks
CREATE NONCLUSTERED INDEX idx_loan_book_loandate_return
ON loan (bookId, loan_date, return_date);

