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


## Урок 2 — JOIN: связывание таблиц

**Что отрабатывал:** объединение таблиц `clients` и `accounts` по общему полю (`clients.id = accounts.client_id`), разница `INNER JOIN` и `LEFT JOIN`, поведение `NULL`.

### INNER JOIN — только совпадения
```sql
SELECT c.full_name, a.account_number, a.currency, a.balance
FROM clients c
INNER JOIN accounts a ON c.id = a.client_id;
```
Возвращает только клиентов, у которых есть счёт (3 строки). Сидоров не попадает — у него счетов нет.

### LEFT JOIN — все клиенты
```sql
SELECT c.full_name, a.account_number, a.currency, a.balance
FROM clients c
LEFT JOIN accounts a ON c.id = a.client_id;
```
Возвращает всех клиентов. У Сидорова в колонках счёта — `NULL` (значения нет, при этом сам клиент включён в выборку).

### Сравнение результатов

| Тип JOIN | Кого показывает | Строк | Сидоров |
|---|---|---|---|
| `INNER JOIN` | только клиентов со счетами | 3 | не попадает |
| `LEFT JOIN` | всех клиентов | 4 | попадает, счёт = `NULL` |

### Зачем это QA
`LEFT JOIN` позволяет смоделировать «клиента без связанных данных» и заранее проверить поведение интерфейса. Типичный баг: в профиле клиента без счетов приложение должно показать пустой список, но из-за необработанного `NULL` падает с ошибкой `500`. Важно: `NULL` — это отсутствие значения, а не `0`; Это частый источник дефектов.

### Скриншоты
- `INNER JOIN` (3 строки): `./screenshots/sql-lesson2-inner.png`
- `LEFT JOIN` (Сидоров с NULL): `./screenshots/sql-lesson2-left.png`

### Вывод
Умею связывать таблицы по ключу, осознанно выбирать между `INNER` и `LEFT JOIN` в зависимости от задачи, и использую `LEFT JOIN` для негативных сценариев — проверки того, как система обрабатывает отсутствующие (`NULL`) данные.


## Урок 3 — проверка данных глазами QA (INSERT, UPDATE, агрегаты)

**Принцип:** доверяй, но проверяй. Сообщение приложения «Успешно» не гарантирует, что в базе всё корректно — QA проверяет это сам через SQL.

**Что отрабатывал:** подготовку тестовых данных, изменение данных, проверку отчётов, безопасную работу с `UPDATE`/`DELETE`.

### Сценарий 1. Подготовка данных (INSERT)
Создание нужного клиента и счёта напрямую в базе, когда их нет на стенде.
```sql
INSERT INTO clients (id, full_name, phone)
VALUES (4, 'Мария Кузнецова', '+79994445566');

INSERT INTO accounts (account_number, client_id, currency, balance)
VALUES ('ACC-4001', 4, 'RUB', 999999.00);
```
Проверка, что данные создались и связались:
```sql
SELECT c.full_name, a.account_number, a.balance
FROM clients c
JOIN accounts a ON c.id = a.client_id
WHERE c.id = 4;
```

### Сценарий 2. Изменение данных (UPDATE)
```sql
UPDATE accounts SET balance = 0 WHERE account_number = 'ACC-1001';

SELECT * FROM accounts WHERE account_number = 'ACC-1001';
```
**Правило безопасности:** `UPDATE` и `DELETE` всегда пишутся с `WHERE`. Без него изменения применяются ко **всем** строкам таблицы — частая и дорогая ошибка.

### Сценарий 3. Проверка отчёта (агрегаты)
Сверка суммарного баланса по клиенту с тем, что показывает UI.
```sql
SELECT c.full_name, SUM(a.balance) AS total_balance
FROM clients c
JOIN accounts a ON c.id = a.client_id
GROUP BY c.full_name;
```
`GROUP BY` группирует строки по клиенту, `SUM` складывает балансы внутри группы. Расхождение с цифрой на экране = баг в отчёте.

### Уборка тестовых данных
```sql
DELETE FROM accounts WHERE account_number = 'ACC-4001';
DELETE FROM clients WHERE id = 4;
```

### Связка с API
После создания пользователя через `POST` (раздел `api-testing`) следующий шаг QA — запросом `SELECT` убедиться, что пользователь действительно записался в БД. Связка «отправил через API → проверил в базе» — ключевой навык проверки интеграции.

### Скриншоты
- INSERT + проверочный SELECT: `./screenshots/sql-lesson3-insert.png`
- UPDATE + проверка: `./screenshots/sql-lesson3-update.png`
- Отчёт (GROUP BY / SUM): `./screenshots/sql-lesson3-report.png`

### Вывод
Владею CRUD-операциями: готовлю тестовые данные (`INSERT`), изменяю их для проверки поведения приложения (`UPDATE`), проверяю отчёты через агрегаты (`GROUP BY`, `SUM`), осознаю опасность `UPDATE`/`DELETE` без `WHERE` и умею проверять корректность записи данных после действий через API.