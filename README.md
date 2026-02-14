# Migrant Health Analytics using Snowflake

## 📌 Project Overview
This project builds an end-to-end data analytics pipeline using Snowflake to analyze migrant health data, including medical visits, lab reports, and vaccination records.

The pipeline is fully automated and supports incremental data loading, data governance, and dashboard analytics.

---

## 🏗️ Architecture
CSV Files → RAW → STAGING → CURATED → ANALYTICS → DASHBOARD

---

## 🧱 Tech Stack
- Snowflake
- SQL
- Snowflake Streams & Tasks
- Snowflake Dashboards
- GitHub

---

## 📂 Data Layers

### RAW
- Stores raw CSV data
- Uses internal stages
- COPY INTO for ingestion

### STAGING
- Cleans and standardizes raw data
- Uses streams for incremental processing

### CURATED
- Deduplicated and trusted data
- MERGE logic via stored procedures
- Automated using tasks
- Data masking applied

### ANALYTICS
- Read-only aggregated views
- Dashboard-ready metrics

---

## 📊 Dashboard Features
- Total migrant workers
- Medical visit trends
- Disease incidence analysis
- Vaccination coverage
- Age and gender health analysis

Dashboards auto-update when new CSV files are added.

---

## 🔄 Automation
- Streams capture new raw data
- Tasks refresh curated layer every 5 minutes
- Dashboards reflect latest data on refresh

---

## 💰 Cost Optimization
- Separate warehouse for ELT tasks
- Auto-suspend enabled
- Tasks suspended when not in use

---

## 🚀 How to Run
1. Execute SQL scripts in order: RAW → STAGING → CURATED → ANALYTICS
2. Upload CSV files to Snowflake stage
3. Resume task for automation
4. Open dashboard to view insights

---

## 👩‍💻 Author
Saranya
# migrant-health-snowflake-project
