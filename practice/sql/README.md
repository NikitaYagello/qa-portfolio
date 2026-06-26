# SQL — практика (DBeaver)

Отработка SQL для тестирования: чтение и проверка данных в базе, фильтрация, сортировка, связывание таблиц. Тестировщику SQL нужен, чтобы проверять, что приложение корректно записало или изменило данные в базе.

**Инструменты:** DBeaver · SQLite

**Файлы раздела:**
- `schema.sql` — создание таблиц и тестовых данных
- `screenshots/` — подтверждающие скриншоты


## Тестовые данные

Учебная схема — клиенты и их банковские счета (один клиент может иметь несколько счетов; у части клиентов счёта нет).

```sql
CREATE TABLE clients (
    id          INTEGER PRIMARY KEY,
    full_name   TEXT,
    phone       TEXT
);

CREATE TABLE accounts (
    account_number TEXT PRIMARY KEY,
    client_id      INTEGER,
    currency       TEXT,
    balance        REAL
);

INSERT INTO clients (id, full_name, phone) VALUES
(1, 'Иван Иванов',   '+79991112233'),
(2, 'Анна Петрова',  '+79992223344'),
(3, 'Сергей Сидоров','+79993334455');

INSERT INTO accounts (account_number, client_id, currency, balance) VALUES
('ACC-1001', 1, 'RUB', 50000.00),
('ACC-1002', 1, 'USD', 150.00),
('ACC-2001', 2, 'RUB', 120000.00);
```

> У клиента Сидоров (id 3) счёта нет — это используется в негативных сценариях с JOIN.


## Урок 1 — SELECT, фильтрация, сортировка

**Что отрабатывал:** чтение данных из таблиц, отбор по условию, сортировка, подсчёт строк.

### Запросы

**Выбор данных**
```sql
SELECT * FROM clients;                 -- все колонки
SELECT full_name, phone FROM clients;  -- только нужные колонки
```

**Фильтрация — WHERE**
```sql
SELECT * FROM accounts WHERE currency = 'RUB';
SELECT * FROM accounts WHERE balance > 100000;
```

**Сортировка — ORDER BY**
```sql
SELECT * FROM accounts ORDER BY balance DESC;  -- по убыванию
SELECT * FROM accounts ORDER BY balance ASC;   -- по возрастанию
```

**Подсчёт — COUNT**
```sql
SELECT COUNT(*) FROM clients;  -- сколько всего клиентов
```

**Комбинированный запрос** (фильтр + сортировка)
```sql
SELECT * FROM accounts
WHERE currency = 'RUB' AND balance > 40000
ORDER BY balance ASC;
```

### Скриншоты
- Запрос с `WHERE`: `./screenshots/sql-lesson1-where.png`
- Запрос с `ORDER BY`: `./screenshots/sql-lesson1-orderby.png`
- Комбинированый запрос `AND`: `./screenshots/sql-lesson1-combi.png`

### Вывод
Умею читать данные из таблиц, отбирать строки по условию (`WHERE`, текст в кавычках, числа без), сортировать (`ORDER BY` с `ASC`/`DESC`), считать строки (`COUNT`) и комбинировать условия через `AND`. Это база для проверки того, что приложение записало в БД ожидаемые данные.


