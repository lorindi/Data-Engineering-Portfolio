
USE ROLE USERADMIN;

CREATE ROLE IF NOT EXISTS BANKING_PIPELINE_SERVICE_ROLE
    COMMENT='Technical role for Apache Airflow and data build tool (dbt). Loads and transform data.';

CREATE ROLE IF NOT EXISTS BANKING_DATA_ENGINEER_ROLE
    COMMENT='Role for data engineers. Full access to build and support the platform.';

CREATE ROLE IF NOT EXISTS BANKING_DATA_ANALYST_ROLE
    COMMENT='Role for business analysts. Read-only access to the GOLD layer.';