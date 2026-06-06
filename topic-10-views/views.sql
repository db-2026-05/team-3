-- ================================================================
-- SQL VIEWS TEMPLATE (TOPIC 10)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE VIEW scripts for required view types:
--    - Horizontal view (select specific columns)
--    - Vertical view (filter specific rows)
--    - Mixed view (columns + row filters)
--    - Join-based view (multiple tables)
--    - Subquery-based view
--    - UNION-based view
--    - View based on another view
--    - Updatable view with WITH CHECK OPTION
--
-- 2) Comments before each view explaining:
--    - Purpose of the view
--    - How it supports your project design
--
-- 3) Optional demo SELECT statements to show view output.
--
-- RECOMMENDED ORDER:
-- 1) Simple views (horizontal / vertical / mixed)
-- 2) Join and subquery views
-- 3) UNION and layered views
-- 4) CHECK OPTION view
--
-- IMPORTANT:
-- - Script must execute in PostgreSQL without errors.
-- - Keep naming consistent and readable.
-- - Submit all views in this single SQL file.
-- ================================================================

-- Add your CREATE VIEW statements below this line

-- ================================================================

-- SQL VIEWS (TOPIC 10)
-- Library Management System
-- Schema: ddl.sql (MUST BE EXECUTED FIRST)

-- ================================================================
-- NOTE:
-- This file depends on existing schema:
-- members, books, borrowings, book_copies, reviews, reservations

-- ================================================================
-- HORIZONTAL VIEW: book_metadata
-- ================================================================

CREATE OR REPLACE VIEW book_metadata AS
SELECT
    book_id,
    title,
    isbn,
    publication_year
FROM books;

-- ================================================================
-- VERTICAL VIEW: best_reviews
-- ================================================================

CREATE OR REPLACE VIEW best_reviews AS
SELECT
    review_id,
    member_id,
    book_id,
    rating,
    review_text
FROM reviews
WHERE rating = 5;

-- ================================================================
-- MIXED VIEW: available_copies
-- ================================================================

CREATE OR REPLACE VIEW available_copies AS
SELECT
    copy_id,
    book_id,
    copy_number
FROM book_copies
WHERE copy_status = 'available';

-- ================================================================
-- JOIN VIEW: member_review
-- ================================================================

CREATE OR REPLACE VIEW member_review AS
SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    b.book_id,
    b.title,
    r.rating,
    r.review_text
FROM reviews r
JOIN members m ON m.member_id = r.member_id
JOIN books b ON b.book_id = r.book_id;

-- ================================================================
-- SUBQUERY VIEW (REQUIRED CORRELATED SUBQUERY)
-- ================================================================

CREATE OR REPLACE VIEW member_review_sub AS
SELECT
    r.review_id,
    r.member_id,
    (SELECT m.first_name
     FROM members m
     WHERE m.member_id = r.member_id) AS first_name,
    r.book_id,
    r.rating,
    r.review_text
FROM reviews r;

-- ================================================================
-- VIEW BASED ON ANOTHER VIEW
-- ================================================================

CREATE OR REPLACE VIEW member_review_details AS
SELECT
    b.title,
    s.member_id,
    s.first_name,
    s.rating,
    s.review_text
FROM member_review_sub s
JOIN books b ON b.book_id = s.book_id;

-- ================================================================
-- UNION VIEW (FIXED BUSINESS LOGIC)
-- NOTE: reservations MAY have NULL copy_id → no join to book_copies
-- ================================================================

CREATE OR REPLACE VIEW library_activity AS
SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    b.title,
    'BORROWING' AS activity_type,
    br.borrowed_at AS activity_date
FROM borrowings br
JOIN members m ON m.member_id = br.member_id
JOIN book_copies bc ON bc.copy_id = br.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE br.returned_at IS NULL

UNION ALL

SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    b.title,
    'RESERVATION' AS activity_type,
    r.reservation_date AS activity_date
FROM reservations r
JOIN members m ON m.member_id = r.member_id
JOIN books b ON b.book_id = r.book_id
WHERE r.reservation_status IN ('pending', 'assigned', 'fulfilled');

-- ================================================================
-- CHECK OPTION VIEW
-- ================================================================

CREATE OR REPLACE VIEW high_rated_reviews AS
SELECT
    review_id,
    member_id,
    book_id,
    rating,
    review_text,
    created_at,
    updated_at
FROM reviews
WHERE rating >= 4
WITH CHECK OPTION;

-- ================================================================
-- BUSINESS VIEW: overdue borrowings
-- ================================================================

CREATE OR REPLACE VIEW overdue_borrowings AS
SELECT
    br.borrowing_id,
    m.first_name,
    m.last_name,
    b.title,
    br.due_date,
    (CURRENT_TIMESTAMP - br.due_date) AS days_overdue
FROM borrowings br
JOIN members m ON m.member_id = br.member_id
JOIN book_copies bc ON bc.copy_id = br.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE br.returned_at IS NULL
  AND br.due_date < CURRENT_TIMESTAMP;

-- ================================================================
-- BUSINESS VIEW: popular books
-- ================================================================

CREATE OR REPLACE VIEW popular_books AS
SELECT
    b.book_id,
    b.title,
    COUNT(r.review_id) AS review_count,
    AVG(r.rating) AS avg_rating
FROM books b
LEFT JOIN reviews r ON r.book_id = b.book_id
GROUP BY b.book_id, b.title;

-- ================================================================
-- BUSINESS VIEW: reading history (FIXED MISSING REQUIREMENT)
-- ================================================================

CREATE OR REPLACE VIEW reading_history AS
SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    b.title,
    br.borrowed_at,
    br.returned_at,
    EXTRACT(DAY FROM br.returned_at - br.borrowed_at) AS days_borrowed
FROM borrowings br
JOIN members m ON m.member_id = br.member_id
JOIN book_copies bc ON bc.copy_id = br.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE br.returned_at IS NOT NULL;

-- ================================================================
-- BUSINESS VIEW: book inventory status (FIXED REQUIREMENT)
-- ================================================================

CREATE OR REPLACE VIEW book_inventory_status AS
SELECT
    b.book_id,
    b.title,
    COUNT(bc.copy_id) AS total_copies,
    SUM(CASE WHEN bc.copy_status = 'available' THEN 1 ELSE 0 END) AS available_count,
    SUM(CASE WHEN bc.copy_status = 'borrowed' THEN 1 ELSE 0 END) AS borrowed_count,
    SUM(CASE WHEN bc.copy_status = 'unavailable' THEN 1 ELSE 0 END) AS unavailable_count
FROM books b
LEFT JOIN book_copies bc ON bc.book_id = b.book_id
GROUP BY b.book_id, b.title;

-- ================================================================
-- DEMO QUERIES (REQUIRED BY REVIEW)
-- ================================================================

SELECT * FROM book_metadata LIMIT 3;
SELECT * FROM best_reviews LIMIT 3;
SELECT * FROM available_copies LIMIT 3;
SELECT * FROM member_review LIMIT 3;
SELECT * FROM member_review_sub LIMIT 3;
SELECT * FROM member_review_details LIMIT 3;
SELECT * FROM library_activity LIMIT 3;
SELECT * FROM high_rated_reviews LIMIT 3;
SELECT * FROM overdue_borrowings LIMIT 3;
SELECT * FROM reading_history LIMIT 3;
SELECT * FROM book_inventory_status LIMIT 3;
SELECT * FROM popular_books LIMIT 3;