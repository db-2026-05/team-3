-- ================================================================
-- SQL DDL TEMPLATE (TOPIC 04)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) Full PostgreSQL DDL for your finalized schema.
-- 2) CREATE TABLE statements for all entities from your ER diagram.
-- 3) Primary keys, foreign keys, NOT NULL, UNIQUE, CHECK constraints.
-- 4) Indexes for important search/join columns.
-- 5) Clean structure and comments (group by tables/constraints/indexes).
--
-- RECOMMENDED ORDER:
-- 1) Tables
-- 2) Constraints (if not inline)
-- 3) Indexes
--
-- TEAM NOTE:
-- Add short attribution comments for who implemented which part.
-- Example:
-- [Name] - users, roles, permissions tables
-- [Name] - orders, payments, invoices tables
--
-- IMPORTANT:
-- The script must run in PostgreSQL and produce a working schema that
-- matches your approved ER diagram and conceptual schema.
-- Submit this as one SQL file.
-- ================================================================

-- Add your DDL below this line

-- ======================================================
-- MEMBERS
-- ======================================================

CREATE TABLE members (
    member_id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50),
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ======================================================
-- CATEGORIES
-- ======================================================

CREATE TABLE categories (
    category_id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- ======================================================
-- AUTHORS
-- ======================================================

CREATE TABLE authors (
    author_id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL
);

-- ======================================================
-- BOOKS
-- ======================================================

CREATE TABLE books (
    book_id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(50) NOT NULL UNIQUE,
    publication_year INT,
    category_id BIGINT NOT NULL,
    CONSTRAINT fk_books_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_books_publication_year
        CHECK (
            publication_year IS NULL
            OR publication_year BETWEEN 0 AND EXTRACT(YEAR FROM CURRENT_DATE)::INT + 1
        )
);

-- ======================================================
-- BOOK COPIES
-- ======================================================

CREATE TABLE book_copies (
    copy_id BIGSERIAL PRIMARY KEY,
    book_id BIGINT NOT NULL,
    copy_number INT NOT NULL,  -- Порядковий номер; унікальний у межах книги. Може мати розриви.
    copy_status VARCHAR(50) NOT NULL,
    acquired_date DATE NOT NULL DEFAULT CURRENT_DATE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_book_copies_book
        FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT uq_book_copies_book_copy_number
        UNIQUE (book_id, copy_number),

    CONSTRAINT chk_book_copies_copy_number
        CHECK (copy_number > 0),

    -- copy_status описує лише фізичний стан копії.
    -- Резервація — окрема концепція (таблиця reservations), не стан копії.
    CONSTRAINT chk_book_copies_status
        CHECK (copy_status IN ('available', 'borrowed', 'lost', 'unavailable')),
)

-- ======================================================
-- BORROWINGS
-- ======================================================

CREATE TABLE borrowings (
    borrowing_id BIGSERIAL PRIMARY KEY,
    member_id BIGINT NOT NULL,
    copy_id BIGINT NOT NULL,
    borrowed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    returned_at TIMESTAMP,  -- NULL = активне borrowing; заповнена = повернено

    CONSTRAINT fk_borrowings_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_borrowings_copy
        FOREIGN KEY (copy_id)
        REFERENCES book_copies(copy_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_borrowings_due_after_borrowed
        CHECK (due_date >= DATE(borrowed_at)),

    CONSTRAINT chk_borrowings_due_is_future
        CHECK (due_date >= CURRENT_DATE),

    CONSTRAINT chk_borrowings_returned_after_borrowed
        CHECK (
            returned_at IS NULL
            OR returned_at >= borrowed_at
        )
);

-- ======================================================
-- BOOK_AUTHORS (many-to-many)
-- ======================================================

CREATE TABLE book_authors (
    book_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,

    CONSTRAINT pk_book_authors
        PRIMARY KEY (book_id, author_id),

    CONSTRAINT fk_book_authors_book
        FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_book_authors_author
        FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ======================================================
-- RESERVATIONS
-- ======================================================

CREATE TABLE reservations (
    reservation_id BIGSERIAL PRIMARY KEY,
    member_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    copy_id BIGINT, -- NULL = резервація в черзі; заповнена = копія виділена
    reservation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reservation_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    queue_position INT,  -- Позиція в черзі очікування (1, 2, 3...)

    CONSTRAINT fk_reservations_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_reservations_book
        FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_reservations_copy
        FOREIGN KEY (copy_id)
        REFERENCES book_copies(copy_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_reservations_status
        CHECK (reservation_status IN ('pending', 'assigned', 'fulfilled', 'cancelled')),

    CONSTRAINT chk_reservations_queue_position
        CHECK (
            queue_position IS NULL
            OR queue_position > 0
        )
);

-- ======================================================
-- REVIEWS
-- ======================================================

CREATE TABLE reviews (
    review_id BIGSERIAL PRIMARY KEY,
    member_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    rating INT NOT NULL,
    review_text TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reviews_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_reviews_book
        FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT uq_reviews_member_book
        UNIQUE (member_id, book_id),

    CONSTRAINT chk_reviews_rating
        CHECK (rating BETWEEN 1 AND 5)
);

-- ======================================================
-- INDEXES
-- ======================================================

CREATE INDEX idx_books_category_id
    ON books(category_id);

CREATE INDEX idx_book_copies_book_id
    ON book_copies(book_id);

CREATE INDEX idx_borrowings_member_id
    ON borrowings(member_id);

CREATE INDEX idx_borrowings_copy_id
    ON borrowings(copy_id);

CREATE INDEX idx_borrowings_due_date
    ON borrowings(due_date);

-- Partial index для запитів активних видач (returned_at IS NULL):
-- покриває "знайти активне borrowing для копії" та "active borrowings of member".
CREATE INDEX idx_borrowings_active
    ON borrowings(copy_id)
    WHERE returned_at IS NULL;

CREATE INDEX idx_book_authors_author_id
    ON book_authors(author_id);

-- idx_reservations_member_id навмисно НЕ створюється:
-- prefix-index композитного idx_reservations_member_book вже покриває
-- запити з фільтром лише по member_id.

CREATE INDEX idx_reservations_book_id
    ON reservations(book_id);

CREATE INDEX idx_reservations_copy_id
    ON reservations(copy_id);

CREATE INDEX idx_reservations_member_book
    ON reservations(member_id, book_id);

-- Partial unique index:
-- one pending reservation per member per book
CREATE UNIQUE INDEX uq_reservations_pending_member_book
    ON reservations(member_id, book_id)
    WHERE reservation_status = 'pending';

CREATE INDEX idx_reviews_book_id
    ON reviews(book_id);

CREATE INDEX idx_reviews_member_id
    ON reviews(member_id);