-- ================================================================
-- FUNCTIONS & STORED PROCEDURES TEMPLATE (TOPIC 12)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
--
-- FUNCTIONS (at least 3):
--   - Each function should encapsulate reusable logic or a
--     calculation relevant to your project domain.
--   - Use CREATE OR REPLACE FUNCTION ... RETURNS ...
--
-- STORED PROCEDURES — SELECT / INSERT (at least 2):
--   - Procedures that retrieve data or insert new records.
--   - Use CREATE OR REPLACE PROCEDURE ...
--
-- STORED PROCEDURES — UPDATE (at least 2):
--   - Procedures that modify existing records.
--
-- FOR EACH FUNCTION / PROCEDURE, ADD COMMENTS EXPLAINING:
--   - Purpose: what it does
--   - Parameters: name, type, meaning
--   - Expected behavior / return value
--
-- TEST CALLS:
--   - Include at least one example call per function/procedure
--     (SELECT my_function(...) or CALL my_procedure(...))
--
-- OPTIONAL:
--   - EXCEPTION blocks for error handling
--   - Transaction management with BEGIN / COMMIT / ROLLBACK
--
-- RECOMMENDED ORDER:
-- 1) Functions
-- 2) SELECT / INSERT procedures
-- 3) UPDATE procedures
-- 4) Test calls
--
-- IMPORTANT:
-- - All routines must execute in PostgreSQL without errors.
-- - Logic must be relevant to your project domain.
-- - Submit everything in this single SQL file.
-- ================================================================

-- Add your functions and procedures below this line

-- =====================================================================
-- PROGRAMMABILITY SCRIPT FOR ALL TEAM MEMBERS
-- Domains:
-- Person 1: books, categories, authors, book_authors
-- Person 2: book_copies, reviews
-- Person 3: members, borrowings, reservations
-- =====================================================================

-- =====================================================================
-- PERSON 1: CATALOG MANAGEMENT
-- Tables: books, categories, authors, book_authors
-- =====================================================================

-- ---------------------------------------------------------------------
-- FUNCTIONS (Person 1)
-- ---------------------------------------------------------------------

-- Purpose: Retrieves a comma-separated list of author names for a specific book.
-- Parameters: p_book_id (BIGINT)
-- Expected behavior: Returns a single TEXT string containing author names.
CREATE OR REPLACE FUNCTION fn_get_authors_for_book(p_book_id BIGINT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_author_names TEXT;
BEGIN
    SELECT STRING_AGG(a.first_name || ' ' || a.last_name, ', ')
    INTO v_author_names
    FROM authors a
    JOIN book_authors ba ON a.author_id = ba.author_id
    WHERE ba.book_id = p_book_id;

    RETURN COALESCE(v_author_names, 'No Authors Found');
END;
$$;

-- Purpose: Calculates the total number of books within a specific category.
-- Parameters: p_category_id (BIGINT)
-- Expected behavior: Returns an INT representing the total book count.
CREATE OR REPLACE FUNCTION fn_count_books_by_category(p_category_id BIGINT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM books
    WHERE category_id = p_category_id;

    RETURN v_count;
END;
$$;

-- Purpose: Retrieves all books written by a specific author.
-- Parameters: p_author_id (BIGINT)
-- Expected behavior: Returns a table of books.
CREATE OR REPLACE FUNCTION fn_get_books_by_author(p_author_id BIGINT)
RETURNS TABLE (
    book_id BIGINT,
    title VARCHAR,
    publication_year INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT b.book_id, b.title, b.publication_year
    FROM books b
    JOIN book_authors ba ON b.book_id = ba.book_id
    WHERE ba.author_id = p_author_id;
END;
$$;

-- ---------------------------------------------------------------------
-- SELECT/INSERT PROCEDURES (Person 1)
-- ---------------------------------------------------------------------

-- Purpose: Inserts a new author into the database.
-- Parameters: p_first_name (VARCHAR), p_last_name (VARCHAR), OUT p_author_id
CREATE OR REPLACE PROCEDURE sp_add_author(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    INOUT p_author_id BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO authors (first_name, last_name)
    VALUES (p_first_name, p_last_name)
    RETURNING author_id INTO p_author_id;
END;
$$;

-- Purpose: Inserts a new book and links it to an existing author.
-- Parameters: Title, ISBN, Year, Category ID, Author ID.
-- Demonstrates EXCEPTION handling for duplicate ISBNs.
CREATE OR REPLACE PROCEDURE sp_add_book_with_author(
    p_title VARCHAR,
    p_isbn VARCHAR,
    p_pub_year INT,
    p_category_id BIGINT,
    p_author_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_book_id BIGINT;
BEGIN
    INSERT INTO books (title, isbn, publication_year, category_id)
    VALUES (p_title, p_isbn, p_pub_year, p_category_id)
    RETURNING book_id INTO v_new_book_id;

    INSERT INTO book_authors (book_id, author_id)
    VALUES (v_new_book_id, p_author_id);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Operation failed: ISBN % already exists.', p_isbn;
END;
$$;

-- ---------------------------------------------------------------------
-- UPDATE PROCEDURES (Person 1)
-- ---------------------------------------------------------------------

-- Purpose: Updates the category of a specific book.
-- Parameters: p_book_id (BIGINT), p_new_category_id (BIGINT).
CREATE OR REPLACE PROCEDURE sp_update_book_category(
    p_book_id BIGINT,
    p_new_category_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE books
    SET category_id = p_new_category_id
    WHERE book_id = p_book_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Book with ID % not found.', p_book_id;
    END IF;
END;
$$;

-- Purpose: Updates the first and last name of an author.
-- Parameters: p_author_id (BIGINT), p_new_first (VARCHAR), p_new_last (VARCHAR).
CREATE OR REPLACE PROCEDURE sp_update_author_name(
    p_author_id BIGINT,
    p_new_first VARCHAR,
    p_new_last VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE authors
    SET first_name = p_new_first,
        last_name = p_new_last
    WHERE author_id = p_author_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Author with ID % not found.', p_author_id;
    END IF;
END;
$$;


-- =====================================================================
-- PERSON 2: INVENTORY & FEEDBACK
-- Tables: book_copies, reviews
-- =====================================================================

-- ---------------------------------------------------------------------
-- FUNCTIONS (Person 2)
-- ---------------------------------------------------------------------

-- Purpose: Counts how many available copies exist for a given book.
-- Parameters: p_book_id (BIGINT)
CREATE OR REPLACE FUNCTION fn_count_available_copies(p_book_id BIGINT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM book_copies
    WHERE book_id = p_book_id AND copy_status = 'available';
    RETURN v_count;
END;
$$;

-- Purpose: Calculates the average review rating for a given book.
-- Parameters: p_book_id (BIGINT)
CREATE OR REPLACE FUNCTION fn_get_avg_book_rating(p_book_id BIGINT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_avg NUMERIC;
BEGIN
    SELECT ROUND(AVG(rating)::NUMERIC, 2) INTO v_avg
    FROM reviews
    WHERE book_id = p_book_id;
    RETURN COALESCE(v_avg, 0);
END;
$$;

-- Purpose: Retrieves the latest review text for a specific book.
-- Parameters: p_book_id (BIGINT)
CREATE OR REPLACE FUNCTION fn_get_latest_review(p_book_id BIGINT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_review TEXT;
BEGIN
    SELECT review_text INTO v_review
    FROM reviews
    WHERE book_id = p_book_id
    ORDER BY created_at DESC
    LIMIT 1;
    RETURN COALESCE(v_review, 'No reviews yet');
END;
$$;

-- ---------------------------------------------------------------------
-- SELECT/INSERT PROCEDURES (Person 2)
-- ---------------------------------------------------------------------

-- Purpose: Inserts a new review for a book.
-- Parameters: p_member_id, p_book_id, p_rating, p_review_text
CREATE OR REPLACE PROCEDURE sp_add_review(
    p_member_id BIGINT,
    p_book_id BIGINT,
    p_rating INT,
    p_review_text TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reviews (member_id, book_id, rating, review_text)
    VALUES (p_member_id, p_book_id, p_rating, p_review_text);
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Member % has already reviewed book %.', p_member_id, p_book_id;
    WHEN check_violation THEN
        RAISE EXCEPTION 'Rating must be between 1 and 5.';
END;
$$;

-- Purpose: Adds a new physical copy for a book, auto-calculating the copy number.
-- Parameters: p_book_id, p_acquired_date, OUT p_copy_id
CREATE OR REPLACE PROCEDURE sp_add_book_copy(
    p_book_id BIGINT,
    p_acquired_date DATE,
    INOUT p_copy_id BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_next_number INT;
BEGIN
    SELECT COALESCE(MAX(copy_number), 0) + 1 INTO v_next_number
    FROM book_copies
    WHERE book_id = p_book_id;

    INSERT INTO book_copies (book_id, copy_number, copy_status, acquired_date)
    VALUES (p_book_id, v_next_number, 'available', p_acquired_date)
    RETURNING copy_id INTO p_copy_id;
END;
$$;

-- ---------------------------------------------------------------------
-- UPDATE PROCEDURES (Person 2)
-- ---------------------------------------------------------------------

-- Purpose: Updates the physical status of a book copy (e.g., to 'lost').
-- Parameters: p_copy_id, p_new_status
CREATE OR REPLACE PROCEDURE sp_update_copy_status(
    p_copy_id BIGINT,
    p_new_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE book_copies
    SET copy_status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE copy_id = p_copy_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Copy ID % not found.', p_copy_id;
    END IF;
END;
$$;

-- Purpose: Allows a member to modify an existing review.
-- Parameters: p_review_id, p_new_rating, p_new_text
CREATE OR REPLACE PROCEDURE sp_update_review(
    p_review_id BIGINT,
    p_new_rating INT,
    p_new_text TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE reviews
    SET rating = p_new_rating,
        review_text = p_new_text,
        updated_at = CURRENT_TIMESTAMP
    WHERE review_id = p_review_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Review ID % not found.', p_review_id;
    END IF;
END;
$$;


-- =====================================================================
-- PERSON 3: CIRCULATION & MEMBERS
-- Tables: members, borrowings, reservations
-- =====================================================================

-- ---------------------------------------------------------------------
-- FUNCTIONS (Person 3)
-- ---------------------------------------------------------------------

-- Purpose: Checks if a member has any currently overdue books.
-- Parameters: p_member_id (BIGINT)
-- Expected behavior: Returns a BOOLEAN.
CREATE OR REPLACE FUNCTION fn_has_overdue_books(p_member_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_has_overdue BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM borrowings
        WHERE member_id = p_member_id
          AND returned_at IS NULL
          AND due_date < CURRENT_DATE
    ) INTO v_has_overdue;
    RETURN v_has_overdue;
END;
$$;

-- Purpose: Calculates the current position in the queue for a reservation.
-- Parameters: p_reservation_id (BIGINT)
CREATE OR REPLACE FUNCTION fn_get_queue_position(p_reservation_id BIGINT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_position INT;
BEGIN
    SELECT queue_position INTO v_position
    FROM reservations
    WHERE reservation_id = p_reservation_id;

    RETURN COALESCE(v_position, 0);
END;
$$;

-- Purpose: Retrieves the total active borrowings for a specific member.
-- Parameters: p_member_id (BIGINT)
CREATE OR REPLACE FUNCTION fn_get_active_borrowing_count(p_member_id BIGINT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_active_count INT;
BEGIN
    SELECT COUNT(*) INTO v_active_count
    FROM borrowings
    WHERE member_id = p_member_id AND returned_at IS NULL;

    RETURN v_active_count;
END;
$$;

-- ---------------------------------------------------------------------
-- SELECT/INSERT PROCEDURES (Person 3)
-- ---------------------------------------------------------------------

-- Purpose: Registers a new library member.
-- Parameters: First name, Last name, Email, Phone.
CREATE OR REPLACE PROCEDURE sp_register_member(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR,
    INOUT p_member_id BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO members (first_name, last_name, email, phone)
    VALUES (p_first_name, p_last_name, p_email, p_phone)
    RETURNING member_id INTO p_member_id;
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Email % is already registered.', p_email;
END;
$$;

-- Purpose: Creates a new borrowing record (Check-out process).
-- Parameters: p_member_id, p_copy_id, p_due_date
CREATE OR REPLACE PROCEDURE sp_checkout_book(
    p_member_id BIGINT,
    p_copy_id BIGINT,
    p_due_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_borrowing_id BIGINT;
BEGIN
    -- Validation
    IF p_due_date <= CURRENT_DATE THEN
        RAISE EXCEPTION 'Due date must be in the future.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM members WHERE member_id = p_member_id) THEN
        RAISE EXCEPTION 'Member ID % not found.', p_member_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM book_copies
                   WHERE copy_id = p_copy_id
                   AND copy_status = 'available') THEN
        RAISE EXCEPTION 'Copy ID % is not available for checkout.', p_copy_id;
    END IF;

    -- Transactional block with proper error handling
    BEGIN
        INSERT INTO borrowings (member_id, copy_id, borrowed_at, due_date)
        VALUES (p_member_id, p_copy_id, CURRENT_TIMESTAMP, p_due_date)
        RETURNING borrowing_id INTO v_borrowing_id;

        UPDATE book_copies
        SET copy_status = 'borrowed', updated_at = CURRENT_TIMESTAMP
        WHERE copy_id = p_copy_id;

    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE EXCEPTION 'Foreign key constraint violation during checkout.';
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Checkout failed: %', SQLERRM;
    END;
END;
$$;

-- ---------------------------------------------------------------------
-- UPDATE PROCEDURES (Person 3)
-- ---------------------------------------------------------------------

-- Purpose: Processes a book return.
-- Parameters: p_borrowing_id (BIGINT)
CREATE OR REPLACE PROCEDURE sp_return_book(
    p_borrowing_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_copy_id BIGINT;
BEGIN
    -- Mark as returned
    UPDATE borrowings
    SET returned_at = CURRENT_TIMESTAMP
    WHERE borrowing_id = p_borrowing_id AND returned_at IS NULL
    RETURNING copy_id INTO v_copy_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Active borrowing % not found.', p_borrowing_id;
    END IF;

    -- Make the copy available again
    UPDATE book_copies SET copy_status = 'available' WHERE copy_id = v_copy_id;
END;
$$;

-- Purpose: Cancels a pending reservation.
-- Parameters: p_reservation_id (BIGINT)
CREATE OR REPLACE PROCEDURE sp_cancel_reservation(
    p_reservation_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE reservations
    SET reservation_status = 'cancelled',
        queue_position = NULL
    WHERE reservation_id = p_reservation_id AND reservation_status = 'pending';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pending reservation % not found.', p_reservation_id;
    END IF;
END;
$$;

-- =====================================================================
-- TEST DATA SETUP (Active only if schema already created)
-- =====================================================================
-- NOTE: These INSERTs require that all tables from topic-04 are already
-- created in the database. Run topic-04 DDL script FIRST.
-- Uncomment the INSERT statements below after schema is ready.
-- =====================================================================
INSERT INTO categories (category_name) VALUES ('Fiction'), ('Non-Fiction');
INSERT INTO authors (first_name, last_name) VALUES ('John', 'Doe'), ('Jane', 'Smith');
INSERT INTO books (title, isbn, publication_year, category_id)
    VALUES ('Test Book', '9780000000001', 2020, 1);
INSERT INTO book_authors (book_id, author_id) VALUES (1, 1);
INSERT INTO members (first_name, last_name, email, phone)
    VALUES ('Test', 'User', 'test@example.com', '1234567890');

INSERT INTO borrowings (member_id, copy_id, borrowed_at, due_date, returned_at)
    VALUES (1, 1, CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_DATE - INTERVAL '5 days', NULL);

INSERT INTO reservations (member_id, book_id, reservation_date, reservation_status, queue_position)
    VALUES (1, 1, CURRENT_TIMESTAMP, 'pending', 1);


-- =====================================================================
-- TEST CALLS (Activate for verification)
-- =====================================================================

-- Person 1 Tests
SELECT fn_get_authors_for_book(1);
SELECT fn_count_books_by_category(1);
SELECT * FROM fn_get_books_by_author(1);

-- Person 2 Tests
SELECT fn_count_available_copies(1);
SELECT fn_get_avg_book_rating(1);
SELECT fn_get_latest_review(1);

-- Person 3 Tests
SELECT fn_has_overdue_books(1);
SELECT fn_get_queue_position(1);
SELECT fn_get_active_borrowing_count(1);