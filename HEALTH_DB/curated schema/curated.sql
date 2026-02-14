
CREATE OR REPLACE TABLE HEALTH_DB.CURATED.MIGRANT_PROFILES (
    migrant_id STRING,
    age INT,
    gender STRING,
    home_state STRING,
    current_state STRING,
    created_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_ts TIMESTAMP
);


CREATE OR REPLACE TABLE HEALTH_DB.CURATED.MEDICAL_VISITS (
    visit_id STRING,
    migrant_id STRING,
    visit_date DATE,
    diagnosis STRING,
    treatment STRING,
    hospital_name STRING,
    created_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE TABLE HEALTH_DB.CURATED.LAB_REPORTS (
    report_id STRING,
    migrant_id STRING,
    test_name STRING,
    test_result STRING,
    report_date DATE,
    created_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE TABLE HEALTH_DB.CURATED.VACCINATION_RECORDS (
    migrant_id STRING,
    vaccine_name STRING,
    dose_number INT,
    vaccination_date DATE,
    created_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE MASKING POLICY HEALTH_DB.CURATED.MASK_MIGRANT_ID
AS (val STRING) RETURNS STRING ->
CASE
    WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'HEALTH_ADMIN')
        THEN val
    ELSE 'MASKED_ID'
END;




ALTER TABLE HEALTH_DB.CURATED.MIGRANT_PROFILES
MODIFY COLUMN migrant_id
SET MASKING POLICY HEALTH_DB.CURATED.MASK_MIGRANT_ID;

ALTER TABLE HEALTH_DB.CURATED.MEDICAL_VISITS
MODIFY COLUMN migrant_id
SET MASKING POLICY HEALTH_DB.CURATED.MASK_MIGRANT_ID;

ALTER TABLE HEALTH_DB.CURATED.LAB_REPORTS
MODIFY COLUMN migrant_id
SET MASKING POLICY HEALTH_DB.CURATED.MASK_MIGRANT_ID;

ALTER TABLE HEALTH_DB.CURATED.VACCINATION_RECORDS
MODIFY COLUMN migrant_id
SET MASKING POLICY HEALTH_DB.CURATED.MASK_MIGRANT_ID;


CREATE OR REPLACE PROCEDURE HEALTH_DB.CURATED.SP_REFRESH_CURATED()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

-- Migrant Profiles (UPSERT)
MERGE INTO HEALTH_DB.CURATED.MIGRANT_PROFILES t
USING HEALTH_DB.STAGING.MIGRANT_PROFILES s
ON t.migrant_id = s.migrant_id
WHEN MATCHED THEN
    UPDATE SET
        age = s.age,
        gender = s.gender,
        home_state = s.home_state,
        current_state = s.current_state,
        updated_ts = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT (migrant_id, age, gender, home_state, current_state)
    VALUES (s.migrant_id, s.age, s.gender, s.home_state, s.current_state);

-- Medical Visits (Insert-only)
MERGE INTO HEALTH_DB.CURATED.MEDICAL_VISITS t
USING HEALTH_DB.STAGING.MEDICAL_VISITS s
ON t.visit_id = s.visit_id
WHEN NOT MATCHED THEN
    INSERT (visit_id, migrant_id, visit_date, diagnosis, treatment, hospital_name)
    VALUES (s.visit_id, s.migrant_id, s.visit_date, s.diagnosis, s.treatment, s.hospital_name);

-- Lab Reports
MERGE INTO HEALTH_DB.CURATED.LAB_REPORTS t
USING HEALTH_DB.STAGING.LAB_REPORTS s
ON t.report_id = s.report_id
WHEN NOT MATCHED THEN
    INSERT (report_id, migrant_id, test_name, test_result, report_date)
    VALUES (s.report_id, s.migrant_id, s.test_name, s.test_result, s.report_date);

-- Vaccination Records
MERGE INTO HEALTH_DB.CURATED.VACCINATION_RECORDS t
USING HEALTH_DB.STAGING.VACCINATION_RECORDS s
ON t.migrant_id = s.migrant_id
AND t.vaccine_name = s.vaccine_name
AND t.dose_number = s.dose_number
WHEN NOT MATCHED THEN
    INSERT (migrant_id, vaccine_name, dose_number, vaccination_date)
    VALUES (s.migrant_id, s.vaccine_name, s.dose_number, s.vaccination_date);

RETURN 'CURATED LAYER UPDATED SUCCESSFULLY';

END;
$$;


CALL HEALTH_DB.CURATED.SP_REFRESH_CURATED();

CREATE OR REPLACE TASK HEALTH_DB.CURATED.TASK_REFRESH_CURATED
WAREHOUSE = PIPELINE_WH
SCHEDULE = '5 MINUTE'
AS
CALL HEALTH_DB.CURATED.SP_REFRESH_CURATED();


ALTER TASK HEALTH_DB.CURATED.TASK_REFRESH_CURATED RESUME;


CREATE OR REPLACE VIEW HEALTH_DB.CURATED.VW_MIGRANT_PROFILES AS
SELECT migrant_id, age, gender, current_state
FROM HEALTH_DB.CURATED.MIGRANT_PROFILES;

CREATE OR REPLACE VIEW HEALTH_DB.CURATED.VW_MEDICAL_VISITS AS
SELECT migrant_id, visit_date, diagnosis, treatment, hospital_name
FROM HEALTH_DB.CURATED.MEDICAL_VISITS;

CREATE OR REPLACE VIEW HEALTH_DB.CURATED.VW_VACCINATION_RECORDS AS
SELECT migrant_id, vaccine_name, dose_number, vaccination_date
FROM HEALTH_DB.CURATED.VACCINATION_RECORDS;





