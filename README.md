# Video Game Sales Analytics

> **Description:** An end-to-end data analytics project exploring global video game sales trends, regional genre preferences, console lifecycles, and publisher performance using a dataset of over 64,000 games. It simulates a real-world business workflow, moving from raw CSV data ingestion and SQL processing in MySQL to building interactive executive dashboards in Power BI.

## 1. Project Overview

### 1.1. Project Title
Video Game Sales Analytics: Regional Preferences, Console Lifecycles and Publisher Performance

### 1.2. Project Background
The video game industry operates across diverse markets, platforms, and customer segments. A successful product in North America may not achieve similar performance in Japan or Europe. Meanwhile, each gaming console has its own commercial lifecycle, while publishers must constantly decide which genres, platforms, and regions to invest in.

The Video Game Sales Analytics project is built to analyze video game sales data at the market level, thereby assisting industry managers and C-level executives in answering three core groups of questions:
* How do game genre preferences differ across regions?
* Which consoles generate the highest sales, and how do their commercial lifecycles unfold?
* Which publishers dominate the market, and what are their flagship product groups?

The project simulates a business-oriented data analytics workflow, where data is ingested directly from source files into MySQL, processed using SQL, organized into an analytical data model, and connected to Power BI to build dashboards.

### 1.3. Project Objective
The objective of the project is to build an end-to-end data processing pipeline:

```text
Raw CSV
   ↓
MySQL Staging Layer
   ↓
Data Cleaning and Validation
   ↓
Exploratory Data Analysis
   ↓
Power BI Visualization
   ↓
Executive Dashboard and Business Insights

## 2. Data Source

### 2.1. Dataset Information
Data is sourced from:
* **Dataset:** Video Game Sales 2024
* **Author:** asaniczka
* **Platform:** Kaggle
* **File:** `vgchartz-2024.csv`
* **Dataset page:** Kaggle – Video Game Sales 2024

The dataset contains information on over 64,000 video game releases. The data page indicates that the dataset builds upon previous versions of Video Game Sales and was collected using a web spider based on Bayne Brannen's process. The author removed the `vg_score`, `user_score`, and `total_shipped` columns as these fields largely contained missing values.

### 2.2. Raw Data Dictionary
The original file consists of 14 data fields. The column list and meanings are referenced from the public structure of `vgchartz-2024.csv`.

| Column | Suggested MySQL type | Description | Analytical role |
| :--- | :--- | :--- | :--- |
| `img` | `TEXT` | Image path or URL for game cover | Metadata |
| `title` | `VARCHAR(255)` | Game name | Game dimension |
| `console` | `VARCHAR(50)` | Console or release platform | Console dimension |
| `genre` | `VARCHAR(100)` | Game genre | Genre dimension |
| `publisher` | `VARCHAR(255)` | Game publishing company | Publisher dimension |
| `developer` | `VARCHAR(255)` | Game development unit | Developer dimension |
| `critic_score` | `DECIMAL(4,2)` | Average review score from critics | Optional quality metric |
| `total_sales` | `DECIMAL(10,2)` | Total global sales in millions of copies | Core fact |
| `na_sales` | `DECIMAL(10,2)` | Sales in North America in millions of copies | Core regional fact |
| `jp_sales` | `DECIMAL(10,2)` | Sales in Japan in millions of copies | Core regional fact |
| `pal_sales` | `DECIMAL(10,2)` | Sales in PAL markets, primarily representing Europe and PAL regions | Core regional fact |
| `other_sales` | `DECIMAL(10,2)` | Sales in remaining regions | Core regional fact |
| `release_date` | `DATE` | Game release date | Date dimension |
| `last_update` | `DATE` | The date the record was last updated at the source | Technical metadata |
