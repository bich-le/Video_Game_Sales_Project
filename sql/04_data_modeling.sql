-- =========================================================
-- 04_data_modeling.sql
-- =========================================================
USE video_game_sales;
-- 1. Yearly market trends

CREATE OR REPLACE VIEW vw_yearly_market_trends AS
SELECT
    YEAR(release_date) AS release_year,

    COUNT(*) AS release_count,
    COUNT(DISTINCT title) AS distinct_titles,
    COUNT(DISTINCT console) AS active_consoles,

    SUM(total_sales) AS global_sales,
    SUM(na_sales) AS na_sales,
    SUM(jp_sales) AS jp_sales,
    SUM(pal_sales) AS pal_sales,
    SUM(other_sales) AS other_sales,

    AVG(total_sales) AS sales_per_release

FROM clean_vg_sales
WHERE release_date IS NOT NULL
GROUP BY YEAR(release_date);

-- 2. Genre regional performance

CREATE OR REPLACE VIEW vw_genre_regional_performance AS
SELECT
    genre,

    COUNT(*) AS release_count,

    SUM(total_sales) AS global_sales,
    SUM(na_sales) AS na_sales,
    SUM(jp_sales) AS jp_sales,
    SUM(pal_sales) AS pal_sales,
    SUM(other_sales) AS other_sales,

    100.0 * SUM(na_sales)
        / NULLIF(SUM(SUM(na_sales)) OVER (), 0)
        AS na_market_share_pct,

    100.0 * SUM(jp_sales)
        / NULLIF(SUM(SUM(jp_sales)) OVER (), 0)
        AS jp_market_share_pct,

    100.0 * SUM(pal_sales)
        / NULLIF(SUM(SUM(pal_sales)) OVER (), 0)
        AS pal_market_share_pct

FROM clean_vg_sales
WHERE genre IS NOT NULL
GROUP BY genre;

-- 3. Console yearly performance

CREATE OR REPLACE VIEW vw_console_yearly_performance AS
SELECT
    console,
    YEAR(release_date) AS release_year,

    COUNT(*) AS release_count,
    COUNT(DISTINCT title) AS distinct_titles,

    SUM(total_sales) AS annual_sales,
    AVG(total_sales) AS sales_per_release

FROM clean_vg_sales
WHERE release_date IS NOT NULL
  AND console IS NOT NULL
GROUP BY
    console,
    YEAR(release_date);
    
-- 4. Console overall performance

CREATE OR REPLACE VIEW vw_console_performance AS
SELECT
    console,

    COUNT(*) AS release_count,
    COUNT(DISTINCT title) AS distinct_titles,

    SUM(total_sales) AS total_sales,
    AVG(total_sales) AS sales_per_release,

    MIN(YEAR(release_date)) AS first_release_year,
    MAX(YEAR(release_date)) AS last_release_year,

    MAX(YEAR(release_date))
        - MIN(YEAR(release_date))
        + 1 AS observed_lifetime_years

FROM clean_vg_sales
WHERE console IS NOT NULL
GROUP BY console;

-- 5. Publisher performance

CREATE OR REPLACE VIEW vw_publisher_performance AS
SELECT
    publisher,

    COUNT(*) AS release_count,
    COUNT(DISTINCT title) AS distinct_titles,
    COUNT(DISTINCT genre) AS genre_count,
    COUNT(DISTINCT console) AS console_count,

    SUM(total_sales) AS total_sales,
    AVG(total_sales) AS sales_per_release,

    SUM(na_sales) AS na_sales,
    SUM(jp_sales) AS jp_sales,
    SUM(pal_sales) AS pal_sales,
    SUM(other_sales) AS other_sales

FROM clean_vg_sales
WHERE publisher IS NOT NULL
GROUP BY publisher;

-- 6. Publisher product clusters

CREATE OR REPLACE VIEW vw_publisher_product_cluster AS
SELECT
    publisher,
    genre,
    console,

    COUNT(*) AS release_count,
    COUNT(DISTINCT title) AS distinct_titles,

    SUM(total_sales) AS total_sales,
    AVG(total_sales) AS sales_per_release,

    SUM(na_sales) AS na_sales,
    SUM(jp_sales) AS jp_sales,
    SUM(pal_sales) AS pal_sales,
    SUM(other_sales) AS other_sales

FROM clean_vg_sales
WHERE publisher IS NOT NULL
  AND genre IS NOT NULL
  AND console IS NOT NULL
GROUP BY
    publisher,
    genre,
    console;
    
-- Validation
SELECT *
FROM vw_yearly_market_trends
ORDER BY release_year;

SELECT *
FROM vw_genre_regional_performance
ORDER BY global_sales DESC;

SELECT *
FROM vw_console_performance
ORDER BY total_sales DESC;

SELECT *
FROM vw_publisher_performance
ORDER BY total_sales DESC
LIMIT 20;

SELECT
    (SELECT SUM(total_sales)
     FROM clean_vg_sales
     WHERE release_date IS NOT NULL)
        AS clean_total_sales,

    (SELECT SUM(global_sales)
     FROM vw_yearly_market_trends)
        AS view_total_sales;