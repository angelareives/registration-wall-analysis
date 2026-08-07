-- Registration Wall Analysis
-- Data Cleaning
-- Creates standardized tables for ActiveCampaign and Wisepops signup data.


-- ============================================================
-- 1. Clean ActiveCampaign sitewide signup data
-- ============================================================

DROP TABLE IF EXISTS activecampaign_clean;

CREATE TABLE activecampaign_clean AS
SELECT
    LOWER(TRIM("Email")) AS email,
    TRIM("Date Created") AS date_created,
    date("*NP_Registration Date") AS signup_date,
    "*NP_Registration Page" AS signup_page
FROM activecampaign_raw
WHERE "Email" IS NOT NULL
  AND TRIM("Email") <> ''
  AND "*NP_Registration Date" IS NOT NULL
  AND TRIM("*NP_Registration Date") <> '';


-- ============================================================
-- 2. Clean Wisepops registration wall signup data
-- ============================================================

DROP TABLE IF EXISTS wisepops_signups_clean;

CREATE TABLE wisepops_signups_clean AS
SELECT
    LOWER(TRIM("Email")) AS email,
    TRIM("Date Created") AS date_created,
    date("*WP_SignupDate") AS signup_date,
    "*WP_Signup Page" AS signup_page
FROM wisepops_signups_raw
WHERE "Email" IS NOT NULL
  AND TRIM("Email") <> ''
  AND "*WP_SignupDate" IS NOT NULL
  AND TRIM("*WP_SignupDate") <> '';
