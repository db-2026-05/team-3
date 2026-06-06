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
-- Requires: ddl.sql executed first
-- ================================================================


-- ================================================================
-- SQL VIEWS (TOPIC 10)
-- Library Management System
-- Requires: ddl.sql executed first
-- ================================================================
-- Purpose: Забезпечити сокращену версію каталогу книг
--          (без фізичних копій та відгуків) для публічного перегляду.
--
-- Business Context:
--   - Відвідувачі хочуть бачити загальний список книг без деталей про копії
--   - Каталог сортується за назвою для зручності пошуку
--
-- Related Tables: books, categories
-- Supports: Book discovery, catalog browsing
-- ================================================================
CREATE OR REPLACE VIEW book_catalog AS
SELECT
    book_id,
    title,
    isbn,
    publication_year,
    category_id
FROM books;


-- ================================================================
-- VERTICAL VIEW: recent_reviews
-- Purpose: Відгуки за останні 30 днів
-- ================================================================
CREATE OR REPLACE VIEW recent_reviews AS
SELECT *
FROM reviews
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days';


-- ================================================================
-- MIXED VIEW: available_copies
-- Purpose: Доступні копії книг
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
-- Purpose: Відгуки разом з користувачами та книгами
-- ================================================================
CREATE OR REPLACE VIEW member_review AS
SELECT
    r.review_id,
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.book_id,
    b.title,
    r.rating,
    r.review_text,
    r.created_at
FROM reviews r
JOIN members m ON m.member_id = r.member_id
JOIN books b ON b.book_id = r.book_id;


-- ================================================================
-- SUBQUERY VIEW: members_with_book_count
-- Purpose: Кількість активних позичених книг
-- ================================================================
CREATE OR REPLACE VIEW members_with_book_count AS
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    (
        SELECT COUNT(*)
        FROM borrowings br
        WHERE br.member_id = m.member_id
          AND br.returned_at IS NULL
    ) AS active_books_count
FROM members m;


-- ================================================================
-- VIEW BASED ON ANOTHER VIEW
-- ================================================================
CREATE OR REPLACE VIEW member_review_details AS
SELECT
    review_id,
    member_id,
    member_name,
    book_id,
    title,
    rating,
    review_text
FROM member_review;


-- ================================================================
-- UNION VIEW: library_activity
-- ================================================================
-- Purpose: Об'єднати всі активні дії члена бібліотеки
--          (видачу книг та резервацію).
--
-- Business Context:
--   - Члени можуть переглядати свою активність в одному місці
--   - Дозволяє отримати хронологію всіх операцій
--
-- Structure (both SELECT must have identical columns):
--   1. member_id (bigint)
--   2. member_name (text)
--   3. title (text)
--   4. activity_type (text: 'BORROWING' or 'RESERVATION')
--   5. activity_date (timestamp)
--   6. status (text)
--
-- Active Filter:
--   - BORROWING: only returned_at IS NULL
--   - RESERVATION: only status IN ('pending', 'assigned')
-- ================================================================
CREATE OR REPLACE VIEW library_activity AS

SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title,
    'BORROWING' AS activity_type,
    br.borrowed_at AS activity_date,
    'active' AS status
FROM borrowings br
JOIN members m ON m.member_id = br.member_id
JOIN book_copies bc ON bc.copy_id = br.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE br.returned_at IS NULL

UNION ALL

SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title,
    'RESERVATION' AS activity_type,
    r.reservation_date AS activity_date,
    r.reservation_status AS status
FROM reservations r
JOIN members m ON m.member_id = r.member_id
JOIN books b ON b.book_id = r.book_id
WHERE r.reservation_status IN ('pending', 'assigned');


-- ================================================================
-- UPDATABLE VIEW WITH CHECK OPTION: high_rated_reviews
-- ================================================================
-- Purpose: Забезпечити шар, через який можна редагувати тільки
--          позитивні відгуки (rating >= 4).
--          Запобігає помилковому зниженню рейтингу через цей view.
--
-- Business Logic:
--   - Адміністратори можуть оновлювати high_rated_reviews без ризику
--     випадково зробити рейтинг < 4
--
-- Constraints: rating >= 4 (CHECK OPTION)
-- Updatable: YES (INSERT, UPDATE, DELETE)
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

-- NOTE:
-- WITH CHECK OPTION гарантує:
-- INSERT/UPDATE через view НЕ може створити rating < 4


-- ================================================================
-- ANALYTICS VIEW: popular_books
-- ================================================================
CREATE OR REPLACE VIEW popular_books AS
SELECT
    b.book_id,
    b.title,
    c.category_name,
    COUNT(r.review_id) AS review_count,
    COALESCE(AVG(r.rating)::NUMERIC(3,2), 0) AS avg_rating,
    CASE
        WHEN COUNT(r.review_id) = 0 THEN 'no reviews'
        WHEN AVG(r.rating) >= 4.5 THEN 'highly rated'
        ELSE 'standard'
    END AS popularity_status
FROM books b
LEFT JOIN categories c ON c.category_id = b.category_id
LEFT JOIN reviews r ON r.book_id = b.book_id
GROUP BY b.book_id, b.title, c.category_name;


-- ================================================================
-- READING HISTORY VIEW
-- ================================================================
CREATE OR REPLACE VIEW reading_history_extended AS
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title,
    br.borrowed_at,
    br.returned_at,
    CASE
        WHEN br.returned_at IS NULL THEN NULL
        ELSE EXTRACT(DAY FROM br.returned_at - br.borrowed_at)
    END AS days_borrowed,
    CASE
        WHEN br.returned_at IS NULL THEN 'active'
        ELSE 'completed'
    END AS status
FROM borrowings br
JOIN members m ON m.member_id = br.member_id
JOIN book_copies bc ON bc.copy_id = br.copy_id
JOIN books b ON b.book_id = bc.book_id;


-- ================================================================
-- OVERDUE BORROWINGS VIEW
-- ================================================================
CREATE OR REPLACE VIEW overdue_borrowings AS
SELECT
    br.borrowing_id,
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title,
    br.due_date,
    (CURRENT_DATE - br.due_date) AS days_overdue
FROM borrowings br
JOIN members m ON m.member_id = br.member_id
JOIN book_copies bc ON bc.copy_id = br.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE br.returned_at IS NULL
  AND br.due_date < CURRENT_DATE;


-- ================================================================
-- DEMO QUERIES (SAFE + DETERMINISTIC)
-- ================================================================
SELECT * FROM book_catalog ORDER BY book_id LIMIT 3;
SELECT * FROM recent_reviews ORDER BY created_at DESC LIMIT 3;
SELECT * FROM available_copies ORDER BY copy_id LIMIT 3;
SELECT * FROM member_review ORDER BY review_id LIMIT 3;
SELECT * FROM members_with_book_count ORDER BY member_id LIMIT 3;
SELECT * FROM popular_books ORDER BY review_count DESC LIMIT 3;
SELECT * FROM overdue_borrowings ORDER BY days_overdue DESC LIMIT 5;