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

-- Horizontal view: базова інформація про книги (без зв’язків і агрегатів)
CREATE OR REPLACE VIEW book_metadata AS
SELECT
    book_id,
    title,
    isbn,
    publication_year
FROM books;

SELECT * FROM book_metadata;

-- Vertical view: тільки відгуки з найвищим рейтингом (5 зірок)
CREATE OR REPLACE VIEW best_reviews AS
SELECT
    review_id,
    member_id,
    book_id,
    rating,
    review_text
FROM reviews
WHERE rating = 5;

SELECT * FROM best_reviews;

-- Mixed view: доступні копії книг (фільтрація + вибір колонок)
CREATE OR REPLACE VIEW available_copies AS
SELECT
    copy_id,
    book_id,
    copy_number
FROM book_copies
WHERE copy_status = 'available';

SELECT * FROM available_copies;

-- Join view: відгуки разом з даними про користувача та книгу
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

SELECT * FROM member_review;

-- Subquery view: отримання імені читача через підзапит
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

-- View based on another view: розширення subquery view додаванням назви книги
CREATE OR REPLACE VIEW member_review_details AS
SELECT
    b.title,
    s.first_name,
    s.rating,
    s.review_text
FROM member_review_sub s
JOIN books b ON b.book_id = s.book_id;

SELECT * FROM member_review_details;

-- UNION view: об’єднання активних видач та резервацій у єдиний список активностей
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

SELECT * FROM library_activity;

-- Updatable view with CHECK OPTION: дозволяє редагування тільки для відгуків з рейтингом >= 4
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

SELECT * FROM high_rated_reviews;