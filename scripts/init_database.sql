/* =========================================================================
   PHASE 1: DATABASE & SCHEMA SETUP
   ========================================================================= */
-- 1. Drop and recreate the database (Run this first)
DROP DATABASE IF EXISTS data_ware_house WITH (FORCE);
CREATE DATABASE data_ware_house;

-- ⚠️ STOP HERE! ⚠️
-- You must change your active database connection in DBeaver's top toolbar 
-- to 'data_ware_house' before running the rest of the script below!

-- 2. Create the Data Warehouse Layers
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
