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