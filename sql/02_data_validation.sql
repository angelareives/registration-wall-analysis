-- Registration Wall Analysis
-- Data Validation
-- Validates row counts, duplicate emails, cross-source overlap,
-- and timing differences between contact creation and signup dates.


-- ============================================================
-- 1. Count cleaned rows
-- ============================================================

SELECT COUNT(*) AS sitewide_rows
FROM activecampaign_clean;

SELECT COUNT(*) AS wisepops_rows
FROM wisepops_signups_clean;


-- ============================================================
-- 2. Check for duplicate emails within ActiveCampaign
-- ============================================================

SELECT
    email,
    COUNT(*) AS number_of_rows
FROM activecampaign_clean
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY number_of_rows DESC;


-- ============================================================
-- 3. Check for duplicate emails within Wisepops
-- ============================================================

SELECT
    email,
    COUNT(*) AS number_of_rows
FROM wisepops_signups_clean
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY number_of_rows DESC;


-- ============================================================
-- 4. Count emails appearing in both datasets
-- ============================================================

SELECT
    COUNT(DISTINCT a.email) AS overlapping_emails
FROM activecampaign_clean AS a
INNER JOIN wisepops_signups_clean AS w
    ON a.email = w.email;


-- ============================================================
-- 5. Inspect overlapping records
-- ============================================================

SELECT
    a.email,
    a.date_created AS ac_date_created,
    a.signup_date AS newspack_signup_date,
    w.signup_date AS wisepops_signup_date,
    a.signup_page AS newspack_page,
    w.signup_page AS wisepops_page
FROM activecampaign_clean AS a
INNER JOIN wisepops_signups_clean AS w
    ON a.email = w.email
ORDER BY w.signup_date
LIMIT 50;


-- ============================================================
-- 6. Compare ActiveCampaign contact creation and signup dates
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN substr(date_created, 1, 10) = signup_date THEN 1
            ELSE 0
        END
    ) AS created_same_day,
    SUM(
        CASE
            WHEN substr(date_created, 1, 10) < signup_date THEN 1
            ELSE 0
        END
    ) AS existed_before_signup,
    SUM(
        CASE
            WHEN substr(date_created, 1, 10) > signup_date THEN 1
            ELSE 0
        END
    ) AS created_after_signup
FROM activecampaign_clean;


-- ============================================================
-- 7. Compare Wisepops contact creation and signup dates
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN substr(date_created, 1, 10) = signup_date THEN 1
            ELSE 0
        END
    ) AS created_same_day,
    SUM(
        CASE
            WHEN substr(date_created, 1, 10) < signup_date THEN 1
            ELSE 0
        END
    ) AS existed_before_signup,
    SUM(
        CASE
            WHEN substr(date_created, 1, 10) > signup_date THEN 1
            ELSE 0
        END
    ) AS created_after_signup
FROM wisepops_signups_clean;
