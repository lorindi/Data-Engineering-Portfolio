USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS BANKING_DATA_PLATFORM
    COMMENT = 'Mini banking data platform. Source data: Berka dataset from a Czech bank, published for the Principles and Practice of Knowledge Discovery in Databases (PKDD) 1999 Discovery Challenge.';

USE DATABASE BANKING_DATA_PLATFORM;

CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'First layer. Stores raw data exactly as it comes from the source files. No changes and no business rules.';

CREATE SCHEMA IF NOT EXISTS SILVER_RAW_VAULT
    COMMENT = 'Second layer, part one. Stores data in Data Vault format: hubs, links and satellites. Keeps the full history of all changes. No business rules.';

CREATE SCHEMA IF NOT EXISTS SILVER_BUSINESS_VAULT
    COMMENT = 'Second layer, part two. Adds business rules on top of the raw vault, for example gender from birth number and translation of Czech codes.';

CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Third layer. Stores clean, ready-to-use tables for reports, dashboards and regulatory reporting.';

CREATE SCHEMA IF NOT EXISTS GOVERNANCE
    COMMENT = 'Stores security and control objects: masking policies, row access policies, tags and data quality check results.';