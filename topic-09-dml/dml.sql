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
-- Table Book Copies

-- Insert 10 copies for each book into book_copies
INSERT INTO book_copies (book_id, copy_number, copy_status)
SELECT b.book_id, COALESCE(m.max_cn, 0) + gs.n as copy_number, 'available'
FROM books b
LEFT JOIN (
    SELECT book_id, MAX(copy_number) AS max_cn
    FROM book_copies
    GROUP BY book_id
) m ON m.book_id = b.book_id
CROSS JOIN generate_series(1, 10) gs(n);

-- Update book copy status by copy ID
UPDATE book_copies
SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
WHERE copy_id = $2;

-- Update status of all copies of a book by book ID
UPDATE book_copies
SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
WHERE book_id = $2;

-- Update status of all copies of a book by title
UPDATE book_copies
SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
WHERE book_id IN (
    SELECT book_id
    FROM books
    WHERE LOWER(TRIM(title)) = LOWER(TRIM($2))
);

-- Update status of all copies of a book by title and publication year
UPDATE book_copies
SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
WHERE book_id IN (
    SELECT book_id
    FROM books
    WHERE LOWER(TRIM(title)) = LOWER(TRIM($2))
      AND publication_year = $3
);

-- Update status of all copies of books within a publication year range (x-y)
UPDATE book_copies
SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
WHERE book_id IN (
    SELECT book_id
    FROM books
    WHERE publication_year BETWEEN $2 AND $3
);

-- Update status of all copies of books published after year x (new books)
UPDATE book_copies
SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
WHERE book_id IN (
    SELECT book_id
    FROM books
    WHERE publication_year > $2
);

-- Update status of all copies of books published before year x (old books)
UPDATE book_copies
SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
WHERE book_id IN (
    SELECT book_id
    FROM books
    WHERE publication_year < $2
);

-- Update status of all copies of a book by book ID and current copy status
UPDATE book_copies
SET copy_status = $1, updated_at = CURRENT_TIMESTAMP
WHERE book_id = $2 AND copy_status = 'available';


-- The deletion for this table is not relevant to business logic as we want to keep a record of all copies for historical and inventory purposes.
-- Instead of deleting records, we will update the copy_status to 'unavailable' or 'lost' to indicate that the copy is no longer available for circulation.
-- This allows us to maintain data integrity and track the history of each copy without losing important information through deletion.
-- If book will be deleted, the copies will be automatically deleted by ON DELETE CASCADE constraint on book_id foreign key in book_copies table,
-- so we don't need to write a separate DELETE statement for book_copies.

-- Invalid inserts
-- invalid status (CHECK constraint fails)
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (1, 1, 'broken');

-- invalid status typo
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (1, 2, 'avaiable');

-- copy_number = 0 (CHECK fails)
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (1, 0, 'available');

-- negative copy_number
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (1, -1, 'available');

-- NULL book_id (NOT NULL fails)
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (NULL, 1, 'available');

-- NULL copy_status (NOT NULL fails)
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (1, 1, NULL);

-- duplicate (book_id, copy_number) UNIQUE violation
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (1, 1, 'available');

-- non-existing book (FK fails)
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (9999, 1, 'available');

-- string instead of number
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (1, 'first', 'available');

-- zero copy_number edge invalid
INSERT INTO book_copies (book_id, copy_number, copy_status)
VALUES (2, 0, 'borrowed');

-- ================================================================
-- Reviews

-- User add review
INSERT INTO reviews (member_id, book_id, rating, review_text)
VALUES ($1, $2, $3, $4)

-- Examples:
INSERT INTO reviews (member_id, book_id, rating, review_text)
VALUES (
    SELECT member_id FROM members LIMIT 1,
    SELECT book_id FROM books LIMIT 1,
    3,
    NULL
)

INSERT INTO reviews (member_id, book_id, rating, review_text)
VALUES (1, 1, 4, NULL)

INSERT INTO reviews (member_id, book_id, rating, review_text)
VALUES (1, 1, 1, NULL)

INSERT INTO reviews (member_id, book_id, rating, review_text)
VALUES (1, 1, 5, NULL)

-- Mass review generation
INSERT INTO reviews (member_id, book_id, rating, review_text)
SELECT m.member_id, b.book_id, '3', 'not bad'
FROM books b
CROSS JOIN members m

-- User change review's text
UPDATE reviews
SET review_text = $1
WHERE review_id = $2

-- Examples:
UPDATE reviews
SET review_text = 'nice book'
WHERE review_id = 1

-- User change review's text
UPDATE reviews
SET rating = $1
WHERE review_id = $2

-- Examples:
UPDATE reviews
SET rating = 2
WHERE review_id = 1

-- User change whole review data
UPDATE reviews
SET review_text = $1,
rating = $2
WHERE review_id = $3

-- Examples:
UPDATE reviews
SET review_text = 'nice book',
rating = 5
WHERE review_id = 1

-- User change rating of all reviews for one book
UPDATE reviews
SET rating = $1
WHERE book_id = $2

-- Examples:
UPDATE reviews
SET rating = 5
WHERE book_id = 1

-- User change all his reviews
UPDATE reviews
SET rating = $1
WHERE member_id = $2

-- Examples:
UPDATE reviews
SET rating = 5
WHERE member_id = 1

-- User delete the review
DELETE FROM reviews
WHERE review_id = $1

-- Invalid inserts
-- rating too low (CHECK fails)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (1, 1, 0);

-- rating negative (CHECK fails)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (2, 2, -3);

-- rating too high (CHECK fails)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (3, 3, 6);

-- NULL rating (NOT NULL fails)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (4, 4, NULL);

-- duplicate review (UNIQUE fails)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (1, 1, 5);

-- duplicate again same pair (UNIQUE fails)
INSERT INTO reviews (member_id, book_id, rating, review_text)
VALUES (2, 2, 4, 'test');

-- invalid member_id (FK fails)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (9999, 1, 4);

-- invalid book_id (FK fails)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (1, 9999, 4);

-- rating decimal (depends, should fail if INT strict)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (1, 2, 4.5);

-- string rating (type error)
INSERT INTO reviews (member_id, book_id, rating)
VALUES (1, 2, 'five');

-- ================================================================