-- =========================================================
-- 03_eda.sql
-- =========================================================
-- 1. Data overview and coverage
USE video_game_sales;

SELECT * 
FROM clean_vg_sales;

SELECT
	COUNT(*) AS total_releases,
    COUNT(DISTINCT title) AS distinct_titles,
    COUNT(DISTINCT console) AS distinct_consoles,
    COUNT(DISTINCT genre) AS distinct_genres,
    COUNT(DISTINCT publisher) AS distinct_publishers,
    COUNT(DISTINCT developer) AS distinct_developers,
    MIN(release_date) AS earliest_release_date,
    MAX(release_date) AS latest_release_date
FROM clean_vg_sales;

-- Coverage
SELECT 
	COUNT(*) AS total_releases,
    
    SUM(total_sales IS NOT NULL) AS releases_with_total_sales,
    SUM(na_sales IS NOT NULL) AS releases_with_na_sales,
    SUM(jp_sales IS NOT NULL) AS releases_with_jp_sales,
    SUM(pal_sales IS NOT NULL) AS releases_with_pal_sales,
    SUM(other_sales IS NOT NULL) AS releases_with_other_sales,
    SUM(release_date IS NOT NULL) AS releases_with_release_date,
    
    ROUND(100.0 * SUM(total_sales IS NOT NULL) / COUNT(*), 2) AS total_sales_coverage,
	ROUND(100.0 * SUM(release_date IS NOT NULL) / COUNT(*), 2) AS release_date_coverage
FROM clean_vg_sales;

-- Release dist by year
SELECT
	YEAR(release_date) AS release_year,
    COUNT(*) AS release_count
FROM clean_vg_sales
WHERE release_date IS NOT NULL
GROUP BY YEAR(release_date)
ORDER BY release_year;

-- 63,888 releases (39,594 unique titles) from 1971–2024.
-- Sales data covers only 29.55% of releases; interpret sales results with caution.
-- Releases peaked in 2009 and declined after 2011.
-- Data from 2021–2024 is likely incomplete.

-- 2. Overall Market Trends
-- =========================================================
SELECT
    ROUND(SUM(total_sales), 2) AS global_sales,
    ROUND(SUM(na_sales), 2) AS na_sales,
    ROUND(SUM(jp_sales), 2) AS jp_sales,
    ROUND(SUM(pal_sales), 2) AS pal_sales,
    ROUND(SUM(other_sales), 2) AS other_sales
FROM clean_vg_sales;

SELECT
	YEAR(release_date) AS release_year,
    ROUND(SUM(total_sales),2) AS global_sales,
    COUNT(*) AS release_count,
    ROUND(SUM(total_sales)/COUNT(total_sales),2) AS sales_per_release
FROM clean_vg_sales
WHERE release_date IS NOT NULL
GROUP BY YEAR(release_date)
ORDER BY release_year;

-- top games
SELECT
    title,
    console,
    genre,
    publisher,
    release_date,
    total_sales
FROM clean_vg_sales
WHERE total_sales IS NOT NULL
ORDER BY total_sales DESC
LIMIT 20;

-- Overall Market
-- Total reported global sales reached 6,598.01 million units.
-- North America dominated the market (50.7%), followed by PAL (29.0%),
-- Japan (10.3%), and Other regions (9.9%).

-- Market Trend
-- Global sales grew rapidly from the mid-1990s and peaked in 2008
-- (537.84 million units), remaining above 440 million annually from 2008–2011.
-- Sales declined steadily after 2011.

-- Sales Efficiency
-- Although 2009 recorded the most releases, it generated lower total sales than 2008, 
-- indicating that more releases did not necessarily produce higher market sales.
-- Sales per release also weakened after 2015, suggesting lower average
-- commercial performance.

-- Data Limitation
-- Sales data from 2019 onward is clearly incomplete and should not be used
-- to infer recent market trends.

-- Top-Selling Releases
-- The highest-selling records are dominated by Grand Theft Auto and
-- Call of Duty, with Rockstar Games and Activision leading.
-- Rankings are release-platform specific, so the same title may appear
-- multiple times across different consoles.

-- 3. Regional Genre Preferences
-- =========================================================
SELECT
    genre,
    ROUND(SUM(na_sales), 2) AS na_sales,
    ROUND(SUM(jp_sales), 2) AS jp_sales,
    ROUND(SUM(pal_sales), 2) AS pal_sales,
    ROUND(SUM(other_sales), 2) AS other_sales,
    ROUND(SUM(total_sales), 2) AS global_sales
FROM clean_vg_sales
GROUP BY genre
ORDER BY global_sales DESC;

SELECT
    genre,
    ROUND(100.0 * SUM(na_sales) / SUM(SUM(na_sales)) OVER (),2) 
		AS na_market_share_pct,
    ROUND(100.0 * SUM(jp_sales) / SUM(SUM(jp_sales)) OVER (),2)
		AS jp_market_share_pct,
    ROUND(100.0 * SUM(pal_sales) / SUM(SUM(pal_sales)) OVER (),2)
		AS pal_market_share_pct
FROM clean_vg_sales
GROUP BY genre
ORDER BY genre;

-- Genre Ranking
WITH genre_sales AS (
	SELECT genre,
		SUM(na_sales) AS na_sales,
        SUM(jp_sales) AS jp_sales,
        SUM(pal_sales) AS pal_sales
	FROM clean_vg_sales
    GROUP BY genre
)

SELECT
	genre,
    ROUND(na_sales,2) AS na_sales,
    DENSE_RANK() OVER (ORDER BY na_sales DESC) AS na_rank,
    ROUND(jp_sales,2) AS jp_sales,
    DENSE_RANK() OVER (ORDER BY jp_sales DESC) AS jp_rank,
    ROUND(pal_sales,2) AS pal_sales,
    DENSE_RANK() OVER (ORDER BY pal_sales DESC) AS pal_rank
FROM genre_sales
ORDER BY na_rank;

-- genre dependency
SELECT 
	genre,
    ROUND(SUM(total_sales),2) AS global_sales,
    ROUND(100.0 * SUM(na_sales) / NULLIF(SUM(total_sales),0),2) AS na_dependency_pct,
    ROUND(100.0 * SUM(jp_sales) / NULLIF(SUM(total_sales),0),2) AS jp_dependency_pct,
    ROUND(100.0 * SUM(pal_sales) / NULLIF(SUM(total_sales),0),2) AS pal_dependency_pct
FROM clean_vg_sales
WHERE total_sales IS NOT NULL
GROUP BY genre
ORDER BY global_sales DESC;
    
-- Sports, Action, and Shooter lead Western markets (NA & PAL).
-- Role-Playing dominates Japan, highlighting distinct regional preferences.

-- Shooter is Western-focused, while RPG and Visual Novel are Japan-focused.
-- Racing performs relatively stronger in PAL.

-- Action and Sports have broad global appeal, whereas RPG and Visual Novel
-- require a more localized strategy for the Japanese market.

-- 4. Console Performance and Lifecycle
-- =========================================================
    
-- Overall console performance
SELECT
    console,
    COUNT(*) AS release_count,
    COUNT(DISTINCT title) AS distinct_titles,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(AVG(total_sales), 2) AS avg_sales_per_release,
    MIN(YEAR(release_date)) AS first_release_year,
    MAX(YEAR(release_date)) AS last_release_year
FROM clean_vg_sales
GROUP BY console
ORDER BY total_sales DESC;

-- Annual Lifecycle
SELECT 
	console,
    YEAR(release_date) AS release_year,
    ROUND(SUM(total_sales),2) AS annual_sales,
    COUNT(*) AS release_count
FROM clean_vg_sales
WHERE release_date IS NOT NULL
GROUP BY console, YEAR(release_date)
ORDER BY console, release_year;

-- Peak Year
WITH console_year_sales AS (
    SELECT
        console,
        YEAR(release_date) AS release_year,
        SUM(total_sales) AS annual_sales
    FROM clean_vg_sales
    WHERE release_date IS NOT NULL
    GROUP BY
        console,
        YEAR(release_date)
),

ranked_years AS (
    SELECT
        console,
        release_year,
        annual_sales,
        ROW_NUMBER() OVER (
            PARTITION BY console
            ORDER BY annual_sales DESC, release_year
        ) AS sales_rank
    FROM console_year_sales
)

SELECT
    console,
    release_year AS peak_sales_year,
    ROUND(annual_sales, 2) AS peak_annual_sales
FROM ranked_years
WHERE sales_rank = 1
ORDER BY peak_annual_sales DESC;

-- Years to Peak
WITH console_year_sales AS (
    SELECT
        console,
        YEAR(release_date) AS release_year,
        SUM(total_sales) AS annual_sales
    FROM clean_vg_sales
    WHERE release_date IS NOT NULL
    GROUP BY
        console,
        YEAR(release_date)
),

console_metrics AS (
    SELECT
        console,
        release_year,
        annual_sales,
        MIN(release_year) OVER (
            PARTITION BY console
        ) AS first_release_year,

        ROW_NUMBER() OVER (
            PARTITION BY console
            ORDER BY annual_sales DESC, release_year
        ) AS sales_rank
    FROM console_year_sales
)

SELECT
    console,
    first_release_year,
    release_year AS peak_sales_year,
    release_year - first_release_year AS years_to_peak,
    ROUND(annual_sales, 2) AS peak_annual_sales
FROM console_metrics
WHERE sales_rank = 1
ORDER BY peak_annual_sales DESC;

-- Sales Efficiency
SELECT
    console,
    MIN(YEAR(release_date)) AS first_release_year,
    MAX(YEAR(release_date)) AS last_release_year,

    MAX(YEAR(release_date))
    - MIN(YEAR(release_date))
    + 1 AS observed_lifetime_years

FROM clean_vg_sales
WHERE release_date IS NOT NULL
GROUP BY console
ORDER BY observed_lifetime_years DESC;

-- PS2 is the best-selling console, followed by Xbox 360 and PS3.
-- Xbox 360 and PS3 generated higher sales per release than PS2.
-- PS4 outperformed Xbox One among modern consoles.
-- Early console generations contributed most historical sales.
-- Lifecycle metrics should be interpreted cautiously due to inconsistent
-- release-year data and incomplete sales coverage.

-- 5. Publisher Performance
-- =========================================================
-- Clean data (Mapping publisher name)
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

SELECT
    publisher,
    COUNT(*) AS release_count,
    ROUND(SUM(total_sales), 2) AS total_sales
FROM clean_vg_sales
GROUP BY publisher
ORDER BY total_sales DESC
LIMIT 20;

SELECT ROUND(SUM(total_sales), 2) AS total_sales
FROM clean_vg_sales;

-- Publisher Scale
SELECT
    publisher,
    COUNT(total_sales) AS release_count,
    COUNT(DISTINCT title) AS distinct_titles,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(AVG(total_sales), 2) AS sales_per_release
FROM clean_vg_sales
WHERE publisher IS NOT NULL
GROUP BY publisher
ORDER BY total_sales DESC
LIMIT 20;

-- Genre Contribution
WITH publisher_genre_sales AS (
	SELECT 
		publisher,
		genre,
		SUM(total_sales) AS genre_sales
	FROM clean_vg_sales
	GROUP BY publisher, genre
),
ranked_genres AS (
	SELECT
		publisher,
		genre,
		genre_sales,
		SUM(genre_sales) OVER (PARTITION BY publisher) AS publisher_total_sales,
		ROW_NUMBER() OVER (PARTITION BY publisher ORDER BY genre_sales DESC) AS genre_rank
	FROM publisher_genre_sales
)
SELECT 
	publisher,
    genre AS top_genre,
    ROUND(genre_sales, 2) AS genre_sales,
    ROUND (100.0 * genre_sales / NULLIF(publisher_total_sales, 0), 2) AS contribution_pct
FROM ranked_genres
WHERE genre_rank = 1
ORDER BY genre_sales DESC;

-- Publisher Contribution
WITH publisher_console_sales AS (
    SELECT
        publisher,
        console,
        SUM(total_sales) AS console_sales
    FROM clean_vg_sales
    WHERE publisher IS NOT NULL
    GROUP BY publisher, console
),

ranked_consoles AS (
    SELECT
        publisher,
        console,
        console_sales,
		SUM(console_sales) OVER (PARTITION BY publisher) AS publisher_total_sales,
        ROW_NUMBER() OVER (PARTITION BY publisher ORDER BY console_sales DESC) AS console_rank
	FROM publisher_console_sales
)
SELECT
    publisher,
    console AS top_console,
    ROUND(console_sales, 2) AS console_sales,
	ROUND(100.0 * console_sales / NULLIF(publisher_total_sales, 0),2) AS contribution_pct
FROM ranked_consoles
WHERE console_rank = 1
ORDER BY console_sales DESC;

-- Genre & Console
WITH product_clusters AS (
	SELECT 
		 publisher,
		 genre,
		 console,
		 COUNT(*) AS release_count,
		 SUM(total_sales) AS cluster_sales
	FROM clean_vg_sales
	WHERE publisher IS NOT NULL
	GROUP BY publisher, genre, console
),

ranked_clusters AS (
	SELECT
		publisher,
		genre,
		console,
		release_count,
		cluster_sales,
		SUM(cluster_sales) OVER (PARTITION BY publisher) AS publisher_total_sales,
		ROW_NUMBER() OVER (PARTITION BY publisher ORDER BY cluster_sales DESC) AS cluster_rank
	FROM product_clusters
)

SELECT 
	publisher,
    genre,
    console,
    release_count,
    ROUND (cluster_sales,2) AS cluster_sales,
    ROUND (100.0 * cluster_sales / NULLIF(publisher_total_sales,0),2) AS publisher_contri_pct
FROM ranked_clusters
WHERE cluster_rank = 1
ORDER BY cluster_sales DESC;

-- Publisher Regional Concentration
SELECT
    publisher,
    ROUND(SUM(na_sales), 2) AS na_sales,
    ROUND(SUM(jp_sales), 2) AS jp_sales,
    ROUND(SUM(pal_sales), 2) AS pal_sales,
    ROUND(SUM(other_sales), 2) AS other_sales,
    ROUND(SUM(total_sales), 2) AS total_sales
FROM clean_vg_sales
WHERE publisher IS NOT NULL
GROUP BY publisher
ORDER BY total_sales DESC
LIMIT 20;

-- Publisher-name standardization makes Electronic Arts the market leader
-- and improves the accuracy of publisher rankings.

-- Electronic Arts combines scale and efficiency, while Rockstar Games leads in sales per release.
-- EA (Sports), Activision (Shooter), and Rockstar (Action) show distinct genre specialization.

-- Western publishers rely mainly on NA & PAL, whereas Japanese publishers
-- have stronger exposure to the Japanese market.
