SELECT VERSION();
SELECT CURRENT_USER();
SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

-- =========================================================
-- 01_create_database.sql
-- =========================================================

CREATE DATABASE IF NOT EXISTS video_game_sales
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE video_game_sales;

CREATE TABLE raw_vg_sales (
    raw_row_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    img             VARCHAR(500),
    title           VARCHAR(255),
    console         VARCHAR(50),
    genre           VARCHAR(100),
    publisher       VARCHAR(255),
    developer       VARCHAR(255),
    critic_score    VARCHAR(32),
    total_sales     VARCHAR(32),
    na_sales        VARCHAR(32),
    jp_sales        VARCHAR(32),
    pal_sales       VARCHAR(32),
    other_sales     VARCHAR(32),
    release_date    VARCHAR(32),
    last_update     VARCHAR(32)
);

-- =========================================================
-- load_raw_csv
-- =========================================================
LOAD DATA LOCAL INFILE
    'D:/Downloads/vgchartz-2024.csv'
INTO TABLE raw_vg_sales
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
LINES
    TERMINATED BY '\n'
IGNORE 1 LINES
(
    img,
    title,
    console,
    genre,
    publisher,
    developer,
    critic_score,
    total_sales,
    na_sales,
    jp_sales,
    pal_sales,
    other_sales,
    release_date,
    last_update
);

SELECT *
FROM raw_vg_sales;

-- check date format
SELECT DISTINCT release_date
FROM raw_vg_sales
WHERE NULLIF(TRIM(release_date), '') IS NOT NULL
LIMIT 10; -- format: %Y-%m-%d