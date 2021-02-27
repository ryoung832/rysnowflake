--Create some new security roles that represent differnet user scenarios
create role datascientist comment = 'Data Scientists with no access to customer identifying data';
create role analyst comment = 'Analysts with no access to customer identifying data';
create role cust_datascientist comment = 'Data Scientists with authorised access to customer identifying data';
create role cust_analyst comment ='Analysts with authorised access to customer identifying data';

