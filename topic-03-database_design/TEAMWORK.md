# TEAMWORK - Topic 03 (Database Design)

## Склад команди
- Команда: Team 3
- Варіант предметної області: Library Management System

## Таблиця внесків

| Учасник | Роль у команді | Що зроблено | Артефакти / файли |
|---|---|---|---|
| Novikov Volodymyr | Database Architect / Team Lead | Overall database architecture, normalization, PK/FK relationships, schema consistency validation, MVP vs Final Version separation | `library-system.dbml`, ERD foundation | Reviews, Testing & Documentation | Reviews and ratings, testing, documentation, presentation preparation | `reviews`, project documentation |
| Zhyryk Vitaliy | Inventory System | Physical book copies, inventory tracking, availability logic, copy statuses | `book_copies` |
| Volodymyr Fedorkiv | Borrowing & Reservation System | Borrowing workflow, return logic, reservation workflow, reading history | `members`, `borrowings`, `reservations` |


## Контекст теми

Проєкт був розподілений між учасниками команди за функціональними частинами бази даних.

- **Novikov Volodymyr** відповідав за загальну архітектуру бази даних, нормалізацію, ER-модель, PK/FK зв’язки, узгодженість схеми та розділення MVP і Final Version частин проєкту.

- **Zhyryk Vitaliy** відповідав за систему інвентаризації фізичних екземплярів книг (`book_copies`), логіку доступності книг та відстеження статусів екземплярів, а також за систему відгуків і рейтингів (`reviews`), тестування, документацію та підготовку матеріалів для презентації проєкту.

- **Volodymyr Fedorkiv** відповідав за систему видачі та резервування книг (`members`, `borrowings`, `reservations`), включаючи borrowing workflow, return logic та reading history.


## Коротке обґрунтування вибору початкового варіанта
1. Команда обрала Library Management System, тому що ця предметна область має зрозумілі сутності та реальні зв'язки між ними.
2. Варіант покриває ключові навчальні цілі: нормалізацію, ER-діаграми, PK/FK зв’язки, one-to-many та many-to-many зв'язки.
3. Цей варіант добре підходить для командної роботи, тому що його можна чисто розділити на архітектуру, інвентар, borrowing/reservations, reviews/testing/documentation.

