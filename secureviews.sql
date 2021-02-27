use demo_db;
--Create some new security roles that represent differnet user scenarios
create role datascientist comment = 'Data Scientists with no access to customer identifying data';
create role analyst comment = 'Analysts with no access to customer identifying data';
create role cust_datascientist comment = 'Data Scientists with authorised access to customer identifying data';
create role cust_analyst comment ='Analysts with authorised access to customer identifying data';

grant operate on warehouse compute_wh to role analyst;
grant operate on warehouse compute_wh to role cust_analyst;
grant operate on warehouse compute_wh to role datascientist;
grant operate on warehouse compute_wh to role cust_datascientist;

--grant role to users
grant role datascientist to user ry*******;
grant role analyst to user ry*******;
grant role cust_datascientist to user ry*******;
grant role cust_analyst to user ry*******;

--create a view
select * from customers;
create view nopii_customers comment='View No Identifying Customer Data' as 
    select city, region, postal_code, country 
    from customers 
    where city<>'Berlin';

create secure view sv_nopii_customers comment='Secure View No Identifying Customer Data' as 
    select city, region, postal_code, country 
       from customers 
       where city<>'Berlin';

--drop view nopii_customers;

--create a secure view

--map privilages to roles
grant select on table customers to cust_analyst;
grant select on view nopii_customers to cust_analyst;
grant select on view sv_nopii_customers to cust_analyst;

grant select on view nopii_customers to analyst;
grant select on view sv_nopii_customers to analyst;



--switch role to cust_analyst
--both queries should execute correctly
use role cust_analyst;
use demo_db;
use warehouse compute_wh;

select * from customers;

select * from nopii_customers;

--switch role to analyst
--view should only execute correctly
use role analyst;
use demo_db;
use warehouse compute_wh;

select * from customers; -- Fail Not authorised
select * from nopii_customers; --Success
select * from sv_nopii_customers; --Success

--However a view may not be as secure as it could be given example from snowflake error may not occur as it depends on optimiser behavior
select * 
    from nopii_customers 
    where 1/iff(city = 'Berlin',0,1)= 1;

--This is why secure views exist to remove some of those optimiser functions at the cost of some performance

--This will show query used to create view
show views like 'nopii_customers';
--This will not show query used to create view as it is a secure view
show views like 'sv_nopii_customers';

--Interestingly different row level access controls can be implemented using a access rules table
use role accountadmin;
use demo_db;
use warehouse compute_wh;

create table customer_access_rules (
  city character varying(15),
  role_name varchar
);

insert into customer_access_rules values('Berlin','analyst');
select * from customer_access_rules;
select current_role();

create secure view ar_sv_nopii_customers comment='Access Rules No Identifying Customer Data' as 
    select c.city, c.region, c.postal_code, c.country 
    from customers c 
    where c.city not in 
        (select car.city 
         from customer_access_rules car 
         where upper(car.role_name) = current_role());
        
grant select on view ar_sv_nopii_customers to analyst;

use role analyst;
use demo_db;
use warehouse compute_wh;

select * from customers; -- Fail Not authorised
select * from nopii_customers; --Success
select * from sv_nopii_customers; --Success
select * from ar_sv_nopii_customers; --Success

