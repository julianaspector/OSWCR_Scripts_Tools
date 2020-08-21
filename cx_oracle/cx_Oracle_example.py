import pandas as pd

import cx_Oracle

 

#Connect to BRR

dsn_tns = cx_Oracle.makedsn("server name/IP", 1521, service_name="service name")

SQLcxn = cx_Oracle.connect('user id', 'pwd', dsn_tns)

 

#Sample SQL

query ="""SELECT c.GSP_ID,

c.LOCAL_ID,

case when e.subbasin_n is null then e.basin_name else e.subbasin_n end as basin_name,

case when d.MULTI_GSPAR=0 then 'Single Annual Report' else 'Multiple Annual Reports' end as SINGLE_MULTIPLE_AR,

e.basin_subb as subbasin_number,

b.GSPAR_ID,

f.LABEL as REPORT_YEAR

 

FROM

    SGMAADJBASIN.SGMA_GSPAR_GSP b JOIN

    SGMAADJBASIN.SGMA_GSP c

    ON b.GSP_ID = c.GSP_ID JOIN

    SGMAADJBASIN.SGMA_GSPAR_MAIN d

    ON b.GSPAR_ID = d.GSPAR_ID and b.disabled = 0 join

    SGMAADJBASIN.sgma_pub_basin_lookup e

    on d.basin_key = e.basin_key join

    SGMAADJBASIN.SGMA_GSPAR_REPORTING_YEAR f

    ON d.REPORT_YEAR_ID = f.REPORT_YEAR_ID

where d.status = 'SUBMITTED'

    and d.disabled = 0

ORDER BY basin_name,subbasin_number,SINGLE_MULTIPLE_AR,c.GSP_ID,c.LOCAL_ID,b.GSPAR_ID"""

 

#Run query and read result to pandas dataframe

df = pd.read_sql(query, SQLcxn)

 

#do other stuff with dataframe…

 

#write pandas dataframe to csv file

df.to_csv('path here' , index=False,  mode = 'w', header = True, float_format='%g', encoding='utf-8')

