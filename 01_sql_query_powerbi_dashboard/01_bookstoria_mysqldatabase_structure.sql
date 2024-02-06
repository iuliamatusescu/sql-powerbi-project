-- ---------------------------------------------------------------------------------------------------------------------
-- -------------------------------------              CREATE DATABASE             --------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
-- naming database model 'company name_product_activity_year' --

CREATE SCHEMA bookstoria_books_orders_2018_2023 ;
USE bookstoria_books_orders_2018_2023 ;
-- DROP SCHEMA bookstoria_books_orders_2018_2023 ;






-- ---------------------------------------------------------------------------------------------------------------------
-- -------------------------------------               CREATE TABLES               -------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------


-- create Author table; 
-- Primary Key is author_id which cannot be NULL; 
-- Foreign Key: none
-- alternate keys: first_name, last_name

CREATE TABLE author (
	author_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(20),
    last_name VARCHAR(20)
);


-- create Genre table; 
-- Primary Key is genre_id which cannot be NULL; 
-- Foreign Key: none
-- alternate keys: name

CREATE TABLE genre (
	genre_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(40)
);


-- create Edition table; 
-- Primary Key is edition_id which cannot be NULL; 
-- Foreign Key: none
-- alternate keys: name, publishing_year

CREATE TABLE edition (
	edition_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(40),
    publishing_year YEAR
);



-- create Book table; 
-- Primary Key is book_id which cannot be NULL; 
-- Foreign Key: edition_id from table edition
-- alternate keys: title, isbn, file_size_mb

CREATE TABLE book (
	book_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    title VARCHAR(100),
    isbn VARCHAR(17),
    file_size_mb INT,
	edition_id INT,
    FOREIGN KEY(edition_id) REFERENCES edition(edition_id) ON DELETE SET NULL
);



-- create BookAuthor table; 
-- Primary Key and Foreign Key are the same: book_id, author_id
-- alternate keys: none

CREATE TABLE bookAuthor (
	book_id INT,
    author_id INT,
    PRIMARY KEY(book_id, author_id),
    FOREIGN KEY(book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    FOREIGN KEY(author_id) REFERENCES author(author_id) ON DELETE CASCADE
);



-- create BookGenre table; 
-- Primary Key and Foreign Key are the same: book_id, genre_id
-- alternate keys: none

CREATE TABLE bookGenre (
	book_id INT,
    genre_id INT,
    PRIMARY KEY(book_id, genre_id),
    FOREIGN KEY(book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    FOREIGN KEY(genre_id) REFERENCES genre(genre_id) ON DELETE CASCADE
);



-- create Employee table; 
-- Primary Key is employee_id which cannot be NULL; 
-- Foreign Key: none
-- alternate keys: first_name, last_name, gender, birth_date, hire_date, country, city, post_code

CREATE TABLE employee (
	employee_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    gender VARCHAR(6),
    birth_date DATE,
    hire_date DATE,
    country VARCHAR(20),
    city VARCHAR(20),
    post_code VARCHAR(6)
);



-- create Customer table; 
-- Primary Key is customer_id which cannot be NULL; 
-- Foreign Key: none
-- alternate keys: email, user_name, first_name, last_name, phone_number, birth_date, country, city, gender

CREATE TABLE customer (
	customer_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    email VARCHAR(320),
    user_name VARCHAR(50),
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    phone_number VARCHAR(16),
    birth_date DATE,
    country VARCHAR(20),
    city VARCHAR(20),
    gender VARCHAR(6)
);



-- create OrderPlaced table; 
-- Primary Key is order_id which cannot be NULL; 
-- Foreign Key: employee_id from employee table and customer_id from customer table
-- alternate keys: order_date, status, payment_method, amount_eur

CREATE TABLE orderPlaced (
	order_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    order_date DATE,
    status VARCHAR(20),
    payment_method VARCHAR(20),
    amount_eur DECIMAL(10, 2),
    customer_id INT,
    employee_id INT,
    FOREIGN KEY(customer_id) REFERENCES customer(customer_id) ON DELETE SET NULL,
    FOREIGN KEY(employee_id) REFERENCES employee(employee_id) ON DELETE SET NULL
);



-- create BookOrder table; 
-- Primary Key and Foreign Key are the same: book_id, order_id
-- alternate keys: quantity, unit_price_eur

CREATE TABLE bookOrder (
	book_id INT,
    order_id INT,
    quantity INT,
    unit_price_eur DECIMAL(6, 2),
    PRIMARY KEY(book_id, order_id),
    FOREIGN KEY(book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    FOREIGN KEY(order_id) REFERENCES orderPlaced(order_id) ON DELETE CASCADE
);






















































