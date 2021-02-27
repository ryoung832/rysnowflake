USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEMO_DB;

--Masking Policies
--DROP MASKING POLICY CUSTOMER_MASK
CREATE MASKING POLICY CUSTOMER_MASK AS (VAL CHARACTER VARYING(30)) RETURNS CHARACTER VARYING(30) ->
    CASE
        WHEN CURRENT_ROLE() IN ('DATASCIENTIST') THEN '**********'
        ELSE VAL
    END;
    
 ALTER TABLE CUSTOMERS ALTER CONTACT_NAME SET MASKING POLICY CUSTOMER_MASK;
 

USE ROLE DATASCIENTIST;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEMO_DB;

SELECT * FROM CUSTOMERS

USE ROLE CUST_DATASCIENTIST;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEMO_DB;

SELECT * FROM CUSTOMERS
