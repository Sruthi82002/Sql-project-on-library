drop database library_management;
create database library_management;
use library_management;

-- library branch
create table lib_branch(
library_branch_BranchID INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
library_branch_BranchName varchar(100) NOT NULL,
library_branch_BranchAddress varchar(100));
select * from lib_branch;

-- borrower
create table borrower(
borrower_CardNo INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
borrower_BorrowerName varchar(100) Not NULL,
borrower_BorrowerAddress varchar(100),
borrower_BorrowerPhone varchar(20)); 
select * from borrower; 

-- publisher
create table publisher(
publisher_PublisherName varchar(50) PRIMARY KEY,
publisher_PublisherAddress varchar(100) NOT NULL,
publisher_PublisherPhone varchar(20));
select * from publisher;

-- books 
create table books(
book_BookID INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
book_Title varchar(100) NOT NULL, 
book_PublisherName varchar(100),
FOREIGN KEY (book_PublisherName)
REFERENCES publisher(publisher_PublisherName)
ON DELETE CASCADE
ON UPDATE CASCADE);
select * from books; 

-- authors
create table authors(
book_authors_BookID INT,
book_authors_AuthorName varchar(100) NOT NULL,
FOREIGN KEY (book_authors_BookID)
REFERENCES books(book_BookID)
ON DELETE CASCADE
ON UPDATE CASCADE);
ALTER table authors
ADD column book_authors_AuthorID INT AUTO_INCREMENT PRIMARY KEY;
select * from authors;

-- copies 
create table copies(
book_copies_BookID INT,
book_copies_BranchID INT,
book_copies_No_Of_Copies INT,
FOREIGN KEY (book_copies_BookID)
REFERENCES books(book_BookID),
FOREIGN KEY (book_copies_BranchID)
REFERENCES lib_branch(library_branch_BranchID)
ON DELETE CASCADE
ON UPDATE CASCADE);
ALTER table copies
ADD column book_copies_CopiesID INT AUTO_INCREMENT PRIMARY KEY;
select * from copies;

-- loans
create table loans(
-- book_loans_LoansID INT AUTO_INCREMENT PRIMARY KEY,
book_loans_BookID INT,
book_loans_BranchID INT,
book_loans_CardNo INT,
book_loans_DateOut DATE,
book_loans_DueDate DATE,
FOREIGN KEY (book_loans_BookID)
REFERENCES books(book_BookID),
FOREIGN KEY (book_loans_BranchID)
REFERENCES lib_branch(library_branch_BranchID),
FOREIGN KEY (book_loans_CardNo)
REFERENCES borrower(borrower_CardNo)
ON DELETE CASCADE
ON UPDATE CASCADE);
ALTER table loans
ADD column book_loans_LoansID INT AUTO_INCREMENT PRIMARY KEY;
select * from loans;

-- How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
select sum(book_copies_No_Of_Copies) as no_of_copies
from copies as c
inner join books as b
join lib_branch as l
where b.book_title = "The Lost Tribe"
and l.library_branch_BranchName = "Sharpstown"; 

-- How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select count(*) as no_of_copies,b.book_title,l.library_branch_BranchName
from books as b
inner join lib_branch as l
where b.book_title = "The Lost Tribe"
group by l.library_branch_BranchName; 

-- Retrieve the names of all borrowers who do not have any books checked out.
select borrower_BorrowerName
from borrower 
left join loans on borrower.borrower_CardNo = loans.book_loans_CardNo
where loans.book_loans_CardNo is null; 

/* For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, 
retrieve the book title, the borrower's name, and the borrower's address.*/
SELECT b.book_Title,br.borrower_BorrowerName , br.borrower_BorrowerAddress,lb.library_branch_BranchName
FROM books as b
JOIN loans as l on b.book_BookID = l.book_loans_BookID
JOIN lib_branch as lb on lb.library_branch_BranchID = l.book_loans_BranchID
JOIN borrower as br on br.borrower_CardNo = l.book_loans_CardNo
WHERE book_loans_DueDate = '2/3/18'
AND library_branch_BranchName = 'Sharpstown'; 

-- For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
SELECT library_branch_BranchName as branch_name, COUNT(*) as total_loans
FROM loans
JOIN lib_branch ON loans.book_loans_BranchID = lib_branch.library_branch_BranchID
JOIN books ON loans.book_loans_BookID = books.book_BookID
GROUP BY branch_name;

-- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
SELECT b.borrower_BorrowerName, b.borrower_BorrowerAddress,COUNT(c.book_BookID) as num_checkouts
FROM borrower as b
join loans as l on b.borrower_CardNo = l.book_loans_CardNo
join books as c on l.book_loans_BookID = c.book_BookID
group by b.borrower_BorrowerName, b.borrower_BorrowerAddress
having num_checkouts>5; 

-- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
select b.book_Title,c.book_copies_No_Of_Copies as no_of_copies,l.library_branch_BranchName
from books as b
join authors as a on b.book_BookID = a.book_authors_BookID 
join copies as c on b.book_BookID = c.book_copies_BookID
join lib_branch as l on l.library_branch_BranchID = c.book_copies_BranchId  
where a.book_authors_AuthorName = "Stephen King" and l.library_branch_BranchName = "Central";




