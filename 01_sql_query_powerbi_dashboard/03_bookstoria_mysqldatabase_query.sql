-- ---------------------------------------------------------------------------------------------------------------------
-- ------------------------------------              DATA FOR POWER BI             -------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-- -- export all tables as csv (if needed)

-- SELECT * FROM author INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/author.csv';
-- SELECT * FROM book INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/book.csv';
-- SELECT * FROM bookauthor INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bookauthor.csv';
-- SELECT * FROM bookgenre INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bookgenre.csv';
-- SELECT * FROM bookorder INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bookorder.csv';
-- SELECT * FROM customer INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer.csv';
-- SELECT * FROM edition INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/edition.csv';
-- SELECT * FROM employeeemployee INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/employee.csv';
-- SELECT * FROM genre INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/genre.csv';
-- SELECT * FROM orderplaced INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orderplaced.csv';


-- ---------------------------------------------------------------------------------------------------------------------
-- ------------------------------------          Sales Overview 2018-2023          -------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


-- -- total sales in eur (rounded amount)
SELECT ROUND(SUM(orderplaced.amount_eur),0) AS 'Total Sales in EUR'
FROM orderplaced;


-- -- total orders placed
SELECT COUNT(orderplaced.order_id) AS 'Total Orders Placed'
FROM orderplaced;


-- -- total books sold
SELECT SUM(bookorder.quantity) AS 'Total Books Sold'
FROM bookorder;



-- -- sales in eur, orders placed and books sold by year

-- create new table to add sales amount and number of books to the date and order id
CREATE TABLE books_sold_by_year
AS (
SELECT YEAR(orderplaced.order_date) AS 'year', orderplaced.order_id, (bookorder.quantity * bookorder.unit_price_eur) AS 'sales_in_eur', bookorder.quantity AS 'number_of_books_sold'
FROM orderplaced
LEFT JOIN bookorder
ON orderplaced.order_id = bookorder.order_id
);

-- check the new table's structure
SELECT * FROM books_sold_by_year;

-- view data by year, incuding total
SELECT IFNULL(year, 'Total') AS Year, ROUND(SUM(books_sold_by_year.sales_in_eur),0) AS 'Total Sales in EUR', COUNT(DISTINCT(books_sold_by_year.order_id)) AS 'Total Orders Placed', SUM(books_sold_by_year.number_of_books_sold) AS 'Total Books Sold'
FROM books_sold_by_year
GROUP BY books_sold_by_year.year WITH ROLLUP;

-- deleting books_sold_by_year table from database
DROP TABLE books_sold_by_year;



-- ---------------------------------------------------------------------------------------------------------------------
-- ----------------------------          Best Selling Books & Authors - in units          ------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


-- create new table using join on four tables
CREATE TABLE books_sold
AS (
SELECT 
	author.last_name,
    author.first_name,
	book.book_id, 
    book.title, 
    bookorder.quantity,
    bookorder.unit_price_eur,
    (bookorder.quantity * bookorder.unit_price_eur) AS sales_eur,
    bookorder.order_id,
    orderplaced.order_date,
    YEAR(orderplaced.order_date) AS 'order_year',
    customer.gender AS 'customer_gender'
FROM book
JOIN bookauthor
	ON book.book_id = bookauthor.book_id
JOIN author
	ON bookauthor.author_id = author.author_id
JOIN bookorder
	ON book.book_id = bookorder.book_id
JOIN orderplaced
	ON orderplaced.order_id = bookorder.order_id
JOIN customer
	ON customer.customer_id = orderplaced.customer_id);
    
-- check the new table's structure
SELECT * FROM books_sold;


-- select top 10 books (in units sold) in 2019 and 2018
(SELECT books_sold.title, SUM(books_sold.quantity) as number_of_books_sold, books_sold.order_year
FROM books_sold
WHERE books_sold.order_year = 2018
GROUP BY `title`
ORDER BY number_of_books_sold DESC
LIMIT 10)
UNION
(SELECT books_sold.title, SUM(books_sold.quantity) as number_of_books_sold, books_sold.order_year
FROM books_sold
WHERE books_sold.order_year = 2019
GROUP BY `title`
ORDER BY number_of_books_sold DESC
LIMIT 10);


-- select top 10 books (in units sold) in 2019 bought by men
SELECT books_sold.title, SUM(books_sold.quantity) as number_of_books_sold, books_sold.order_year, books_sold.customer_gender
FROM books_sold
WHERE (books_sold.order_year = 2019) AND (books_sold.customer_gender = 'Male')
GROUP BY `title`
ORDER BY number_of_books_sold DESC
LIMIT 10;

-- select top 10 authors (in units sold) in 2023 bought by women
SELECT books_sold.last_name AS 'author', SUM(books_sold.quantity) as number_of_books_sold, books_sold.order_year, books_sold.customer_gender
FROM books_sold
WHERE (books_sold.order_year = 2023) AND (books_sold.customer_gender = 'Female')
GROUP BY `author`
ORDER BY number_of_books_sold DESC
LIMIT 10;



-- ---------------------------------------------------------------------------------------------------------------------
-- ----------------------------          Best Selling Books & Authors - sales EUR          -----------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-- select top 10 books (in eur) ever sold
SELECT books_sold.title, ROUND(SUM(sales_eur),0) as sales_eur_per_book
FROM books_sold
GROUP BY `title`
ORDER BY sales_eur_per_book DESC
LIMIT 10;

-- select top 10 authors (in eur) ever sold
SELECT books_sold.last_name AS 'author', ROUND(SUM(sales_eur),0) as sales_eur_per_author
FROM books_sold
GROUP BY `author`
ORDER BY sales_eur_per_author DESC
LIMIT 10;

-- deleting books_sold table from database
DROP TABLE books_sold;



-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------          Employees Overview 2018 - 2023          ----------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-- select total employees who have processed at least one order during 2018-2023
SELECT COUNT(DISTINCT(orderplaced.employee_id)) AS 'Employees who processed at least 1 order'
FROM orderplaced;


-- display total employees on gender split
SELECT COUNT(DISTINCT(orderplaced.employee_id)) AS 'Employees who processed at least 1 order', employee.gender AS 'Gender'
FROM orderplaced
LEFT JOIN employee
ON orderplaced.employee_id = employee.employee_id
GROUP BY employee.gender;


-- display total employees on year of being hired split (expressed as count)
SELECT COUNT(DISTINCT(orderplaced.employee_id)) AS 'Employees who processed at least 1 order', YEAR(employee.hire_date) AS 'Employment Year'
FROM orderplaced
LEFT JOIN employee
ON orderplaced.employee_id = employee.employee_id
GROUP BY YEAR(employee.hire_date);


-- display total employees on year of being hired split (expressed as both count and %)
SELECT 
	COUNT(DISTINCT(orderplaced.employee_id)) AS 'Employees Count',
    ROUND(COUNT(DISTINCT(orderplaced.employee_id)) * 100 / (SELECT COUNT(DISTINCT(orderplaced.employee_id)) AS 'Employees who processed at least 1 order'
FROM orderplaced), 1) AS 'Employees %', 
	YEAR(employee.hire_date) AS 'Employment Year'
FROM orderplaced
LEFT JOIN employee
ON orderplaced.employee_id = employee.employee_id
GROUP BY YEAR(employee.hire_date);

-- select top 10 employees who processed the highest number of orders
SELECT employee.employee_id, employee.last_name, COUNT(orderplaced.order_id) AS 'number_of_processed_orders'
FROM employee
LEFT JOIN orderplaced
ON employee.employee_id = orderplaced.employee_id
GROUP BY employee.employee_id
ORDER BY COUNT(orderplaced.order_id) DESC
LIMIT 11;



-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------          Customers Overview 2018 - 2023          ----------------------------------
-- ---------------------------------------------------------------------------------------------------------------------

-- select total customers who have placed at least one order during 2018-2023
SELECT COUNT(DISTINCT(orderplaced.customer_id)) AS 'Customers who processed at least 1 order'
FROM orderplaced;

-- display total customers on gender split
SELECT COUNT(DISTINCT(orderplaced.customer_id)) AS 'Customerss who processed at least 1 order', customer.gender AS 'Gender'
FROM orderplaced
LEFT JOIN customer
ON orderplaced.customer_id = customer.customer_id
GROUP BY customer.gender;

-- select top 10 customers who bought the highest number of books

CREATE TABLE customer_overview
AS (
SELECT 
	customer.customer_id,
    customer.last_name AS customer_name,
	author.last_name AS author_last_name,
    author.first_name AS author_first_name,
	book.book_id, 
    book.title, 
    bookorder.quantity,
    bookorder.unit_price_eur,
    (bookorder.quantity * bookorder.unit_price_eur) AS sales_eur,
    bookorder.order_id,
    orderplaced.order_date,
    YEAR(orderplaced.order_date) AS 'order_year',
    customer.gender AS 'customer_gender'
FROM book
JOIN bookauthor
	ON book.book_id = bookauthor.book_id
JOIN author
	ON bookauthor.author_id = author.author_id
JOIN bookorder
	ON book.book_id = bookorder.book_id
JOIN orderplaced
	ON orderplaced.order_id = bookorder.order_id
JOIN customer
	ON customer.customer_id = orderplaced.customer_id);

SELECT * FROM customer_overview;

SELECT customer_overview.customer_id, customer_overview.customer_name, SUM(customer_overview.quantity) AS 'number_of_books_bought'
FROM customer_overview
GROUP BY  customer_overview.customer_id, customer_overview.customer_name
ORDER BY SUM(customer_overview.quantity) DESC
LIMIT 10;

DROP TABLE customer_overview;

