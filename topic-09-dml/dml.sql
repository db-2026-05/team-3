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

-- ================================================================
-- 2. AUTHORS
-- ================================================================

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
-- 3. BOOKS
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

-- ================================================================
-- 4. BOOK_AUTHORS (FIXED RELATIONSHIP)
-- ================================================================

INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),  -- 1984 → Orwell
(2, 1),  -- Animal Farm → Orwell
(3, 2),  -- Harry Potter → Rowling
(4, 3),  -- The Hobbit → (kept as given in dataset)
(5, 4),  -- Dune → Lee (dataset assumption as per DBML mismatch fix)
(6, 9),  -- Sapiens → Harari
(7, 5),  -- Foundation → Asimov
(8, 3),  -- It → Stephen King
(9, 6),  -- Pride and Prejudice → Jane Austen
(10, 10); -- Agatha Christie

-- ================================================================
-- 5. MEMBERS (FIXED DBML STRUCTURE)
-- ================================================================

INSERT INTO members (member_id, first_name, last_name, email, phone) VALUES
(1, 'Ivan', 'Petrenko', 'ivan@example.com', '111111111'),
(2, 'Olha', 'Shevchenko', 'olha@example.com', '222222222'),
(3, 'Andrii', 'Bondar', 'andrii@example.com', '333333333'),
(4, 'Maria', 'Tkachenko', 'maria@example.com', '444444444'),
(5, 'Dmytro', 'Kravets', 'dmytro@example.com', '555555555'),
(6, 'Natalia', 'Koval', 'natalia@example.com', '666666666'),
(7, 'Serhii', 'Melnyk', 'serhii@example.com', '777777777'),
(8, 'Iryna', 'Polishchuk', 'iryna@example.com', '888888888'),
(9, 'Oleh', 'Savchuk', 'oleh@example.com', '999999999'),
(10, 'Kateryna', 'Romanenko', 'katya@example.com', '101010101');

-- ================================================================
-- 6. BOOK COPIES
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
-- 7. BORROWINGS (FIXED DBML FIELDS)
-- ================================================================

INSERT INTO borrowings (borrowing_id, member_id, copy_id, borrowed_at, due_date, returned_at) VALUES
(1, 1, 2, '2025-01-10', '2025-02-10', NULL),
(2, 2, 6, '2025-02-12', '2025-03-12', NULL),
(3, 3, 14, '2025-02-15', '2025-03-15', NULL),
(4, 4, 19, '2025-03-01', '2025-04-01', NULL),
(5, 5, 9, '2025-03-05', '2025-03-20', '2025-03-18'),
(6, 6, 1, '2025-03-10', '2025-04-10', NULL),
(7, 7, 7, '2025-03-15', '2025-04-15', NULL),
(8, 8, 10, '2025-03-20', '2025-04-20', NULL),
(9, 9, 16, '2025-03-25', '2025-04-25', NULL),
(10, 10, 18, '2025-03-30', '2025-04-30', NULL);

-- ================================================================
-- 8. REVIEWS
-- ================================================================

INSERT INTO reviews (review_id, member_id, book_id, rating, review_text) VALUES
(1, 1, 1, 5, 'Excellent dystopian novel'),
(2, 2, 2, 4, 'Very strong political allegory'),
(3, 3, 3, 5, 'Great fantasy world'),
(4, 4, 4, 5, 'Classic adventure story'),
(5, 5, 5, 4, 'Deep sci-fi universe'),
(6, 6, 6, 5, 'Highly educational'),
(7, 7, 7, 4, 'Classic science fiction'),
(8, 8, 8, 5, 'Very scary and engaging'),
(9, 9, 9, 5, 'Romantic masterpiece'),
(10, 10, 10, 4, 'Excellent mystery');

-- ================================================================
-- 9. UPDATE SCENARIOS (WITH COMMENTS)
-- ================================================================

-- Mark copy as borrowed (simulate checkout process)
UPDATE book_copies
SET copy_status = 'borrowed'
WHERE copy_id = 5;

-- Update review content after rereading book
UPDATE reviews
SET rating = 5,
    review_text = 'Updated: outstanding book',
    updated_at = CURRENT_TIMESTAMP
WHERE review_id = 2;

-- Update member email (profile change)
UPDATE members
SET email = 'ivan.petrenko.updated@example.com',
    updated_at = CURRENT_TIMESTAMP
WHERE member_id = 1;

-- ================================================================
-- 10. DELETE SCENARIO (SOFT BUSINESS LOGIC)
-- ================================================================

-- Remove review (user deleted feedback)
DELETE FROM reviews
WHERE review_id = 10;

-- ================================================================
-- 11. CONSTRAINT TESTS (ISOLATED - DO NOT RUN WITH MAIN SCRIPT)
-- ================================================================

/*
-- ❌ rating out of range
INSERT INTO reviews (review_id, member_id, book_id, rating)
VALUES (11, 1, 1, 6);

-- ❌ invalid copy status
INSERT INTO book_copies (copy_id, book_id, copy_number, copy_status)
VALUES (21, 1, 4, 'broken');

-- ❌ invalid FK
INSERT INTO borrowings (borrowing_id, member_id, copy_id, borrowed_at, due_date)
VALUES (11, 999, 1, '2025-01-01', '2025-02-01');
*/

-- ================================================================