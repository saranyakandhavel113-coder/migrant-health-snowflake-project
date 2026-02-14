--Analytics View: Total Registered Migrant Workers
CREATE OR REPLACE VIEW ANALYTICS.VW_TOTAL_MIGRANTS AS
SELECT COUNT(DISTINCT migrant_id) AS total_migrants
FROM CURATED.MIGRANT_PROFILES;


--Migrant count by current state
CREATE OR REPLACE VIEW HEALTH_DB.ANALYTICS.VW_MIGRANTS_BY_STATE AS
SELECT
    current_state,
    COUNT(DISTINCT migrant_id) AS migrant_count
FROM HEALTH_DB.CURATED.MIGRANT_PROFILES
GROUP BY current_state;


--Most common diagnoses

CREATE OR REPLACE VIEW HEALTH_DB.ANALYTICS.VW_TOP_DIAGNOSES AS
SELECT
    diagnosis,
    COUNT(*) AS diagnosis_count
FROM HEALTH_DB.CURATED.MEDICAL_VISITS
GROUP BY diagnosis
ORDER BY diagnosis_count DESC;




--Analytics View: Disease Incidence Trends (Monthly)

CREATE OR REPLACE VIEW ANALYTICS.VW_DISEASE_TRENDS AS
SELECT
    diagnosis,
    DATE_TRUNC('MONTH', visit_date) AS visit_month,
    COUNT(*) AS total_cases
FROM CURATED.MEDICAL_VISITS
GROUP BY diagnosis, visit_month;




--Analytics View: Vaccination Coverage Percentage

CREATE OR REPLACE VIEW ANALYTICS.VW_VACCINATION_COVERAGE_PERCENTAGE AS
SELECT
    vaccine_name,
    COUNT(DISTINCT migrant_id) AS vaccinated_count,
    ROUND(
        COUNT(DISTINCT migrant_id) * 100.0 /
        NULLIF(
            (SELECT COUNT(DISTINCT migrant_id)
             FROM CURATED.MIGRANT_PROFILES),
            0
        ),
        2
    ) AS coverage_percentage
FROM CURATED.VACCINATION_RECORDS
GROUP BY vaccine_name;


--Vaccination coverage by vaccine
CREATE OR REPLACE VIEW HEALTH_DB.ANALYTICS.VW_VACCINATION_COVERAGE AS
SELECT
    vaccine_name,
    COUNT(DISTINCT migrant_id) AS vaccinated_migrants
FROM HEALTH_DB.CURATED.VACCINATION_RECORDS
GROUP BY vaccine_name;


--Lab test results summary
CREATE OR REPLACE VIEW HEALTH_DB.ANALYTICS.VW_LAB_TEST_RESULTS AS
SELECT
    test_name,
    test_result,
    COUNT(*) AS result_count
FROM HEALTH_DB.CURATED.LAB_REPORTS
GROUP BY test_name, test_result;


--Complete health overview (joined view)
CREATE OR REPLACE VIEW HEALTH_DB.ANALYTICS.VW_MIGRANT_HEALTH_OVERVIEW AS
SELECT
    mp.migrant_id,
    mp.gender,
    mp.age,
    mp.current_state,
    mv.visit_date,
    mv.diagnosis,
    lr.test_name,
    lr.test_result,
    vr.vaccine_name,
    vr.dose_number
FROM HEALTH_DB.CURATED.MIGRANT_PROFILES mp
LEFT JOIN HEALTH_DB.CURATED.MEDICAL_VISITS mv
    ON mp.migrant_id = mv.migrant_id
LEFT JOIN HEALTH_DB.CURATED.LAB_REPORTS lr
    ON mp.migrant_id = lr.migrant_id
LEFT JOIN HEALTH_DB.CURATED.VACCINATION_RECORDS vr
    ON mp.migrant_id = vr.migrant_id;



--Analytics View: Hospital Visit Frequency
CREATE OR REPLACE VIEW ANALYTICS.VW_HOSPITAL_VISITS AS
SELECT
    UPPER(TRIM(hospital_name)) AS hospital_name,
    COUNT(*) AS visit_count
FROM CURATED.MEDICAL_VISITS
GROUP BY hospital_name;


--Medical visits trend (time series)

CREATE OR REPLACE VIEW HEALTH_DB.ANALYTICS.VW_MEDICAL_VISITS_TREND AS
SELECT
    visit_date,
    COUNT(*) AS total_visits
FROM HEALTH_DB.CURATED.MEDICAL_VISITS
GROUP BY visit_date
ORDER BY visit_date;





--Analytics View: State-wise Health Risk Indicators
CREATE OR REPLACE VIEW ANALYTICS.VW_STATE_HEALTH_RISK AS
SELECT
    m.current_state,
    COUNT(v.visit_id) AS total_visits,
    COUNT_IF(v.diagnosis IS NOT NULL) AS disease_cases,
    ROUND(
        COUNT_IF(v.diagnosis IS NOT NULL) * 100.0 /
        NULLIF(COUNT(v.visit_id), 0),
        2
    ) AS risk_percentage
FROM CURATED.MIGRANT_PROFILES m
JOIN CURATED.MEDICAL_VISITS v
    ON m.migrant_id = v.migrant_id
GROUP BY m.current_state;



--Age & Gender-based Health Analytics

CREATE OR REPLACE VIEW ANALYTICS.VW_AGE_GENDER_ANALYTICS AS
WITH BASE AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(mp.gender)) = 'MALE' THEN 'Male'
            WHEN UPPER(TRIM(mp.gender)) = 'FEMALE' THEN 'Female'
            ELSE 'Unknown'
        END AS gender,
        CASE
            WHEN mp.age < 18 THEN 'Below 18'
            WHEN mp.age BETWEEN 18 AND 30 THEN '18-30'
            WHEN mp.age BETWEEN 31 AND 45 THEN '31-45'
            WHEN mp.age BETWEEN 46 AND 60 THEN '46-60'
            ELSE 'Above 60'
        END AS age_group,
        mv.visit_id
    FROM CURATED.MIGRANT_PROFILES mp
    LEFT JOIN CURATED.MEDICAL_VISITS mv
        ON mp.migrant_id = mv.migrant_id
)
SELECT
    age_group,
    gender,
    COUNT(DISTINCT visit_id) AS total_cases
FROM BASE
GROUP BY age_group, gender;

