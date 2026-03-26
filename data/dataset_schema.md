# Dataset Schema

## Table: SalesOrders

This document describes the structure of the `beverage_sales_sample.csv` file used in this analysis.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `Order_ID` | VARCHAR | Unique identifier for each order | ORD6 |
| `Customer_ID` | VARCHAR | Unique identifier for each customer | CUS533 |
| `Customer_Type` | VARCHAR | Type of customer — either B2B or B2C | B2B |
| `Product` | VARCHAR | Name of the product ordered | Mango Juice |
| `Category` | VARCHAR | Product category | Juices |
| `Unit_Price` | DECIMAL | Price per unit before discount | 2.50 |
| `Quantity` | INT | Number of units ordered | 10 |
| `Discount` | DECIMAL | Discount rate applied (0.00 to 0.10) | 0.05 |
| `Total_Price` | DECIMAL | Final order value after discount applied | 23.75 |
| `Region` | VARCHAR | German state where the order was placed | Saarland |
| `Order_Date` | DATE | Date the order was placed | 2023-02-18 |

---

## Categories

The dataset contains four product categories:

| Category | Description |
|---|---|
| Alcoholic Beverages | Premium spirits, champagne, wine, and beer |
| Juices | Fruit and vegetable juices |
| Soft Drinks | Carbonated drinks and energy drinks |
| Water | Still and sparkling water brands |

---

## Regions

The dataset covers all 16 German federal states (Bundesländer):

Baden-Württemberg, Bayern, Berlin, Brandenburg, Bremen, Hamburg, Hessen, Mecklenburg-Vorpommern, Niedersachsen, Nordrhein-Westfalen, Rheinland-Pfalz, Saarland, Sachsen, Sachsen-Anhalt, Schleswig-Holstein, Thüringen

---

## Calculated Fields

Some analyses derive additional fields from the base columns:

| Derived Field | Formula | Used In |
|---|---|---|
| Full Price Revenue | `Unit_Price × Quantity` | Days 9, 10, 23 |
| Revenue Loss from Discount | `Total_Price − (Unit_Price × Quantity)` | Day 9 |
| Weighted Discount Rate | `SUM(Discount × Unit_Price × Quantity) / SUM(Unit_Price × Quantity)` | Days 6, 17 |
| Average Order Value (AOV) | `SUM(Total_Price) / COUNT(DISTINCT Order_ID)` | Days 4, 16, 21 |
| Revenue Per Unit | `SUM(Unit_Price × Quantity) / SUM(Quantity)` | Day 10 |

---

## Notes

- `Total_Price` is calculated as `Unit_Price × Quantity × (1 − Discount)`
- Discount values are either 0.00 (no discount) or 0.05/0.10 (5% or 10% discount)
- The dataset covers orders from January 2021 through December 2023
- This file is a 5% random sample of the original Kaggle dataset
- Original source: [Synthetic Beverage Sales Data](https://www.kaggle.com/datasets/ambikaprasadrath/synthetic-beverage-sales-data)
