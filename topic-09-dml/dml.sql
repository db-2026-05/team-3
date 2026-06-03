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

-- ================================================================