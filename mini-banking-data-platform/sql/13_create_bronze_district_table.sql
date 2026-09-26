USE ROLE BANKING_PIPELINE_SERVICE_ROLE;
USE WAREHOUSE WAREHOUSE_FOR_LOADING_AND_TRANSFORMING;
USE SCHEMA BANKING_DATA_PLATFORM.BRONZE;

CREATE TABLE IF NOT EXISTS BERKA_DISTRICT_RAW (

    A1  VARCHAR,   -- district_id
    A2  VARCHAR,   -- district name
    A3  VARCHAR,   -- region
    A4  VARCHAR,   -- number of inhabitants
    A5  VARCHAR,   -- number of municipalities with less than 500 inhabitants
    A6  VARCHAR,   -- number of municipalities with 500 to 1999 inhabitants
    A7  VARCHAR,   -- number of municipalities with 2000 to 9999 inhabitants
    A8  VARCHAR,   -- number of municipalities with 10000 or more inhabitants
    A9  VARCHAR,   -- number of cities
    A10 VARCHAR,   -- percent of people who live in cities
    A11 VARCHAR,   -- average salary
    A12 VARCHAR,   -- unemployment rate in 1995
    A13 VARCHAR,   -- unemployment rate in 1996
    A14 VARCHAR,   -- number of entrepreneurs per 1000 inhabitants
    A15 VARCHAR,   -- number of crimes in 1995
    A16 VARCHAR,   -- number of crimes in 1996

    SOURCE_FILE_NAME VARCHAR,
    SOURCE_FILE_ROW_NUMBER NUMBER,
    SOURCE_FILE_LAST_MODIFIED TIMESTAMP_LTZ,
    LOADED_AT_TIMESTAMP TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT='Raw districts from district.csv (Berka dataset). Loaded 1 to 1, all columns as text. Column names A1 to A16 are kept as in the source file.';