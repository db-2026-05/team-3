# TEAMWORK - Topic 12 (Functions & Stored Procedures)

## Склад команди
- Команда: Library Management System Team
- Варіант предметної області: Library Management System (каталог книг, видача, резервування, відгуки)

---

## Таблиця внесків

| Учасник | Роль у команді | Що зроблено | Артефакти / файли |
|---|---|---|---|
| Novikov Volodymyr | Catalog & Data Architect | Функції для книг, авторів, категорій; логіка роботи з каталогом; додавання та оновлення даних книг | `functions_stored_procedures.sql` (catalog management) |
| Vitaliy Zhyryk | Inventory & Reviews Specialist | Функції для book_copies та reviews; підрахунок доступних копій; середній рейтинг; додавання/оновлення відгуків і копій книг | `functions_stored_procedures.sql` (inventory + reviews) |
| Volodymyr Fedorkiv | Circulation & Members Manager | Функції та процедури для members, borrowings, reservations; checkout/return логіка; реєстрація користувачів | `functions_stored_procedures.sql` (members + circulation) |

---

## Контекст теми

У проєкті реалізовано набір SQL функцій і stored procedures у файлі `functions_stored_procedures.sql`, які покривають основні бізнес-процеси бібліотеки:

- **Functions (обчислювальна логіка):**
  - отримання авторів книги
  - підрахунок книг у категорії
  - список книг автора
  - підрахунок доступних копій
  - середній рейтинг книги
  - останній відгук
  - перевірка активних позичок і прострочень

- **SELECT / INSERT procedures:**
  - додавання авторів, книг, копій
  - реєстрація нових членів бібліотеки
  - додавання відгуків
  - оформлення видачі книги (checkout)

- **UPDATE procedures:**
  - оновлення категорії книги
  - зміна даних автора
  - оновлення статусу копій книг
  - редагування відгуків
  - повернення книги (return process)

- **EXCEPTION handling:**
  - перевірка унікальності (email, ISBN)
  - перевірка існування записів
  - контроль доступності копій
  - обробка помилок INSERT/UPDATE

- **Transaction logic:**
  - видача книги (borrowings + book_copies update)
  - повернення книги (оновлення borrowings + доступність копії)

---

## Коротке обґрунтування командного підходу

### 1. Розподіл функцій і процедур
Робота була поділена за доменами бази даних:

- **Novikov Volodymyr** — каталог книг (books, authors, categories)
- **Vitaliy Zhyryk** — інвентар і відгуки (book_copies, reviews)
- **Volodymyr Fedorkiv** — користувачі та операції бібліотеки (members, borrowings, reservations)

Це дозволило паралельну розробку без конфліктів у коді.

---

### 2. Чому ці routines важливі для предметної області

- Functions забезпечують швидку аналітику (рейтинги, кількість копій, перевірка стану користувачів)
- Procedures реалізують бізнес-операції бібліотеки (видача, повернення, реєстрація)
- Exception handling гарантує цілісність даних
- Transaction logic забезпечує атомарність критичних операцій

---

### 3. Як перевіряли коректність

- Для всіх функцій і процедур створено тестові `SELECT` та `CALL`
- Перевіряли:
  - правильність повернення значень
  - вставку та оновлення даних
  - реакцію на помилки (unique_violation, check_violation)
  - транзакційну коректність checkout/return сценаріїв
- Виконання тестувалось у PostgreSQL середовищі

---