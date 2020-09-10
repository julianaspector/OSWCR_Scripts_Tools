library(tidyverse)
library(data.table)

# Read in data from OSWCR and EWM
ewm_master_site <-
  fread("~/anaconda3/envs/oracle_env/files/20200902/EWM_MASTER_SITE.csv")
ewm_station <-
  fread("~/anaconda3/envs/oracle_env/files/20200902/EWM_STATION.csv")
viewsql_final <-
  fread("~/anaconda3/envs/oracle_env/files/20200904/VIEWSQL_FINAL_MAT_VW.csv")
well_numbers <-
  fread("~/anaconda3/envs/oracle_env/files/20200902/WELL_NUMBERS.csv")
ewm_perforations <-
  fread("~/anaconda3/envs/oracle_env/files/20200902/EWM_STATION_PERFORATION.csv")

ewm_master_site[ewm_master_site == ""] <- NA
ewm_station[ewm_station == ""] <- NA
viewsql_final[viewsql_final == ""] <- NA
well_numbers[well_numbers == ""] <- NA
ewm_perforations[ewm_perforations == ""] <- NA

# Rename column in EWM to match OSWCR
ewm_station <- ewm_station %>% rename(LEGACYLOGNUMBER=COMPLETION_RPT_NBR)

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
    BOTTOMOFPERFORATEDINTERVAL = PERFORATION_BOTTOM_MSRMNT
  )

# Drop na in columns
EWM_join_perf <-
  EWM_join_perf %>% drop_na(TOPOFPERFORATEDINTERVAL,
                            BOTTOMOFPERFORATEDINTERVAL,
                            TOTALCOMPLETEDDEPTH)

# Join OSWCR data by common field WCRNUMBER
OSWCR_join <-
  full_join(viewsql_final, well_numbers, by = "WCRNUMBER")

OSWCR_join <- OSWCR_join %>% drop_na(LEGACYLOGNUMBER) %>% filter(is.na(STATE_WELL_NUMBER)=='TRUE')
ewm_station <- ewm_station %>% drop_na(LEGACYLOGNUMBER)

legacy_log_join <- inner_join(ewm_station, OSWCR_join)

# Drop rows with NA
OSWCR_join <-
  OSWCR_join %>% drop_na(
    STATE_WELL_NUMBER,
    TOTALCOMPLETEDDEPTH,
    TOPOFPERFORATEDINTERVAL,
    BOTTOMOFPERFORATEDINTERVAL
  ) %>%
  select(
    WCRNUMBER,
    STATE_WELL_NUMBER,
    TOPOFPERFORATEDINTERVAL,
    BOTTOMOFPERFORATEDINTERVAL,
    TOTALCOMPLETEDDEPTH
  )

EWM_join_perf <-
  EWM_join_perf %>% drop_na(TOPOFPERFORATEDINTERVAL,
                            BOTTOMOFPERFORATEDINTERVAL,
                            TOTALCOMPLETEDDEPTH) %>%
  select (
    STATE_WELL_NUMBER,
    TOPOFPERFORATEDINTERVAL,
    BOTTOMOFPERFORATEDINTERVAL,
    TOTALCOMPLETEDDEPTH
  )

OSWCR_join <- OSWCR_join %>% mutate_if(is.numeric, as.integer)
EWM_join_perf <- EWM_join_perf %>% mutate_if(is.numeric, as.integer)

same <-
  inner_join(
    EWM_join_perf,
    OSWCR_join,
    by = c(
      "STATE_WELL_NUMBER",
      "TOTALCOMPLETEDDEPTH",
      "BOTTOMOFPERFORATEDINTERVAL",
      "TOPOFPERFORATEDINTERVAL"
    )
  )
total_join <-
  inner_join(EWM_join_perf, OSWCR_join, by = "STATE_WELL_NUMBER")
different <- anti_join(total_join, same)

# Inner join OSWCR and EWM data by SWN ----
swn_join <-
  inner_join(OSWCR_join, EWM_join_perf, by = "STATE_WELL_NUMBER")

# clean swn_join
swn_join[swn_join == "NN"] <- NA

# ANTI-JOIN ----
swn_anti_join <-
  anti_join(EWM_join, OSWCR_join, by = "STATE_WELL_NUMBER")

# SINGLE COMPLETIONS ----
single_completions <- OSWCR_join %>%
  group_by(WCRNUMBER) %>%
  filter(n() == 1)

singleCompletions_join <-
  inner_join(single_completions, EWM_join, by = "STATE_WELL_NUMBER")
singleCompletions_join[singleCompletions_join == "NN"] <- NA
