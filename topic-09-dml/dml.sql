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
-- CLEANUP (executed before data loading)
-- ================================================================

DELETE FROM borrowings;
DELETE FROM reviews;
DELETE FROM reservations;
DELETE FROM book_authors;
DELETE FROM book_copies;
DELETE FROM books;
DELETE FROM categories;
DELETE FROM authors;
DELETE FROM members;

-- ================================================================
-- 1. REFERENCE DATA (categories, authors)
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
(10, 'Agatha', 'Christie'),
(11, 'J.R.R.', 'Tolkien'),
(12, 'Frank', 'Herbert');

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
(1, 1),
(2, 1),
(3, 2),
(4, 11),
(5, 12),
(6, 9),
(7, 5),
(8, 3),
(9, 6),
(10, 10);

-- ================================================================
-- 5. MEMBERS (FIXED DBML STRUCTURE)
-- ================================================================

-- updated_at is set equal to registered_at at seed time so the audit
-- columns stay temporally consistent (otherwise the DEFAULT would stamp
-- them with the load date, which post-dates the historical registered_at).
INSERT INTO members (member_id, first_name, last_name, email, phone, registered_at, updated_at) VALUES
(1, 'Ivan', 'Petrenko', 'ivan@example.com', '111111111', '2024-01-15', '2024-01-15'),
(2, 'Olha', 'Shevchenko', 'olha@example.com', '222222222', '2024-01-16', '2024-01-16'),
(3, 'Andrii', 'Bondar', 'andrii@example.com', '333333333', '2024-01-17', '2024-01-17'),
(4, 'Maria', 'Tkachenko', 'maria@example.com', '444444444', '2024-01-18', '2024-01-18'),
(5, 'Dmytro', 'Kravets', 'dmytro@example.com', '555555555', '2024-01-19', '2024-01-19'),
(6, 'Natalia', 'Koval', 'natalia@example.com', '666666666', '2024-01-20', '2024-01-20'),
(7, 'Serhii', 'Melnyk', 'serhii@example.com', '777777777', '2024-01-21', '2024-01-21'),
(8, 'Iryna', 'Polishchuk', 'iryna@example.com', '888888888', '2024-01-22', '2024-01-22'),
(9, 'Oleh', 'Savchuk', 'oleh@example.com', '999999999', '2024-01-23', '2024-01-23'),
(10, 'Kateryna', 'Romanenko', 'katya@example.com', '101010101', '2024-01-24', '2024-01-24');

-- ================================================================
-- 6. BOOK COPIES
-- ================================================================

-- NOTE 1: copy_status is kept consistent with the active borrowings below
--   (every copy that has a borrowing with returned_at IS NULL is 'borrowed').
--   In later topics this synchronization is automated via triggers/procedures.
-- NOTE 2: acquired_date/updated_at are set explicitly to historical values
--   (all earlier than the first borrowing) so a copy is never "acquired"
--   after it was lent out; otherwise the DEFAULT would stamp them with today.
INSERT INTO book_copies (copy_id, book_id, copy_number, copy_status, acquired_date, updated_at) VALUES
(1, 1, 1, 'borrowed', '2023-03-10', '2023-03-10'),
(2, 1, 2, 'borrowed', '2023-03-10', '2023-03-10'),
(3, 1, 3, 'available', '2023-05-22', '2023-05-22'),
(4, 2, 1, 'available', '2023-04-01', '2023-04-01'),
(5, 2, 2, 'borrowed', '2023-04-01', '2023-04-01'),
(6, 3, 1, 'borrowed', '2023-06-15', '2023-06-15'),
(7, 3, 2, 'borrowed', '2023-06-15', '2023-06-15'),
(8, 4, 1, 'available', '2023-07-20', '2023-07-20'),
(9, 4, 2, 'available', '2023-07-20', '2023-07-20'),
(10, 5, 1, 'available', '2023-08-05', '2023-08-05'),
(11, 5, 2, 'borrowed', '2023-08-05', '2023-08-05'),
(12, 6, 1, 'available', '2023-09-12', '2023-09-12'),
(13, 6, 2, 'available', '2023-09-12', '2023-09-12'),
(14, 7, 1, 'borrowed', '2023-10-01', '2023-10-01'),
(15, 7, 2, 'available', '2023-10-01', '2023-10-01'),
(16, 8, 1, 'borrowed', '2023-11-18', '2023-11-18'),
(17, 8, 2, 'available', '2023-11-18', '2023-11-18'),
(18, 9, 1, 'borrowed', '2024-01-09', '2024-01-09'),
(19, 10, 1, 'borrowed', '2024-02-14', '2024-02-14'),
(20, 10, 2, 'available', '2024-02-14', '2024-02-14');

-- ================================================================
-- 7. BORROWINGS (FIXED DBML FIELDS)
-- ================================================================

INSERT INTO borrowings (borrowing_id, member_id, copy_id, borrowed_at, due_date, returned_at) VALUES
(1, 1, 2, '2025-01-10', '2025-02-10', NULL),
(2, 2, 6, '2025-02-12', '2025-03-12', NULL),
(3, 3, 14, '2025-02-15', '2025-03-15', NULL),
(4, 4, 19, '2025-03-01', '2025-04-01', NULL),
(5, 5, 10, '2025-03-05', '2025-03-20', '2025-03-18'),
(6, 6, 1, '2025-03-10', '2025-04-10', NULL),
(7, 7, 7, '2025-03-15', '2025-04-15', NULL),
(8, 8, 11, '2025-03-20', '2025-04-20', NULL),
(9, 9, 16, '2025-03-25', '2025-04-25', NULL),
(10, 10, 18, '2025-03-30', '2025-04-30', NULL),
(11, 1, 5, '2025-04-01', '2025-05-01', NULL);

-- ================================================================
-- 7b. RESERVATIONS
--   Members queue for books whose copies are currently all borrowed.
--     copy_id IS NULL -> still waiting in the queue (queue_position set)
--     copy_id filled  -> a physical copy has been assigned to the member
--   Respects partial unique index uq_reservations_pending_member_book
--   (at most one 'pending' reservation per member per book).
-- ================================================================

INSERT INTO reservations
    (reservation_id, member_id, book_id, copy_id, reservation_status, queue_position) VALUES
(1,  2, 1,  NULL, 'pending',   1),
(2,  3, 1,  NULL, 'pending',   2),
(3,  4, 3,  NULL, 'pending',   1),
(4,  5, 3,  NULL, 'pending',   2),
(5,  6, 5,  NULL, 'pending',   1),
(6,  7, 7,  NULL, 'pending',   1),
(7,  8, 10, NULL, 'pending',   1),
(8,  9, 4,  8,    'assigned',  NULL),
(9,  10, 6, NULL, 'fulfilled', NULL),
(10, 1, 8,  NULL, 'cancelled', NULL),
(11, 2, 9,  NULL, 'pending',   1);

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
-- 8b. SYNC SEQUENCES
--   All rows above use explicit PK values, which does NOT advance the
--   BIGSERIAL sequences. Re-align each sequence to MAX(id) so later
--   default-driven inserts (other topics, procedures) do not collide.
-- ================================================================

SELECT setval(pg_get_serial_sequence('categories', 'category_id'),  (SELECT MAX(category_id)  FROM categories));
SELECT setval(pg_get_serial_sequence('authors',     'author_id'),   (SELECT MAX(author_id)    FROM authors));
SELECT setval(pg_get_serial_sequence('books',       'book_id'),     (SELECT MAX(book_id)      FROM books));
SELECT setval(pg_get_serial_sequence('members',     'member_id'),   (SELECT MAX(member_id)    FROM members));
SELECT setval(pg_get_serial_sequence('book_copies', 'copy_id'),     (SELECT MAX(copy_id)      FROM book_copies));
SELECT setval(pg_get_serial_sequence('borrowings',  'borrowing_id'),(SELECT MAX(borrowing_id) FROM borrowings));
SELECT setval(pg_get_serial_sequence('reservations','reservation_id'),(SELECT MAX(reservation_id) FROM reservations));
SELECT setval(pg_get_serial_sequence('reviews',     'review_id'),   (SELECT MAX(review_id)    FROM reviews));

-- ================================================================
-- 9. UPDATE SCENARIOS (WITH COMMENTS)
-- ================================================================

-- (a) BOOK RETURN WORKFLOW (transactional; kept consistent by hand here,
--     automated by triggers/procedures in later topics).
--     Member 8 returns copy 11 (a copy of book 5 "Dune").
UPDATE borrowings
SET returned_at = '2025-04-18'
WHERE borrowing_id = 8;

--     The freed copy becomes available again.
UPDATE book_copies
SET copy_status = 'available',
    updated_at = CURRENT_TIMESTAMP
WHERE copy_id = 11;

--     Assign the freed copy to the next member waiting for book 5.
UPDATE reservations
SET copy_id = 11,
    reservation_status = 'assigned',
    queue_position = NULL
WHERE reservation_id = 5;

-- (b) Mark a physical copy as lost (inventory maintenance).
UPDATE book_copies
SET copy_status = 'lost',
    updated_at = CURRENT_TIMESTAMP
WHERE copy_id = 3;

-- (c) Update review content after rereading book.
UPDATE reviews
SET rating = 5,
    review_text = 'Updated: outstanding book',
    updated_at = CURRENT_TIMESTAMP
WHERE review_id = 2;

-- (d) Update member email (profile change).
UPDATE members
SET email = 'ivan.petrenko.updated@example.com',
    updated_at = CURRENT_TIMESTAMP
WHERE member_id = 1;

-- ================================================================
-- 10. DELETE SCENARIOS (WITH COMMENTS)
-- ================================================================

-- Remove a review (member deleted their feedback).
DELETE FROM reviews
WHERE review_id = 10;

-- Remove a cancelled reservation (cleanup of an abandoned request).
DELETE FROM reservations
WHERE reservation_id = 10 AND reservation_status = 'cancelled';

-- ================================================================
-- 11. CONSTRAINT VALIDATION
-- ================================================================

-- (a) Active, self-contained demonstration: each invalid write is attempted
--     and its rejection is caught, so the main script still completes while
--     proving the constraint actually fires.
DO $$
BEGIN
    -- rating must be between 1 and 5 (chk_reviews_rating)
    BEGIN
        INSERT INTO reviews (member_id, book_id, rating) VALUES (1, 5, 6);
        RAISE EXCEPTION 'unexpected: chk_reviews_rating did not fire';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK: rating=6 rejected by chk_reviews_rating';
    END;

    -- copy_status restricted to the allowed set (chk_book_copies_status)
    BEGIN
        INSERT INTO book_copies (book_id, copy_number, copy_status)
        VALUES (1, 99, 'broken');
        RAISE EXCEPTION 'unexpected: chk_book_copies_status did not fire';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK: copy_status=broken rejected by chk_book_copies_status';
    END;

    -- member_id must reference an existing member (fk_borrowings_member)
    BEGIN
        INSERT INTO borrowings (member_id, copy_id, due_date)
        VALUES (999, 4, '2026-12-31');
        RAISE EXCEPTION 'unexpected: fk_borrowings_member did not fire';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'OK: member_id=999 rejected by fk_borrowings_member';
    END;
END $$;

-- (b) Reference copies of the same checks for manual line-by-line testing
--     (uncomment to run individually):
/*
INSERT INTO reviews (member_id, book_id, rating) VALUES (1, 5, 6);                    -- rating > 5
INSERT INTO book_copies (book_id, copy_number, copy_status) VALUES (1, 99, 'broken'); -- bad status
INSERT INTO borrowings (member_id, copy_id, due_date) VALUES (999, 4, '2026-12-31');  -- bad FK
*/

-- ================================================================
-- END OF DML SCRIPT
-- ================================================================