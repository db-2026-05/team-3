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
-- Schema: see ddl.sql (PostgreSQL)
-- ================================================================


-- ================================================================
-- HORIZONTAL VIEW
-- PURPOSE: Базова інформація про книги без зв'язків
-- USE CASE: Каталог книг у бібліотеці
-- ================================================================
CREATE OR REPLACE VIEW book_metadata AS
SELECT
    book_id,
    title,
    isbn,
    publication_year
FROM books;


-- ================================================================
-- VERTICAL VIEW
-- PURPOSE: Відображення тільки найкращих відгуків (5 зірок)
-- USE CASE: Рекомендовані відгуки
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
-- MIXED VIEW
-- PURPOSE: Доступні копії книг
-- USE CASE: Перевірка наявності книг для видачі
-- ================================================================
CREATE OR REPLACE VIEW available_copies AS
SELECT
    copy_id,
    book_id,
    copy_number
FROM book_copies
WHERE copy_status = 'available';


-- ================================================================
-- JOIN VIEW
-- PURPOSE: Відгуки разом з користувачами та книгами
-- USE CASE: Панель адміністратора / UI відгуків
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
-- SUBQUERY VIEW
-- PURPOSE: Отримання даних через correlated subquery
-- IMPORTANT: містить member_id для подальших join
-- ================================================================
CREATE OR REPLACE VIEW member_review_sub AS
SELECT
    r.member_id,
    (
        SELECT m.first_name
        FROM members m
        WHERE m.member_id = r.member_id
    ) AS first_name,
    r.book_id,
    r.rating,
    r.review_text
FROM reviews r;


-- ================================================================
-- VIEW BASED ON ANOTHER VIEW
-- PURPOSE: Розширення subquery view з назвами книг
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
-- UNION VIEW
-- PURPOSE: Об'єднання активних borrowings і reservations
-- NOTE: всі колонки синхронізовані за назвою і типом
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

UNION

SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    b.title,
    'RESERVATION' AS activity_type,
    r.reservation_date AS activity_date
FROM reservations r
JOIN members m ON m.member_id = r.member_id
JOIN books b ON b.book_id = r.book_id
WHERE r.reservation_status = 'pending';


-- ================================================================
-- UPDATABLE VIEW WITH CHECK OPTION
-- PURPOSE: Дозволяє змінювати тільки високорейтингові відгуки
-- NOTE: INSERT/UPDATE з rating < 4 буде відхилено
-- NULL rating також відхиляється (UNKNOWN в CHECK OPTION)
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