# TEAMWORK - Topic 09 (SQL DML)

## Склад команди
- Команда: Team 3
- Варіант предметної області: Library Management System

## Таблиця внесків
| Учасник | Роль у команді | Що зроблено | Артефакти / файли |
|---|---|---|---|
| Novikov Volodymyr | Database Architect / Team Lead | Core-catalog INSERT (`categories`, `authors`, `books`, `book_authors`); загальна структура скрипта, порядок секцій, cleanup-блок, sequence sync (`setval`), PostgreSQL-сумісність; UPDATE/DELETE по core-таблицях | `dml.sql` (reference data, core entities, junction, sequence sync) |
| Zhyryk Vitaliy | Inventory System, Reviews, Testing & Documentation | INSERT `book_copies` та `reviews`; узгодження `copy_status` з активними borrowings; UPDATE відгуку та статусу копії (lost); constraint-перевірки (rating, copy_status); тестування і документація | `dml.sql` (`book_copies`, `reviews`, constraint validation) |
| Volodymyr Fedorkiv | Borrowing & Reservation System | INSERT `members`, `borrowings`, `reservations`; book return workflow (UPDATE borrowings + звільнення копії + assignment резервації); DELETE скасованої резервації | `dml.sql` (`members`, `borrowings`, `reservations`) |

## Контекст теми
Роботу над `dml.sql` розподілили за тими самими підсистемами, що й у Topic 03/04:

- **Novikov Volodymyr** наповнив reference data та core entities (`categories`, `authors`, `books`) і M:N зв'язку `book_authors`, а також як Team Lead відповідав за порядок секцій (reference → core → transactional → UPDATE/DELETE → constraint validation), cleanup-блок (FK-safe order), синхронізацію послідовностей через `setval` та перевірку запуску всього скрипта в PostgreSQL.
- **Zhyryk Vitaliy** наповнив `book_copies` і `reviews`, узгодив `copy_status` кожної копії з активними видачами (`returned_at IS NULL` → `borrowed`), підготував UPDATE-сценарії (оновлення відгуку, позначення копії як `lost`) та активний блок constraint validation.
- **Volodymyr Fedorkiv** наповнив `members`, `borrowings`, `reservations` та реалізував транзакційні сценарії: повернення книги (UPDATE `borrowings.returned_at` + звільнення копії + призначення копії наступному в черзі резервації) і видалення скасованої резервації.

Кожна таблиця містить щонайменше 10 записів. Реалістичність та узгодженість наборів даних перевіряли крос-перевіркою FK-зв'язків і станів (`copy_status` ↔ активні borrowings, черга резервацій ↔ borrowed-копії).

### Пояснення пропущених UPDATE/DELETE (Task #04)
- `categories`, `authors` — це довідкові таблиці; `DELETE` у них не демонструється навмисно: `books.category_id` має `FK ... ON DELETE RESTRICT`, тому категорію не можна видалити, поки на неї посилаються книги. Це свідоме архітектурне рішення, а не пропуск.
- `books` — повне видалення книги зачіпає `book_copies`, `borrowings`, `reservations`, `reviews`, тому в межах Topic 09 не виконується (це бізнес-операція рівня застосунку, а не наповнення даними).
- `book_authors` — як чиста M:N таблиця без залежних записів, безпечно підтримує `DELETE` (розрив помилкового зв'язку показано в core-частині).

## Коротке обґрунтування командного підходу
1. **Як розподілили таблиці/сценарії наповнення:** за логічними підсистемами — core catalog (Novikov), inventory + reviews (Zhyryk), members + borrowing/reservation workflow (Fedorkiv). Це повторює поділ із Topic 03/04 і дозволяє кожному відповідати за свій набір даних без конфліктів.
2. **Чому саме такі тестові дані:** взяли впізнавані книги/авторів і анонімні, але реалістичні дані учасників (українські імена, прозорі email). Стани підібрані так, щоб одночасно існували активні видачі, повернення, черги резервацій і відгуки — це покриває основні функціональні сценарії застосунку.
3. **Як перевіряли коректність і реалістичність:** запускали `dml.sql` після `ddl.sql` у PostgreSQL 17 (dbfiddle.uk), перевіряли FK-порядок вставок і cleanup, узгодженість `copy_status` з активними borrowings, дотримання partial unique index для pending-резервацій, а також спрацювання обмежень через активний блок constraint validation.
