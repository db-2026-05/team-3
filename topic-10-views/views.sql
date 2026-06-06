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
-- SQL VIEWS TEMPLATE (TOPIC 10)
-- Library Management System
-- ================================================================

-- ================================================================
-- HORIZONTAL VIEW
-- Purpose:
-- Displays only key member contact information.
-- Used when full member details are not required.
-- ================================================================
CREATE OR REPLACE VIEW member_contacts AS
SELECT
    member_id,
    first_name,
    last_name,
    email
FROM members;

SELECT * FROM member_contacts;


-- ================================================================
-- VERTICAL VIEW
-- Purpose:
-- Shows only reviews with the highest rating.
-- Used for displaying featured reviews.
-- ================================================================
CREATE OR REPLACE VIEW best_reviews_only AS
SELECT
    review_id,
    member_id,
    book_id,
    rating,
    review_text
FROM reviews
WHERE rating = 5;

SELECT * FROM best_reviews_only;


-- ================================================================
-- MIXED VIEW
-- Purpose:
-- Combines column selection and row filtering.
-- Displays only active members with essential information.
-- ================================================================
CREATE OR REPLACE VIEW active_members AS
SELECT
    member_id,
    first_name,
    last_name,
    email
FROM members
WHERE membership_status = 'ACTIVE';

SELECT * FROM active_members;


-- ================================================================
-- JOIN VIEW
-- Purpose:
-- Shows member reviews together with member information.
-- Demonstrates a view based on multiple tables.
-- ================================================================
CREATE OR REPLACE VIEW member_review AS
SELECT
    m.member_id,
    m.first_name,
    r.book_id,
    r.rating,
    r.review_text
FROM reviews r
JOIN members m
    ON m.member_id = r.member_id;

SELECT * FROM member_review;


-- ================================================================
-- AGGREGATE / INVENTORY VIEW
-- Purpose:
-- Displays the number of available copies for each book.
-- Supports inventory monitoring.
-- ================================================================
CREATE OR REPLACE VIEW book_inventory AS
SELECT
    b.book_id,
    b.title,
    COUNT(bc.copy_id) AS copy_count
FROM books b
LEFT JOIN book_copies bc
    ON bc.book_id = b.book_id
GROUP BY b.book_id, b.title;

SELECT * FROM book_inventory;


-- ================================================================
-- SUBQUERY VIEW
-- Purpose:
-- Demonstrates the use of a subquery inside a view.
-- Retrieves reviewer names through a correlated subquery.
-- ================================================================
CREATE OR REPLACE VIEW member_review_sub AS
SELECT
    (
        SELECT m.first_name
        FROM members m
        WHERE m.member_id = r.member_id
    ) AS first_name,
    r.book_id,
    r.rating,
    r.review_text
FROM reviews r;

SELECT * FROM member_review_sub;


-- ================================================================
-- VIEW BASED ON ANOTHER VIEW
-- Purpose:
-- Extends member_review_sub with book titles.
-- Demonstrates layered view architecture.
-- ================================================================
CREATE OR REPLACE VIEW member_review_sub_book AS
SELECT
    b.title,
    r.first_name,
    r.rating,
    r.review_text
FROM member_review_sub r
LEFT JOIN books b
    ON b.book_id = r.book_id;

SELECT * FROM member_review_sub_book;


-- ================================================================
-- UNION VIEW
-- Purpose:
-- Combines review information from two sources.
-- Demonstrates UNION operation in views.
-- ================================================================
CREATE OR REPLACE VIEW review_union AS
SELECT
    first_name,
    CAST(book_id AS TEXT) AS book_info,
    rating,
    review_text
FROM member_review_sub

UNION

SELECT
    first_name,
    title AS book_info,
    rating,
    review_text
FROM member_review_sub_book;

SELECT * FROM review_union;


-- ================================================================
-- UPDATABLE VIEW WITH CHECK OPTION
-- Purpose:
-- Allows updates only for reviews with rating >= 4.
-- CHECK OPTION prevents modifications that would
-- violate the view condition.
-- ================================================================
CREATE OR REPLACE VIEW high_rated_reviews AS
SELECT
    review_id,
    member_id,
    book_id,
    rating,
    review_text
FROM reviews
WHERE rating >= 4
WITH CHECK OPTION;

SELECT * FROM high_rated_reviews;