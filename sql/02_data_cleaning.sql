-- =========================================================
-- 02_data_cleaning.sql
-- =========================================================
CREATE TABLE clean_vg_sales (
    game_release_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    title           VARCHAR(255),
    console         VARCHAR(50),
    genre           VARCHAR(100),
    publisher       VARCHAR(255),
    developer       VARCHAR(255),

    total_sales     DECIMAL(10,2),
    na_sales        DECIMAL(10,2),
    jp_sales        DECIMAL(10,2),
    pal_sales       DECIMAL(10,2),
    other_sales     DECIMAL(10,2),

    release_date    DATE
);

INSERT INTO clean_vg_sales (
    title,
    console,
    genre,
    publisher,
    developer,
    total_sales,
    na_sales,
    jp_sales,
    pal_sales,
    other_sales,
    release_date
)
SELECT
    title,
    console,
    genre,
    publisher,
    developer,
    total_sales,
    na_sales,
    jp_sales,
    pal_sales,
    other_sales,
    release_date
FROM (
    SELECT
        NULLIF(TRIM(title), '') AS title,
        NULLIF(TRIM(console), '') AS console,
        NULLIF(TRIM(genre), '') AS genre,
        NULLIF(TRIM(publisher), '') AS publisher,
        NULLIF(TRIM(developer), '') AS developer,

        CASE
            WHEN TRIM(total_sales)
                 REGEXP '^[0-9]+([.][0-9]+)?$'
            THEN CAST(TRIM(total_sales) AS DECIMAL(10,2))
            ELSE NULL
        END AS total_sales,

        CASE
            WHEN TRIM(na_sales)
                 REGEXP '^[0-9]+([.][0-9]+)?$'
            THEN CAST(TRIM(na_sales) AS DECIMAL(10,2))
            ELSE NULL
        END AS na_sales,

        CASE
            WHEN TRIM(jp_sales)
                 REGEXP '^[0-9]+([.][0-9]+)?$'
            THEN CAST(TRIM(jp_sales) AS DECIMAL(10,2))
            ELSE NULL
        END AS jp_sales,

        CASE
            WHEN TRIM(pal_sales)
                 REGEXP '^[0-9]+([.][0-9]+)?$'
            THEN CAST(TRIM(pal_sales) AS DECIMAL(10,2))
            ELSE NULL
        END AS pal_sales,

        CASE
            WHEN TRIM(other_sales)
                 REGEXP '^[0-9]+([.][0-9]+)?$'
            THEN CAST(TRIM(other_sales) AS DECIMAL(10,2))
            ELSE NULL
        END AS other_sales,

        CASE
            WHEN TRIM(release_date)
                 REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(TRIM(release_date), '%Y-%m-%d')
            ELSE NULL
        END AS release_date,

        ROW_NUMBER() OVER (
            PARTITION BY
                LOWER(TRIM(title)),
                LOWER(TRIM(console)),
                NULLIF(TRIM(release_date), ''),
                LOWER(COALESCE(NULLIF(TRIM(publisher), ''), ''))
            ORDER BY raw_row_id
        ) AS row_num

    FROM raw_vg_sales
    WHERE NULLIF(TRIM(title), '') IS NOT NULL
      AND NULLIF(TRIM(console), '') IS NOT NULL
      AND NULLIF(TRIM(genre), '') IS NOT NULL
) AS cleaned
WHERE row_num = 1;

-- Trim whitespace.
-- Convert empty strings to NULL.
-- Cast sales to DECIMAL.
-- Convert release dates to DATE.
-- Remove incomplete rows.
-- Remove duplicates.
-- Preserve missing sales as NULL.

SELECT
    (SELECT COUNT(*) FROM raw_vg_sales) AS raw_rows,
    (SELECT COUNT(*) FROM clean_vg_sales) AS clean_rows;
SELECT
    COUNT(*) AS total_rows,

    SUM(title IS NULL) AS null_title,
    SUM(console IS NULL) AS null_console,
    SUM(genre IS NULL) AS null_genre,
    SUM(publisher IS NULL) AS null_publisher,
    SUM(developer IS NULL) AS null_developer,

    SUM(total_sales IS NULL) AS null_total_sales,
    SUM(na_sales IS NULL) AS null_na_sales,
    SUM(jp_sales IS NULL) AS null_jp_sales,
    SUM(pal_sales IS NULL) AS null_pal_sales,
    SUM(other_sales IS NULL) AS null_other_sales,

    SUM(release_date IS NULL) AS null_release_date

FROM clean_vg_sales;

-- Standardize publisher names
UPDATE clean_vg_sales
SET publisher = CASE
    WHEN publisher IN (
        'EA Sports',
        'EA Sports BIG'
    ) THEN 'Electronic Arts'

    WHEN publisher IN (
        'Warner Bros. Interactive',
        'Warner Bros. Interactive Entertainment'
    ) THEN 'Warner Bros. Interactive Entertainment'

    WHEN publisher IN (
        'Sony Computer Entertainment',
        'Sony Computer Entertainment America',
        'Sony Interactive Entertainment'
    ) THEN 'Sony Interactive Entertainment'

    WHEN publisher IN (
        'Konami',
        'Konami Digital Entertainment'
    ) THEN 'Konami'

    WHEN publisher IN (
        'Namco',
        'Namco Bandai',
        'Namco Bandai Games'
    ) THEN 'Bandai Namco Entertainment'

    WHEN publisher IN (
        'Microsoft',
        'Microsoft Studios',
        'Microsoft Game Studios'
    ) THEN 'Microsoft'

    WHEN publisher IN (
        'Square',
        'Square Enix'
    ) THEN 'Square Enix'

    ELSE publisher
END;
