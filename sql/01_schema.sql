-- USERS TABLE
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    install_date TIMESTAMP,
    country VARCHAR(10),
    platform VARCHAR(20),
    acquisition_channel VARCHAR(50),
    device_tier VARCHAR(20),
    archetype VARCHAR(20)
);

-- SESSIONS TABLE
CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    day_since_install INT
);

-- PURCHASES TABLE
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    purchase_timestamp TIMESTAMP,
    price_usd NUMERIC(10,2),
    day_since_install INT
);