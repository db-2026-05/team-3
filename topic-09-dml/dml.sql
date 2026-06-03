-- ================================================================
-- SQL DML TEMPLATE (TOPIC 09)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) INSERT scripts for all required tables in your database.
-- 2) At least 10 records per table with meaningful, realistic values.
-- 3) UPDATE / DELETE scripts where they are relevant to business logic.
-- 4) If UPDATE / DELETE are not relevant for a table, add a short note
--    in documentation explaining why.
-- 5) Comments by section so the script is easy to read and run.
--
-- SCRIPT GOALS:
-- - Populate the database with usable test data.
-- - Validate constraints through realistic DML scenarios.
-- - Support the core functionality of your application.
--
-- RECOMMENDED ORDER:
-- 1) Reference data (lookups/dictionaries)
-- 2) Core entities
-- 3) Transactional data
-- 4) Optional UPDATE / DELETE checks
--
-- IMPORTANT:
-- - Use anonymized or privacy-safe sample data where possible.
-- - The script must execute in PostgreSQL.
-- - Submit this as one SQL file.
-- ================================================================

-- Add your DML below this line

-- ================================================================
-- -- Table Book Copies
-- ================================================================
-- 1. REFERENCE DATA
-- ================================================================

INSERT INTO categories (category_id, category_name) VALUES
(1, 'Fiction'),
(2, 'Science'),
(3, 'History'),
(4, 'Fantasy'),
(5, 'Biography'),
(6, 'Technology'),
(7, 'Mystery'),
(8, 'Romance'),
(9, 'Philosophy'),
(10, 'Education');

INSERT INTO authors (author_id, first_name, last_name) VALUES
(1, 'George', 'Orwell'),
(2, 'J.K.', 'Rowling'),
(3, 'Stephen', 'King'),
(4, 'Harper', 'Lee'),
(5, 'Isaac', 'Asimov'),
(6, 'Jane', 'Austen'),
(7, 'Mark', 'Twain'),
(8, 'Ernest', 'Hemingway'),
(9, 'Yuval', 'Harari'),
(10, 'Agatha', 'Christie');

-- ================================================================
-- 2. CORE ENTITIES
-- ================================================================

INSERT INTO books (book_id, title, isbn, publication_year, category_id) VALUES
(1, '1984', '9780451524935', 1949, 1),
(2, 'Animal Farm', '9780451526342', 1945, 1),
(3, 'Harry Potter', '9780439139601', 1998, 4),
(4, 'The Hobbit', '9780547928227', 1937, 4),
(5, 'Dune', '9780441172719', 1965, 4),
(6, 'Sapiens', '9780062316097', 2011, 5),
(7, 'Foundation', '9780553293357', 1951, 6),
(8, 'It', '9781501142970', 1986, 7),
(9, 'Pride and Prejudice', '9781503290563', 1813, 8),
(10, 'Murder on the Orient Express', '9780062693662', 1934, 7);

INSERT INTO members (member_id, full_name, email, phone) VALUES
(1, 'Ivan Petrenko', 'ivan@example.com', '111111111'),
(2, 'Olha Shevchenko', 'olha@example.com', '222222222'),
(3, 'Andrii Bondar', 'andrii@example.com', '333333333'),
(4, 'Maria Tkachenko', 'maria@example.com', '444444444'),
(5, 'Dmytro Kravets', 'dmytro@example.com', '555555555'),
(6, 'Natalia Koval', 'natalia@example.com', '666666666'),
(7, 'Serhii Melnyk', 'serhii@example.com', '777777777'),
(8, 'Iryna Polishchuk', 'iryna@example.com', '888888888'),
(9, 'Oleh Savchuk', 'oleh@example.com', '999999999'),
(10, 'Kateryna Romanenko', 'katya@example.com', '101010101');

INSERT INTO book_authors (book_id, author_id) VALUES
(1,1),(2,1),
(3,2),
(4,3),
(5,4),
(6,9),
(7,5),
(8,3),
(9,6),
(10,10);

-- ================================================================
-- 3. INVENTORY (BOOK COPIES)
-- ================================================================

INSERT INTO book_copies (copy_id, book_id, copy_number, copy_status) VALUES
(1, 1, 1, 'available'),
(2, 1, 2, 'borrowed'),
(3, 1, 3, 'available'),
(4, 2, 1, 'available'),
(5, 2, 2, 'available'),
(6, 3, 1, 'borrowed'),
(7, 3, 2, 'available'),
(8, 4, 1, 'available'),
(9, 4, 2, 'lost'),
(10, 5, 1, 'available'),
(11, 5, 2, 'available'),
(12, 6, 1, 'available'),
(13, 6, 2, 'available'),
(14, 7, 1, 'borrowed'),
(15, 7, 2, 'available'),
(16, 8, 1, 'available'),
(17, 8, 2, 'available'),
(18, 9, 1, 'available'),
(19, 10, 1, 'borrowed'),
(20, 10, 2, 'available');

-- ================================================================
-- 4. BORROWINGS
-- ================================================================

INSERT INTO borrowings (borrowing_id, member_id, copy_id, borrow_date, return_date) VALUES
(1, 1, 2, '2025-01-10', NULL),
(2, 2, 6, '2025-02-12', NULL),
(3, 3, 14, '2025-02-15', NULL),
(4, 4, 19, '2025-03-01', NULL),
(5, 5, 9, '2025-03-05', '2025-03-20'),
(6, 6, 1, '2025-03-10', NULL),
(7, 7, 7, '2025-03-15', NULL),
(8, 8, 10, '2025-03-20', NULL),
(9, 9, 16, '2025-03-25', NULL),
(10, 10, 18, '2025-03-30', NULL);

-- ================================================================
-- 5. REVIEWS
-- ================================================================

INSERT INTO reviews (review_id, member_id, book_id, rating, review_text) VALUES
(1, 1, 1, 5, 'Excellent dystopian novel'),
(2, 2, 2, 4, 'Very interesting allegory'),
(3, 3, 3, 5, 'Amazing fantasy story'),
(4, 4, 4, 5, 'A masterpiece'),
(5, 5, 5, 4, 'Great sci-fi world'),
(6, 6, 6, 5, 'Very educational'),
(7, 7, 7, 4, 'Classic sci-fi'),
(8, 8, 8, 5, 'Scary but great'),
(9, 9, 9, 5, 'Romantic classic'),
(10, 10, 10, 4, 'Very clever mystery');

-- ================================================================
-- 6. UPDATE SCENARIOS
-- ================================================================

UPDATE book_copies
SET copy_status = 'borrowed'
WHERE copy_id = 5;

UPDATE reviews
SET rating = 5, review_text = 'Updated: outstanding book!'
WHERE review_id = 2;

UPDATE members
SET email = 'updated_ivan@example.com'
WHERE member_id = 1;

-- ================================================================
-- 7. DELETE SCENARIOS
-- ================================================================

DELETE FROM reviews
WHERE review_id = 10;

-- ================================================================
-- 8. CONSTRAINT TESTS (INVALID CASES)
-- ================================================================

-- invalid rating
INSERT INTO reviews (review_id, member_id, book_id, rating, review_text)
VALUES (11, 1, 1, 6, 'Invalid rating');

-- invalid copy status
INSERT INTO book_copies (copy_id, book_id, copy_number, copy_status)
VALUES (21, 1, 4, 'broken');

-- invalid foreign key
INSERT INTO borrowings (borrowing_id, member_id, copy_id, borrow_date)
VALUES (11, 999, 1, '2025-01-01');

-- duplicate PK
INSERT INTO categories (category_id, category_name)
VALUES (1, 'Duplicate');

-- null constraint
INSERT INTO members (member_id, full_name, email)
VALUES (11, NULL, 'test@example.com');

-- -- Insert 10 copies for each book into book_copies
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- SELECT b.book_id, COALESCE(m.max_cn, 0) + gs.n as copy_number, 'available'
-- FROM books b
-- LEFT JOIN (
--     SELECT book_id, MAX(copy_number) AS max_cn
--     FROM book_copies
--     GROUP BY book_id
-- ) m ON m.book_id = b.book_id
-- CROSS JOIN generate_series(1, 10) gs(n);

-- -- Update book copy status by copy ID
-- UPDATE book_copies
-- SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
-- WHERE copy_id = $2;

-- -- Update status of all copies of a book by book ID
-- UPDATE book_copies
-- SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
-- WHERE book_id = $2;

-- -- Update status of all copies of a book by title
-- UPDATE book_copies
-- SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
-- WHERE book_id IN (
--     SELECT book_id
--     FROM books
--     WHERE LOWER(TRIM(title)) = LOWER(TRIM($2))
-- );

-- -- Update status of all copies of a book by title and publication year
-- UPDATE book_copies
-- SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
-- WHERE book_id IN (
--     SELECT book_id
--     FROM books
--     WHERE LOWER(TRIM(title)) = LOWER(TRIM($2))
--       AND publication_year = $3
-- );

-- -- Update status of all copies of books within a publication year range (x-y)
-- UPDATE book_copies
-- SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
-- WHERE book_id IN (
--     SELECT book_id
--     FROM books
--     WHERE publication_year BETWEEN $2 AND $3
-- );

-- -- Update status of all copies of books published after year x (new books)
-- UPDATE book_copies
-- SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
-- WHERE book_id IN (
--     SELECT book_id
--     FROM books
--     WHERE publication_year > $2
-- );

-- -- Update status of all copies of books published before year x (old books)
-- UPDATE book_copies
-- SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
-- WHERE book_id IN (
--     SELECT book_id
--     FROM books
--     WHERE publication_year < $2
-- );

-- -- Update status of all copies of a book by book ID and current copy status
-- UPDATE book_copies
-- SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
-- WHERE book_id = $2 AND copy_status = 'available';


-- -- The deletion for this table is not relevant to business logic as we want to keep a record of all copies for historical and inventory purposes.
-- -- Instead of deleting records, we will update the copy_status to 'unavailable' or 'lost' to indicate that the copy is no longer available for circulation.
-- -- This allows us to maintain data integrity and track the history of each copy without losing important information through deletion.
-- -- If book will be deleted, the copies will be automatically deleted by ON DELETE CASCADE constraint on book_id foreign key in book_copies table,
-- -- so we don't need to write a separate DELETE statement for book_copies.

-- -- Invalid inserts
-- -- invalid status (CHECK constraint fails)
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (1, 1, 'broken');

-- -- invalid status typo
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (1, 2, 'avaiable');

-- -- copy_number = 0 (CHECK fails)
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (1, 0, 'available');

-- -- negative copy_number
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (1, -1, 'available');

-- -- NULL book_id (NOT NULL fails)
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (NULL, 1, 'available');

-- -- NULL copy_status (NOT NULL fails)
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (1, 1, NULL);

-- -- duplicate (book_id, copy_number) UNIQUE violation
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (1, 1, 'available');

-- -- non-existing book (FK fails)
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (9999, 1, 'available');

-- -- string instead of number
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (1, 'first', 'available');

-- -- zero copy_number edge invalid
-- INSERT INTO book_copies (book_id, copy_number, copy_status)
-- VALUES (2, 0, 'borrowed');

-- -- ================================================================
-- -- Reviews

-- -- User add review
-- INSERT INTO reviews (member_id, book_id, rating, review_text)
-- VALUES ($1, $2, $3, $4)

-- -- Examples:
-- INSERT INTO reviews (member_id, book_id, rating, review_text)
-- VALUES (
--     SELECT member_id FROM members LIMIT 1,
--     SELECT book_id FROM books LIMIT 1,
--     3,
--     NULL
-- )

-- INSERT INTO reviews (member_id, book_id, rating, review_text)
-- VALUES (1, 1, 4, NULL)

-- INSERT INTO reviews (member_id, book_id, rating, review_text)
-- VALUES (1, 1, 1, NULL)

-- INSERT INTO reviews (member_id, book_id, rating, review_text)
-- VALUES (1, 1, 5, NULL)

-- -- Mass review generation
-- INSERT INTO reviews (member_id, book_id, rating, review_text)
-- SELECT m.member_id, b.book_id, '3', 'not bad'
-- FROM books b
-- CROSS JOIN members m

-- -- User change review's text
-- UPDATE reviews
-- SET review_text = $1
-- WHERE review_id = $2

-- -- Examples:
-- UPDATE reviews
-- SET review_text = 'nice book'
-- WHERE review_id = 1

-- -- User change review's text
-- UPDATE reviews
-- SET rating = $1
-- WHERE review_id = $2

-- -- Examples:
-- UPDATE reviews
-- SET rating = 2
-- WHERE review_id = 1

-- -- User change whole review data
-- UPDATE reviews
-- SET review_text = $1,
-- rating = $2
-- WHERE review_id = $3

-- -- Examples:
-- UPDATE reviews
-- SET review_text = 'nice book',
-- rating = 5
-- WHERE review_id = 1

-- -- User change rating of all reviews for one book
-- UPDATE reviews
-- SET rating = $1
-- WHERE book_id = $2

-- -- Examples:
-- UPDATE reviews
-- SET rating = 5
-- WHERE book_id = 1

-- -- User change all his reviews
-- UPDATE reviews
-- SET rating = $1
-- WHERE member_id = $2

-- -- Examples:
-- UPDATE reviews
-- SET rating = 5
-- WHERE member_id = 1

-- -- User delete the review
-- DELETE FROM reviews
-- WHERE review_id = $1

-- -- Invalid inserts
-- -- rating too low (CHECK fails)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (1, 1, 0);

-- -- rating negative (CHECK fails)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (2, 2, -3);

-- -- rating too high (CHECK fails)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (3, 3, 6);

-- -- NULL rating (NOT NULL fails)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (4, 4, NULL);

-- -- duplicate review (UNIQUE fails)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (1, 1, 5);

-- -- duplicate again same pair (UNIQUE fails)
-- INSERT INTO reviews (member_id, book_id, rating, review_text)
-- VALUES (2, 2, 4, 'test');

-- -- invalid member_id (FK fails)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (9999, 1, 4);

-- -- invalid book_id (FK fails)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (1, 9999, 4);

-- -- rating decimal (depends, should fail if INT strict)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (1, 2, 4.5);

-- -- string rating (type error)
-- INSERT INTO reviews (member_id, book_id, rating)
-- VALUES (1, 2, 'five');

-- ================================================================