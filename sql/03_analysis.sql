-- Registration Wall Analysis
-- Core Analysis
-- Builds the baseline/test comparison and calculates
-- signup growth, daily averages, lift, and wall conversion rate.


-- ============================================================
-- 1. Create analysis-period tables
-- Baseline: May 17–June 15, 2026
-- Test: June 16–July 15, 2026
-- ============================================================

DROP TABLE IF EXISTS activecampaign_analysis;

CREATE TABLE activecampaign_analysis AS
SELECT *
FROM activecampaign_clean
WHERE signup_date BETWEEN '2026-05-17' AND '2026-07-15';


DROP TABLE IF EXISTS wisepops_analysis;

CREATE TABLE wisepops_analysis AS
SELECT *
FROM wisepops_signups_clean
WHERE signup_date BETWEEN '2026-06-16' AND '2026-07-15';


-- ============================================================
-- 2. Build a combined event-level signup table
-- ============================================================

DROP TABLE IF EXISTS combined_signups;

CREATE TABLE combined_signups AS
SELECT
    email,
    date_created,
    signup_date,
    signup_page,
    'sitewide' AS signup_source
FROM activecampaign_analysis

UNION ALL

SELECT
    email,
    date_created,
    signup_date,
    signup_page,
    'registration_wall' AS signup_source
FROM wisepops_analysis;


-- ============================================================
-- 3. Label baseline and test periods
-- ============================================================

DROP TABLE IF EXISTS signups_with_period;

CREATE TABLE signups_with_period AS
SELECT
    email,
    date_created,
    signup_date,
    signup_page,
    signup_source,
    CASE
        WHEN signup_date BETWEEN '2026-05-17' AND '2026-06-15'
            THEN 'Baseline'
        WHEN signup_date BETWEEN '2026-06-16' AND '2026-07-15'
            THEN 'Test'
        ELSE 'Outside Period'
    END AS test_period
FROM combined_signups;


-- ============================================================
-- 4. Count signups by day
-- Used for the daily signup trend
-- ============================================================

SELECT
    signup_date,
    test_period,
    signup_source,
    COUNT(*) AS signups
FROM signups_with_period
WHERE test_period IN ('Baseline', 'Test')
GROUP BY
    signup_date,
    test_period,
    signup_source
ORDER BY signup_date;


-- ============================================================
-- 5. Calculate total signups and average signups per day
-- Both periods contain 30 calendar days
-- ============================================================

SELECT
    test_period,
    COUNT(*) AS total_signups,
    COUNT(DISTINCT signup_date) AS days_with_signups,
    COUNT(*) / 30.0 AS average_signups_per_day
FROM signups_with_period
WHERE test_period IN ('Baseline', 'Test')
GROUP BY test_period;


-- ============================================================
-- 6. Calculate lift in average daily signups
-- ============================================================

WITH period_totals AS (
    SELECT
        test_period,
        COUNT(*) / 30.0 AS average_signups_per_day
    FROM signups_with_period
    WHERE test_period IN ('Baseline', 'Test')
    GROUP BY test_period
)

SELECT
    MAX(
        CASE
            WHEN test_period = 'Baseline'
            THEN average_signups_per_day
        END
    ) AS baseline_average,

    MAX(
        CASE
            WHEN test_period = 'Test'
            THEN average_signups_per_day
        END
    ) AS test_average,

    (
        MAX(
            CASE
                WHEN test_period = 'Test'
                THEN average_signups_per_day
            END
        )
        -
        MAX(
            CASE
                WHEN test_period = 'Baseline'
                THEN average_signups_per_day
            END
        )
    )
    /
    NULLIF(
        MAX(
            CASE
                WHEN test_period = 'Baseline'
                THEN average_signups_per_day
            END
        ),
        0
    )
    * 100.0 AS lift_percent
FROM period_totals;


-- ============================================================
-- 7. Prepare Wisepops impression data
-- Comma-formatted values are converted to integers
-- ============================================================

DROP TABLE IF EXISTS wisepops_impressions_clean;

CREATE TABLE wisepops_impressions_clean AS
SELECT
    "Page URL" AS page_url,
    CAST(REPLACE("Displays", ',', '') AS INTEGER) AS displays,
    CAST(REPLACE("Clicks", ',', '') AS INTEGER) AS clicks,
    CAST(REPLACE("Conversions", ',', '') AS INTEGER) AS conversions,
    CAST(REPLACE("Collected Emails", ',', '') AS INTEGER) AS collected_emails
FROM wisepops_impressions_raw;


-- ============================================================
-- 8. Calculate overall registration wall conversion rate
-- ============================================================

SELECT
    SUM(displays) AS total_displays,
    SUM(collected_emails) AS total_collected_emails,
    SUM(collected_emails) * 100.0
        / NULLIF(SUM(displays), 0) AS conversion_rate_percent
FROM wisepops_impressions_clean;
