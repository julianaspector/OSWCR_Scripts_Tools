library(rvest)
library(anytime)
library(tidyverse)

# make sure to disconnect from vpn, otherwise server will time out

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#SET UP
license_csv_view <- "./20200731/LicenseExpirationDates_20200731.csv"
#datetime_filter <- "2020-06-30 00:00:00"

#read csv
license_csv <- read.csv(license_csv_view)
license_table <- license_csv

# filter--remove records with expiration date 6/30/2020
#license_table <- license_csv %>% filter(LIC_EXPIR_DD != datetime_filter)

# license detail page
base_url <-
  "https://www.cslb.ca.gov/OnlineServices/CheckLicenseII/LicenseDetail.aspx?LicNum="

# create links and read html off pages
license_pages <- data_frame(
  LIC_NBR = license_table$LIC_NBR,
  link = paste0(base_url, LIC_NBR),
  page = map(link, read_html)
)

# extract data from relevant nodes on each page
license_specs <- license_pages %>%
  mutate(node_license = map(page, html_node, 'h1 span'),
         node_exp_date = map(page, html_node, '#MainContent_ExpDt'),
         LIC_NBR = as.character(map(node_license, html_text)),
         NEW_LIC_EXPIR_DD = map(node_exp_date, html_text))

# select relevant columns, unnest expiration dates list and convert to date
license_specs <- license_specs %>% select(LIC_NBR, NEW_LIC_EXPIR_DD)
license_specs <- license_specs %>% unnest(NEW_LIC_EXPIR_DD)
license_specs$NEW_LIC_EXPIR_DD <- anydate(license_specs$NEW_LIC_EXPIR_DD)

# join by LIC_NBR
joined_license_info <- inner_join(license_table, license_specs, by="LIC_NBR")
joined_license_info$LIC_EXPIR_DD <- anydate(joined_license_info$LIC_EXPIR_DD)

to_update <- joined_license_info %>% filter(NEW_LIC_EXPIR_DD > LIC_EXPIR_DD)
