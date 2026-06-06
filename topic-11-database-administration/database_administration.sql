-- ================================================================
-- DATABASE ADMINISTRATION TEMPLATE (TOPIC 11)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE ROLE statements for at least 2 distinct roles.
--    Example roles: read-only analyst, read-write editor.
--
-- 2) GRANT statements assigning appropriate permissions to each role:
--    - Read-only role: GRANT SELECT ON ALL TABLES IN SCHEMA ...
--    - Read-write role: GRANT SELECT, INSERT, UPDATE, DELETE ...
--
-- 3) CREATE USER statements for at least 2 users.
--    Each user must be assigned to one of the defined roles.
--
-- 4) Comments before each section explaining the rationale:
--    - Why this role exists
--    - What access it should and should not have
--
-- RECOMMENDED ORDER:
-- 1) Roles + their GRANTs
-- 2) Users + GRANT ROLE TO USER
-- 3) Optional: REVOKE statements for fine-grained restrictions
-- 4) Optional cleanup block (commented out by default):
--    -- DROP USER ...; DROP ROLE ...;
--
-- IMPORTANT:
-- - Use explicit GRANT / REVOKE statements — do not rely on defaults.
-- - Roles must have meaningfully different permission levels.
-- - Script must execute in PostgreSQL without errors.
-- ================================================================

-- Add your script below this line


-- ======================================================
-- SECURITY SCRIPT
-- 6 Roles, 6 Users, Explicit Grants & Least Privilege
-- ======================================================

BEGIN;

-- ======================================================
-- 1. CREATE GROUP ROLES
-- ======================================================
-- Domain: Catalog (Books & Authors)
-- catalog_manager: Read-write role to maintain the library's inventory.
-- catalog_viewer: Read-only role to safely browse the catalog without altering data.
-- 
-- Domain: Members (Members & Reviews)
-- member_admin: Read-write role to register and manage library members.
-- member_support: Read-only role to view member statuses securely.
-- 
-- Domain: Circulation & Global Audit
-- circulation_staff: Read-write role to process loans, returns, and reservations.
-- audit_viewer: Global read-only role for reporting and compliance audits.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'catalog_manager') THEN
        CREATE ROLE catalog_manager NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'catalog_viewer') THEN
        CREATE ROLE catalog_viewer NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'member_admin') THEN
        CREATE ROLE member_admin NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'member_support') THEN
        CREATE ROLE member_support NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'circulation_staff') THEN
        CREATE ROLE circulation_staff NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'audit_viewer') THEN
        CREATE ROLE audit_viewer NOLOGIN;
    END IF;
END
$$;

-- ======================================================
-- 2. REVOKE BROAD DEFAULT ACCESS
-- ======================================================
-- Enforce least privilege by removing default public access from the schema
-- before explicitly granting necessary permissions.

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

-- ======================================================
-- 3. GRANT PERMISSIONS TO ROLES
-- ======================================================

-- Allow schema usage for all functional roles
GRANT USAGE ON SCHEMA public TO 
    catalog_manager, catalog_viewer, 
    member_admin, member_support, 
    circulation_staff, audit_viewer;

-- -------------------------
-- Domain: Catalog
-- -------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON books, authors, book_authors TO catalog_manager;
GRANT USAGE, SELECT ON books_book_id_seq, authors_author_id_seq TO catalog_manager;

GRANT SELECT ON books, authors, book_authors TO catalog_viewer;

-- -------------------------
-- Domain: Members
-- -------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON members, reviews TO member_admin;
GRANT USAGE, SELECT ON members_member_id_seq, reviews_review_id_seq TO member_admin;

GRANT SELECT ON members, reviews TO member_support;

-- -------------------------
-- Domain: Circulation & Audit
-- -------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON borrowings, book_copies, reservations TO circulation_staff;
GRANT USAGE, SELECT ON borrowings_borrowing_id_seq, book_copies_copy_id_seq, reservations_reservation_id_seq TO circulation_staff;
-- Staff must be able to verify member and book details to process transactions
GRANT SELECT ON members, books TO circulation_staff; 

-- Auditors require complete visibility across all tables
GRANT SELECT ON ALL TABLES IN SCHEMA public TO audit_viewer;

-- ======================================================
-- 4. REVOKE TO ENFORCE STRICT LEAST-PRIVILEGE
-- ======================================================
-- Prevent the physical deletion of core entities and histories.
-- This ensures records are properly archived (e.g., status changes) 
-- instead of permanently erased, maintaining database integrity.

REVOKE DELETE ON books FROM catalog_manager;       
REVOKE DELETE ON members FROM member_admin;        
REVOKE DELETE ON borrowings FROM circulation_staff; 

-- ======================================================
-- 5. CREATE USERS
-- ======================================================

DO $$
BEGIN
    -- Users for Catalog Management
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'catalog_rw_user') THEN
        CREATE USER catalog_rw_user WITH LOGIN INHERIT PASSWORD 'CatRw_2026!';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'catalog_ro_user') THEN
        CREATE USER catalog_ro_user WITH LOGIN INHERIT PASSWORD 'CatRo_2026!';
    END IF;

    -- Users for Member Management
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'member_rw_user') THEN
        CREATE USER member_rw_user WITH LOGIN INHERIT PASSWORD 'MemRw_2026!';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'member_ro_user') THEN
        CREATE USER member_ro_user WITH LOGIN INHERIT PASSWORD 'MemRo_2026!';
    END IF;

    -- Users for Circulation and Audit
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'circ_rw_user') THEN
        CREATE USER circ_rw_user WITH LOGIN INHERIT PASSWORD 'CircRw_2026!';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'audit_ro_user') THEN
        CREATE USER audit_ro_user WITH LOGIN INHERIT PASSWORD 'AudRo_2026!';
    END IF;
END
$$;

-- ======================================================
-- 6. ASSIGN USERS TO ROLES
-- ======================================================

GRANT catalog_manager TO catalog_rw_user;
GRANT catalog_viewer TO catalog_ro_user;

GRANT member_admin TO member_rw_user;
GRANT member_support TO member_ro_user;

GRANT circulation_staff TO circ_rw_user;
GRANT audit_viewer TO audit_ro_user;

COMMIT;

-- ======================================================
-- 7. OPTIONAL CLEANUP BLOCK
-- Commented out by default
-- ======================================================

/*
REVOKE catalog_manager FROM catalog_rw_user;
REVOKE catalog_viewer FROM catalog_ro_user;
REVOKE member_admin FROM member_rw_user;
REVOKE member_support FROM member_ro_user;
REVOKE circulation_staff FROM circ_rw_user;
REVOKE audit_viewer FROM audit_ro_user;

DROP USER IF EXISTS catalog_rw_user, catalog_ro_user;
DROP USER IF EXISTS member_rw_user, member_ro_user;
DROP USER IF EXISTS circ_rw_user, audit_ro_user;

DROP ROLE IF EXISTS catalog_manager, catalog_viewer;
DROP ROLE IF EXISTS member_admin, member_support;
DROP ROLE IF EXISTS circulation_staff, audit_viewer;
*/
