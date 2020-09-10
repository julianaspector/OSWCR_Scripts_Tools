library(tidyverse)
library(data.table)

# Read in data from OSWCR and EWM
ewm_master_site <-
  fread("~/anaconda3/envs/oracle_env/files/20200902/EWM_MASTER_SITE.csv")
ewm_station <-
  fread("~/anaconda3/envs/oracle_env/files/20200902/EWM_STATION.csv")
viewsql_final <-
  fread("~/anaconda3/envs/oracle_env/files/20200910/VIEWSQL_FINAL_MAT_VW.csv")
well_numbers <-
  fread("~/anaconda3/envs/oracle_env/files/20200902/WELL_NUMBERS.csv")
ewm_perforations <-
  fread("~/anaconda3/envs/oracle_env/files/20200902/EWM_STATION_PERFORATION.csv")
wcr_links <-
  fread("~/anaconda3/envs/oracle_env/files/20200910/20200901_WCRPDFlinks_table.csv")

# Replace blank rows with NA
ewm_master_site[ewm_master_site == ""] <- NA
ewm_station[ewm_station == ""] <- NA
viewsql_final[viewsql_final == ""] <- NA
viewsql_final[viewsql_final == "NN"] <- NA
viewsql_final[viewsql_final == "NONE"] <- NA
viewsql_final[viewsql_final == 'none'] <- NA
viewsql_final[viewsql_final == 0] <- NA
well_numbers[well_numbers == ""] <- NA
ewm_perforations[ewm_perforations == ""] <- NA

# Join EWM data by common field EWM_MASTER_SITE_ID
EWM_join <-
  full_join(ewm_master_site, ewm_station, by = "EWM_MASTER_SITE_ID")
EWM_join_perf <-
  full_join(EWM_join, ewm_perforations, by = "EWM_STATION_ID")

# Rename columns in EWM data to match OSWCR data
EWM_join_perf <-
  EWM_join_perf %>% rename(
    STATE_WELL_NUMBER = EWM_STATE_WELL_NBR,
    TOTALCOMPLETEDDEPTH = TOTAL_DEPTH_FT,
    TOPOFPERFORATEDINTERVAL = PERFORATION_TOP_MSRMNT,
    BOTTOMOFPERFORATEDINTERVAL = PERFORATION_BOTTOM_MSRMNT,
    LEGACYLOGNUMBER = COMPLETION_RPT_NBR
  )

wcr_links <- wcr_links %>% rename(WCRNUMBER=WCRNumber)

# Join OSWCR data by common field WCRNUMBER
OSWCR_join <-
  full_join(viewsql_final, well_numbers, by = "WCRNUMBER")

# Convert numeric values to integer
OSWCR_join <- OSWCR_join %>% mutate_if(is.numeric, as.integer)
EWM_join_perf <- EWM_join_perf %>% mutate_if(is.numeric, as.integer)

# Drop records with legacy log number as NA and filter for records with no SWN
OSWCR_join_legacy <-
  OSWCR_join %>% drop_na(LEGACYLOGNUMBER) %>% filter(is.na(STATE_WELL_NUMBER) ==
                                                       'TRUE')
ewm_join_legacy <- EWM_join_perf %>% drop_na(LEGACYLOGNUMBER)

# Drop records with SWN NA in OSWCR
OSWCR_join_first <- OSWCR_join %>% drop_na(STATE_WELL_NUMBER)

# first join by SWN
first_join <-
  inner_join(OSWCR_join_first, EWM_join_perf, by = "STATE_WELL_NUMBER")

# second join by LLN
second_join <-
  inner_join(OSWCR_join_legacy, ewm_join_legacy, by = "LEGACYLOGNUMBER")

# filter first join to remove EWM depth data with NA and only new production/monitoring wells from OSWCR
first_join_filtered <-
  first_join %>% select(
    WCRNUMBER,
    TOTALCOMPLETEDDEPTH.y,
    TOPOFPERFORATEDINTERVAL.y,
    BOTTOMOFPERFORATEDINTERVAL.y
  ) %>% drop_na(TOTALCOMPLETEDDEPTH.y)

lookup_PDF <- inner_join(first_join_filtered, wcr_links)