# TEAMWORK - Topic 10 (SQL Views)

## Склад команди
- Команда: 3
- Варіант предметної області: Library Management System (PostgreSQL Views Layer)
## Таблиця внесків

| Учасник | Роль у команді | Що зроблено | Артефакти / файли |
|---|---|---|---|
| Novikov Volodymyr | Database Architect / Core Data Layer | Розробка базової логіки views: book_catalog загальна архітектура views та узгодження структури | `views.sql` (horizontal, vertical, mixed, analytics, check option views) |
| Vitaliy Zhyryk | Inventory & Reviews Specialist | Робота з таблицями book_copies та reviews, реалізація available_copies, member_review, member_review_details, high_rated_reviews, recent_reviews, popular_books) | `views.sql` (inventory + review-related views) |
| Volodymyr Fedorkiv | Borrowing & Reservation Logic Engineer | Реалізація borrowings, reservations, library_activity (UNION ALL), reading_history_extended, overdue_borrowings, members_with_book_count | `views.sql` (borrowing, reservation, subquery, UNION views) |

---

## Контекст теми

У проєкті реалізовано 9 основних типів SQL views для підтримки бібліотечної системи:
- **Horizontal views** (book_catalog): відповідальний Novikov Volodymyr
  → надають базовий список книг без складних зв’язків
- **Vertical/Mixed views** (recent_reviews, available_copies): відповідальний Vitaliy Zhyryk
  → фільтрація даних за датою або статусом
- **Join-based views** (member_review, reading_history_extended): відповідальний Volodymyr Fedorkiv
  → об’єднання користувачів, книг і відгуків
- **Subquery-based view** (members_with_book_count): Volodymyr Fedorkiv
  → демонстрація аналітичного підходу через підзапити
- **UNION ALL view** (library_activity): Volodymyr Fedorkiv
  → об’єднання активності видач і резервацій в одну стрічку подій
- **View-from-view** (member_review_details): Novikov Volodymyr
  → побудова складніших представлень на основі існуючих views
- **Updatable view WITH CHECK OPTION** (high_rated_reviews): Novikov Volodymyr
  → контроль бізнес-логіки при оновленні даних
- **Analytics view** (popular_books): Novikov Volodymyr + Vitaliy Zhyryk
  → агрегація рейтингів і популярності книг

---

## Коротке обгрунтування командного підходу

1. **Як розподілили views між учасниками:**
   Розподіл здійснено за логічними зонами системи:
   - Novikov Volodymyr — архітектура та складні view-рівні (JOIN, CHECK OPTION, view-from-view)
   - Vitaliy Zhyryk — інвентаризація та дані книг/відгуків
   - Volodymyr Fedorkiv — бізнес-логіка користувачів (borrowings, reservations, activity)

2. **Чому ці views важливі для предметної області:**
   - забезпечують різні рівні доступу до даних (від простого каталогу до аналітики)
   - спрощують роботу frontend / API
   - централізують бізнес-логіку в базі даних
   - дозволяють швидко отримувати аналітику без складних запитів

3. **Як перевіряли коректність views:**
   - кожен view тестувався через `SELECT ... LIMIT ... ORDER BY`
   - перевірено JOIN-консистентність між таблицями
   - перевірено UNION ALL на відповідність колонок
   - перевірено CHECK OPTION через тестові INSERT/UPDATE (очікувані помилки)
   - виконано повний запуск `views.sql` у PostgreSQL без помилок