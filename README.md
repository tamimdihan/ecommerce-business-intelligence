# E-commerce Business Intelligence

An end-to-end business intelligence project using the UCI Online Retail dataset to investigate sales performance, product demand, customer behavior, and commercial risks.

The project follows a practical analytics workflow: **data audit → cleaning → SQL analysis → Python and statistics → Power BI dashboard → executive reporting**.

## Project at a Glance

- **Dataset:** UCI Online Retail
- **Period covered:** 1 December 2010 – 9 December 2011
- **Raw records:** 541,909
- **Cleaned records:** 536,641
- **Exact duplicate rows removed:** 5,268
- **Tools:** Python, Pandas, Jupyter Notebook, MySQL, Power BI
- **Deliverables:** cleaned dataset, customer RFM data, SQL analysis, notebooks, interactive dashboard, and executive report

## Business Objective

Turn transactional retail data into actionable evidence that can help a business understand:

- How sales change over time.
- Which countries and products contribute most to sales.
- How much revenue depends on repeat customers and high-value customers.
- How concentrated revenue is among a small group of customers.
- What cancellations and inactive or at-risk customer segments may signal.
- Where management could investigate opportunities to improve retention and reduce commercial risk.

## Key Findings

The following findings are based on the project's cleaned dataset and analyses.

| Metric | Result |
|---|---:|
| Sales revenue | £10.64M |
| Sales line items | 526,052 |
| Units sold | 5,645,017 |
| Sales orders | 20,726 |
| Identifiable customers with sales | 4,339 |
| Average order value (AOV) | £513.47 |
| UK share of sales revenue | Approximately 84.6% |
| Cancellation value | £893,979.73 |
| Cancellation value as a share of sales revenue | Approximately 8.4% |

### What stands out

1. **Revenue is highly concentrated geographically.** The United Kingdom contributes approximately 84.6% of sales revenue, creating a meaningful market-concentration risk and a question about international growth opportunities.
2. **Repeat customers are commercially important.** In the customer-behavior analysis, repeat customers account for approximately 93.1% of customer-attributed revenue.
3. **Revenue is concentrated among a relatively small group of customers.** The top 10% of identifiable customers account for approximately 61.4% of identifiable-customer revenue.
4. **Some high-value customers may need re-engagement.** RFM analysis identified 337 customers in the “High-Value At-Risk” segment.
5. **Cancellations deserve investigation.** Cancellation value is approximately £894K. This is a transaction-based measure, not a confirmed customer-return rate; operational and financial records may also affect it.
6. **The reporting period needs context.** December 2011 contains data only through 9 December, so it should not be compared with complete months without qualification.

These findings identify areas for business investigation; they do not by themselves establish the causes behind customer behavior or sales changes.

## Methodology

### 1. Data audit

Reviewed the original data for missing values, duplicate rows, unusual quantities and prices, transaction patterns, and date coverage.

### 2. Cleaning and transaction classification

- Removed 5,268 exact duplicate rows.
- Preserved missing customer IDs and descriptions rather than inventing values.
- Classified records as `SALE`, `CANCELLATION`, `INVENTORY_ADJUSTMENT`, or `BAD_DEBT_ADJUSTMENT`.
- Retained unusual quantities for investigation instead of deleting them solely because they were extreme.
- Created transaction-value and sales-only revenue fields so non-sale adjustments are not treated as normal sales revenue.

### 3. SQL business analysis

Used MySQL to answer questions about overall sales, monthly performance, geographic contribution, product performance, customer value, cancellations, average order value, and repeat purchasing.

### 4. Python and statistics

Used Pandas and statistical analysis to explore customer purchasing behavior, revenue concentration, order frequency, and RFM-based customer segments.

### 5. Power BI and executive reporting

Presented key performance indicators, sales trends, customer analytics, product performance, and risk/opportunity areas in an interactive dashboard and a concise executive report.

## Repository Structure

```text
ecommerce-business-intelligence/
├── README.md
├── dashboard/
│   └── ecommerce_business_intelligence.pbix
├── data/
│   ├── external/
│   ├── processed/
│   │   ├── customer_rfm.csv
│   │   └── online_retail_clean.csv
│   └── raw/
│       └── Online Retail.xlsx
├── notebooks/
│   ├── 01_data_audit.ipynb
│   ├── 02_data_cleaning_validation.ipynb
│   └── 03_python_statistics.ipynb
├── reports/
│   ├── data_quality_notes.md
│   ├── executive_report.md
│   └── executive_report.pdf
├── sql/
│   └── business_analysis.sql
└── src/
    └── data_cleaning.py
```

## How to Explore the Project

1. **Start with `reports/data_quality_notes.md`** to understand data-quality issues and the decisions made during cleaning.
2. **Review the notebooks** in numerical order to follow the audit, cleaning, and Python/statistical analysis.
3. **Run `sql/business_analysis.sql`** against a MySQL database containing the cleaned data.
4. **Open `dashboard/ecommerce_business_intelligence.pbix`** in Power BI Desktop to explore the interactive dashboard.
5. **Read `reports/executive_report.pdf`** for the presentation-ready business summary. The Markdown report provides the accompanying written version.

## Reproducing the Cleaning Pipeline

Use Python with Pandas and an Excel reader such as `openpyxl`. From the repository root, run:

```bash
python -m pip install pandas openpyxl
python src/data_cleaning.py
```

The script expects the original workbook at `data/raw/Online Retail.xlsx` and writes the cleaned CSV to `data/processed/online_retail_clean.csv`.

The notebooks document the analysis workflow. MySQL and Power BI Desktop are required to reproduce the SQL analysis and interact with the dashboard, respectively.

## Data Source

Chen, D. (2015). **Online Retail** [Dataset]. UCI Machine Learning Repository.

https://doi.org/10.24432/C5BW33

The dataset contains transactions for a UK-based online retail business between December 2010 and December 2011. Consult the UCI dataset page for source details and applicable terms.

## Definitions and Limitations

- **Sales revenue** includes rows classified as `SALE`; cancellations and adjustments are kept separate.
- **Identifiable-customer metrics** exclude transactions without a customer ID. Customer-behavior and RFM analyses also require positive-price sales, so their customer count can differ from the overall identifiable-customer count.
- **Cancellation value** is not synonymous with confirmed product returns or customer dissatisfaction.
- **RFM segments** are behavioral groupings based on recency, frequency, and monetary value; they are not proof of future customer behavior.
- **December 2011** is incomplete in this dataset.
- This is historical data from 2010–2011, so the findings should not be interpreted as a description of today's retail market.

## Project Goal

The goal is not just to produce charts or SQL queries. It is to demonstrate a complete analytical workflow: inspect imperfect data, document decisions, analyze business questions, communicate findings, and identify practical next steps for decision-makers.


