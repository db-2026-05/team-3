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

-- Mixed views + JOIN
CREATE OR REPLACE VIEW book_inventory AS
SELECT b.title, b.book_id, count(b.book_id) AS copy_count
FROM books b
LEFT JOIN book_copies bc ON bc.book_id = b.book_id
GROUP BY b.book_id;

SELECT * FROM book_inventory;

-- Vertical + JOIN
CREATE OR REPLACE VIEW member_review AS
SELECT m.member_id, r.rating, r.review_text
FROM reviews r
JOIN members m ON m.member_id = r.member_id;

SELECT * FROM member_review;


-- Horizontal + CHECK OPTION
CREATE OR REPLACE VIEW best_reviews AS
SELECT * FROM reviews WHERE rating = 5
WITH CHECK OPTIONS;

SELECT * FROM best_reviews;

-- Subqueries
CREATE OR REPLACE VIEW member_review_sub AS
SELECT
(SELECT m.first_name FROM members m WHERE m.member_id = r.member_id),
r.book_id,
r.rating,
r.review_text
FROM reviews r;

SELECT * FROM member_review_sub;

-- VIEW in VIEW
CREATE OR REPLACE VIEW member_review_sub_book AS
SELECT
b.title,
r.first_name,
r.rating,
r.review_text
FROM member_review_sub r
LEFT JOIN books b ON b.book_id = r.book_id;

SELECT * FROM member_review_sub_book;

-- UNION
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
