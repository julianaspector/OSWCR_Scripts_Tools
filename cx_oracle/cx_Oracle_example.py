import pandas as pd
import cx_Oracle
import os

# Get credentials from environmental variable in conda env
connectString = os.getenv('BRR_credentials')

#Connect to BRR

dsn_tns = cx_Oracle.makedsn("mrsbldbe21277.ad.water.ca.gov", 1521, "B1048")

SQLcxn = cx_Oracle.connect(connectString, dsn=dsn_tns)


#Sample SQL
query ="""select WCRNUMBER,
RECORDTYPE, 
LEGACYLOGNUMBER, 
TOTALCOMPLETEDDEPTH, 
TOPOFPERFORATEDINTERVAL, 
BOTTOMOFPERFORATEDINTERVAL
    FROM DWR_WELLS.VIEWSQL_FINAL_MAT_VW
"""


#Run query and read result to pandas dataframe

df = pd.read_sql(query, SQLcxn)

 

#do other stuff with dataframe…

 

#write pandas dataframe to csv file

df.to_csv('~/anaconda3/envs/oracle_env/files/20200910/VIEWSQL_FINAL_MAT_VW.csv' , index=False,  mode = 'w', header = True, float_format='%g', encoding='utf-8')

