--Total Registered Migrants
SELECT total_migrants
FROM ANALYTICS.VW_TOTAL_MIGRANTS;


--Total Medical Visits
SELECT SUM(total_visits) AS total_visits
FROM ANALYTICS.VW_MEDICAL_VISITS_TREND;


--Migrants by State
SELECT current_state, migrant_count
FROM ANALYTICS.VW_MIGRANTS_BY_STATE;


--Medical Visits Trend
SELECT visit_date, total_visits
FROM ANALYTICS.VW_MEDICAL_VISITS_TREND
ORDER BY visit_date;


--Disease Trends (Monthly)
SELECT visit_month, diagnosis, total_cases
FROM ANALYTICS.VW_DISEASE_TRENDS;


--Top Diagnoses
SELECT diagnosis, diagnosis_count
FROM ANALYTICS.VW_TOP_DIAGNOSES;


--Hospital Visit Frequency
SELECT hospital_name, visit_count
FROM ANALYTICS.VW_HOSPITAL_VISITS;



--Lab Test Results
SELECT test_name, test_result, result_count
FROM ANALYTICS.VW_LAB_TEST_RESULTS;


--State-wise Health Risk
SELECT current_state, risk_percentage
FROM ANALYTICS.VW_STATE_HEALTH_RISK;


--Age based Analytics
SELECT age_group, gender, total_cases
FROM ANALYTICS.VW_AGE_GENDER_ANALYTICS;


--Vaccination Coverage By Percentage
SELECT vaccine_name, coverage_percentage
FROM ANALYTICS.VW_VACCINATION_COVERAGE_PERCENTAGE;


--Vaccination coverage by vaccine
SELECT
    vaccine_name,
    vaccinated_migrants
FROM HEALTH_DB.ANALYTICS.VW_VACCINATION_COVERAGE;



--Age & Gender Based Analytics
SELECT age_group, gender, total_cases
FROM ANALYTICS.VW_AGE_GENDER_ANALYTICS;
