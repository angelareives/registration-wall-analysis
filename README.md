# Registration Wall Analysis

SQL analysis of a 30-day soft registration wall test measuring its impact on newsletter acquisition compared with the previous 30 days.

## Analysis

The SQL workflow includes:
- Data cleaning and standardization
- Data quality and overlap validation
- Baseline vs. test period analysis
- Daily and total signup calculations
- Percentage lift calculation
- Registration wall conversion rate calculation

## Repository Structure

- `01_data_cleaning.sql` — cleans and standardizes signup data
- `02_data_validation.sql` — checks duplicates, cross-source overlap, and date discrepancies
- `03_analysis.sql` — calculates signup performance, lift, and conversion rate

## Tools

SQL · SQLite · Looker Studio · Google Sheets

## Data Privacy

Raw source data is not included because it contains subscriber information.

## Full Case Study

[View the full case study](https://example.com/registration-wall-analysis/)
