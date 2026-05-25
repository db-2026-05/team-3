# TEAMWORK - Topic 04 (SQL DDL)

## Склад команди
- Команда: Team 3
- Варіант предметної області: Library Management System

## Таблиця внесків

| Учасник | Роль у команді | Що зроблено | Артефакти / файли |
|---|---|---|---|
| Novikov Volodymyr | Database Architect / Team Lead | Overall DDL architecture, PK/FK integrity, constraints, section ordering, PostgreSQL compatibility validation | `ddl.sql` (schema foundation, `books`, `categories`, `authors`, `book_authors`) |
| Zhyryk Vitaliy | Inventory System, Reviews, Testing & Documentation | `book_copies` DDL (copy statuses, conditions, unique copy numbers); `reviews` DDL (rating CHECK, one-review-per-member-book); testing, documentation | `ddl.sql` (`book_copies`, `reviews`), project documentation |
| Volodymyr Fedorkiv | Borrowing & Reservation System | `members`, `borrowings`, `reservations` DDL; partial unique index on pending reservations; active-borrowings index | `ddl.sql` (`members`, `borrowings`, `reservations`) |

## Контекст теми
Створення базових таблиць (books, authors, categories, members) та normalization support tables (book_authors) координував Novikov Volodymyr.
PK/FK relationships, naming consistency, constraints strategy та порядок секцій у ddl.sql також перевірялися та узгоджувалися Novikov Volodymyr як Database Architect / Team Lead.
Реалізацію inventory-related entities (book_copies) та review system (reviews) виконував Zhyryk Vitaliy.
Реалізацію borrowing workflow та reservation workflow (borrowings, reservations) виконував Volodymyr Fedorkiv.
Indexing strategy (FK indexes, partial indexes, active borrowings optimization, pending reservations uniqueness) обговорювалася всією командою та фінально перевірялася Team Lead.
PostgreSQL compatibility validation виконувалася через dbfiddle.uk (PostgreSQL 17) шляхом повного запуску ddl.sql без помилок.

## Коротке обґрунтування командного підходу
1. Як ви розподілили DDL-об'єкти між учасниками:
   Команда розподілила роботу за логічними підсистемами предметної області:
   core architecture та normalization;
   inventory subsystem;
   borrowing/reservation subsystem;
   reviews/testing/documentation.
2. Чому обрали саме такий поділ роботи:
   Такий підхід дозволив незалежно проєктувати окремі частини схеми без конфліктів між таблицями та одночасно зберегти узгоджену архітектуру через централізований review PK/FK relationships та constraints.
   Поділ за підсистемами також спростив перевірку ER-to-DDL consistency.
3. Як перевіряли відповідність DDL вашій ER-діаграмі:
   Команда порівнювала ddl.sql із фінальною DBML-схемою та ER-діаграмою з Topic 03.
   Перевіряли:
   відповідність назв таблиць та колонок;
   правильність PK/FK relationships;
   відповідність cardinality;
   many-to-many relationship через book_authors;
   consistency між borrowings, book_copies та reservations.
   Окремо перевіряли виконання DDL у PostgreSQL 17 через dbfiddle.uk.
