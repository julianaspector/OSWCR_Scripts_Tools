library(tidyverse)
library(data.table)


# Read in data from OSWCR and EWM
ewm_master_site <-
  fread("~/anaconda3/envs/oracle_env/files/20200824/EWM_MASTER_SITE.csv")
ewm_station <-
  fread("~/anaconda3/envs/oracle_env/files/20200824/EWM_STATION.csv")
viewsql_final <-
  fread("~/anaconda3/envs/oracle_env/files/20200824/VIEWSQL_FINAL_MAT_VW.csv")
well_numbers <-
  fread("~/anaconda3/envs/oracle_env/files/20200824/WELL_NUMBERS_MAT_VW.csv")

ewm_master_site[ewm_master_site == ""] <- NA
ewm_station[ewm_station == ""] <- NA
viewsql_final[viewsql_final == ""] <- NA
well_numbers[well_numbers == ""] <- NA

# Join EWM data by common field EWM_MASTER_SITE_ID
EWM_join <-
  full_join(ewm_master_site, ewm_station, by = "EWM_MASTER_SITE_ID")

# Rename columns in EWM data to match OSWCR data
EWM_join <-
  EWM_join %>% rename(STATE_WELL_NUMBER = EWM_STATE_WELL_NBR)

# Join OSWCR data by common field WCRNUMBER
OSWCR_join <-
  full_join(viewsql_final, well_numbers, by = "WCRNUMBER")

# Drop rows with SWN as NA
OSWCR_join <- OSWCR_join %>% drop_na(STATE_WELL_NUMBER)

# Inner join OSWCR and EWM data by different columns
swn_join <-
  inner_join(OSWCR_join, EWM_join, by = "STATE_WELL_NUMBER")

# clean swn_join
swn_join[swn_join == "NN"] <- NA

# anti-join
swn_anti_join <- anti_join(EWM_join, OSWCR_join, by="STATE_WELL_NUMBER")

single_completions <- OSWCR_join %>% 
  group_by(WCRNUMBER) %>% 
  filter(n()==1)

singleCompletions_join <- inner_join(single_completions, EWM_join, by="STATE_WELL_NUMBER")
singleCompletions_join[singleCompletions_join == "NN"] <- NA
