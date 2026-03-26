# SQL Beverage Sales Analysis
### A 30-Day SQL Analytics Series

This repository contains the complete SQL analysis from my **#30DaysOfSQL** LinkedIn series, where I answered 25 structured business questions across a beverage sales dataset using Microsoft SQL Server.

The goal was simple practice SQL by asking real business questions on real data, and document every finding in public. What emerged was a complete end-to-end analytical case study covering six analytical segments.

---

## 📁 Repository Structure

```
sql-beverage-sales-analysis/
│
├── README.md
├── queries/
│   └── sql_business_questions.sql
└── data/
    ├── beverage_sales_sample.csv
    └── dataset_schema.md
```

---

## 📊 What This Analysis Covers

| Segment | Questions | Days |
|---|---|---|
| Operational Performance | Product revenue, customer value, regional contribution, AOV by customer type, category quantity | Days 1–5 |
| Profitability & Pricing | Discount rates, discount impact on quantity, discounted vs non-discounted revenue, revenue per unit, discount-driven revenue loss | Days 6–10 |
| Customer Behavior | Repeat customer revenue, highest-revenue customer per region | Days 11–12 |
| Time-Based Trends | Monthly sales trends, yearly revenue, average daily revenue, monthly AOV | Days 13–16 |
| Regional Strategy | Regional discount rates, product performance by region, B2B vs B2C by region, revenue per customer, marketing classification | Days 17–21 |
| Advanced Analytical | Category decline trends, promotional prioritization, inventory strategy, region-category profitability | Days 22–25 |

---

## 🔑 Key Findings

- **Veuve Clicquot and Moët & Chandon** generate 32%+ of total product revenue and lead in 15 of 16 regions
- **Top 5 customers** contribute ~33% of total revenue
- **B2B customers** generate nearly 6× more revenue per order than B2C, driven entirely by volume, not price
- **Discount-quantity correlation** is 0.82, discounts are strongly associated with larger orders
- **Every product** shows revenue loss versus full-price potential despite higher overall revenue under discounting
- **Alcoholic Beverages** generates 18.94 in revenue per unit, nearly 7× more than Juices and 18× more than Water
- **February** consistently underperforms every year; **July–August** consistently peaks
- **Hamburg × Alcoholic Beverages** is the single most profitable region-category combination
- **100% of customers** are repeat buyers across all 10,000 accounts

---

## 🛠️ SQL Techniques Used

- Window Functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, `NTILE`)
- LAG & LEAD for trend analysis
- Common Table Expressions (CTEs)
- CASE WHEN for conditional aggregation
- Weighted averages and correlation calculation
- CROSS JOIN for benchmarking frameworks
- Subqueries and nested queries
- Seasonal and time-based analysis with `YEAR()`, `MONTH()`, `DATENAME()`
- Partitioned aggregations with `OVER(PARTITION BY)`

---

## 🗄️ Dataset

This analysis uses a **5% random sample** of the original Kaggle dataset.

- **Original Dataset:** [Synthetic Beverage Sales Data](https://www.kaggle.com/datasets/ambikaprasadrath/synthetic-beverage-sales-data) by Ambika Prasad Rath on Kaggle
- **Sample File:** `data/beverage_sales_sample.csv`
- **Records in sample:** ~21,000 rows
- **Time period:** 2021–2023
- **Geography:** 16 German states

See `data/dataset_schema.md` for full column descriptions.

---

## ⚙️ How to Use

1. Clone the repository
```bash
git clone https://github.com/victoria-iyanu/sql-beverage-sales-analysis.git
```

2. Import `data/beverage_sales_sample.csv` into your SQL Server database as a table named `SalesOrders`

3. Run the queries in `queries/sql_business_questions.sql`

> **Note:** All queries are written in **T-SQL (Microsoft SQL Server)**. Some functions like `DATEFROMPARTS()`, `DATENAME()`, and `DATEPART()` are SQL Server specific and may require minor adjustments for other dialects.

---

## 📌 LinkedIn Series

All 25 daily analysis posts and 5 recommendation posts from this series are published on my LinkedIn profile.

🔗 [Follow me on LinkedIn](https://www.linkedin.com/in/victoria-iyanu/) for data analytics content, SQL breakdowns, and learning in public.

---

## 📄 License

This project is for educational and portfolio purposes. The dataset sample is derived from the original Kaggle dataset, please refer to the original source for licensing terms.

---

*Built with curiosity, one query at a time.* 🎯
