# =========================================================
# COFFEE SHOP SALES DATA ANALYSIS PROJECT
# Python + PostgreSQL + Data Visualization
# =========================================================


# =========================================================
# IMPORT LIBRARIES
# =========================================================

import pandas as pd
import matplotlib.pyplot as plt
from sqlalchemy import create_engine


# =========================================================
# CONNECT TO POSTGRESQL DATABASE
# =========================================================

# Replace YOUR_PASSWORD with your real PostgreSQL password

engine = create_engine(
    "postgresql+psycopg2://postgres:12504543@localhost:5432/postgres"
)


# =========================================================
# LOAD DATA FROM SQL
# =========================================================

query = "SELECT * FROM coffee_shop_sales"

df = pd.read_sql(query, engine)


# =========================================================
# BASIC DATA INFORMATION
# =========================================================

print("\n========== FIRST 5 ROWS ==========")
print(df.head())

print("\n========== DATA TYPES ==========")
print(df.dtypes)

print("\n========== SHAPE ==========")
print(df.shape)

print("\n========== NULL VALUES ==========")
print(df.isnull().sum())


# =========================================================
# REMOVE DUPLICATES
# =========================================================

df = df.drop_duplicates()

print("\nDuplicates Removed Successfully")


# =========================================================
# CREATE TOTAL SALES COLUMN
# =========================================================

df["total_sales"] = (
    df["transaction_qty"] * df["unit_price"]
)

print("\nTotal Sales Column Created")


# =========================================================
# TOTAL REVENUE
# =========================================================

total_revenue = df["total_sales"].sum()

print("\n========== TOTAL REVENUE ==========")
print(round(total_revenue, 2))


# =========================================================
# AVERAGE ORDER VALUE
# =========================================================

average_order_value = df["total_sales"].mean()

print("\n========== AVERAGE ORDER VALUE ==========")
print(round(average_order_value, 2))


# =========================================================
# TOP SELLING PRODUCTS
# =========================================================

top_products = (
    df.groupby("product_detail")["transaction_qty"]
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

print("\n========== TOP SELLING PRODUCTS ==========")
print(top_products)


# =========================================================
# SALES BY STORE LOCATION
# =========================================================

store_sales = (
    df.groupby("store_location")["total_sales"]
    .sum()
    .sort_values(ascending=False)
)

print("\n========== SALES BY STORE LOCATION ==========")
print(store_sales)


# =========================================================
# SALES BY PRODUCT CATEGORY
# =========================================================

category_sales = (
    df.groupby("product_category")["total_sales"]
    .sum()
    .sort_values(ascending=False)
)

print("\n========== PRODUCT CATEGORY SALES ==========")
print(category_sales)


# =========================================================
# CONVERT DATE COLUMN
# =========================================================

df["transaction_date"] = pd.to_datetime(
    df["transaction_date"],
    errors="coerce"
)


# =========================================================
# MONTHLY SALES ANALYSIS
# =========================================================

df["month"] = df["transaction_date"].dt.month_name()

month_order = [
    "January", "February", "March",
    "April", "May", "June",
    "July", "August", "September",
    "October", "November", "December"
]

monthly_sales = (
    df.groupby("month")["total_sales"]
    .sum()
    .reindex(month_order)
)

print("\n========== MONTHLY SALES ==========")
print(monthly_sales)


# =========================================================
# WEEKDAY SALES ANALYSIS
# =========================================================

df["weekday"] = df["transaction_date"].dt.day_name()

weekday_order = [
    "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday",
    "Saturday", "Sunday"
]

weekday_sales = (
    df.groupby("weekday")["total_sales"]
    .sum()
    .reindex(weekday_order)
)

print("\n========== WEEKDAY SALES ==========")
print(weekday_sales)


# =========================================================
# CONVERT TIME COLUMN
# =========================================================

df["transaction_time"] = pd.to_datetime(
    df["transaction_time"].astype(str),
    format="%H:%M:%S",
    errors="coerce"
)


# =========================================================
# PEAK SALES HOURS
# =========================================================

df["hour"] = df["transaction_time"].dt.hour

hourly_sales = (
    df.groupby("hour")["transaction_id"]
    .count()
)

print("\n========== PEAK SALES HOURS ==========")
print(hourly_sales)


# =========================================================
# VISUALIZATION 1
# TOP PRODUCTS
# =========================================================

plt.figure(figsize=(12, 6))

top_products.plot(kind="bar")

plt.title("Top 10 Best Selling Products")
plt.xlabel("Products")
plt.ylabel("Quantity Sold")

plt.xticks(rotation=45)

plt.tight_layout()
plt.show()


# =========================================================
# VISUALIZATION 2
# STORE SALES
# =========================================================

plt.figure(figsize=(10, 5))

store_sales.plot(kind="bar")

plt.title("Sales by Store Location")
plt.xlabel("Store")
plt.ylabel("Revenue")

plt.tight_layout()
plt.show()


# =========================================================
# VISUALIZATION 3
# CATEGORY SALES
# =========================================================

plt.figure(figsize=(10, 5))

category_sales.plot(kind="bar")

plt.title("Revenue by Product Category")
plt.xlabel("Category")
plt.ylabel("Revenue")

plt.tight_layout()
plt.show()


# =========================================================
# VISUALIZATION 4
# MONTHLY SALES TREND
# =========================================================

plt.figure(figsize=(12, 6))

monthly_sales.plot(kind="line", marker="o")

plt.title("Monthly Sales Trend")
plt.xlabel("Month")
plt.ylabel("Revenue")

plt.xticks(rotation=45)

plt.tight_layout()
plt.show()


# =========================================================
# VISUALIZATION 5
# PEAK SALES HOURS
# =========================================================

plt.figure(figsize=(12, 6))

hourly_sales.plot(kind="line", marker="o")

plt.title("Peak Sales Hours")
plt.xlabel("Hour")
plt.ylabel("Orders")

plt.tight_layout()
plt.show()


# =========================================================
# VISUALIZATION 6
# WEEKDAY SALES
# =========================================================

plt.figure(figsize=(10, 5))

weekday_sales.plot(kind="bar")

plt.title("Weekday Sales Analysis")
plt.xlabel("Weekday")
plt.ylabel("Revenue")

plt.xticks(rotation=45)

plt.tight_layout()
plt.show()


# =========================================================
# EXPORT CLEANED DATA
# =========================================================

df.to_csv(
    "cleaned_coffee_shop_sales.csv",
    index=False
)

print("\nCleaned CSV Exported Successfully")


# =========================================================
# SAVE ANALYSIS TABLES TO SQL
# =========================================================

top_products.to_sql(
    "top_selling_products",
    engine,
    if_exists="replace"
)

store_sales.to_sql(
    "store_sales_summary",
    engine,
    if_exists="replace"
)

category_sales.to_sql(
    "category_sales_summary",
    engine,
    if_exists="replace"
)

print("\nAnalysis Tables Saved to PostgreSQL")


# =========================================================
# CLOSE CONNECTION
# =========================================================

engine.dispose()


# =========================================================
# PROJECT COMPLETED
# =========================================================

print(
    "\n========== COFFEE SHOP SALES ANALYSIS COMPLETED =========="
)