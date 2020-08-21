library(data.table) # rbindlist
library(tidyverse)
library(gsheet)
library(jsonlite)

url <-
  'https://docs.google.com/spreadsheets/d/UNIQUE_KEY/edit?usp=sharing'

file <-
  read.csv(text = gsheet2text(url, format = 'csv'),
           stringsAsFactors = FALSE)

# rename columns from Google Sheet to meaningful headers
file <-
  file %>% select(X, X.5) %>% rename(Date = X, Information = X.5)

# convert JSON information to R object
json_data <- lapply(file$Information, fromJSON)

# extract source because information you need is in there
source <- lapply(json_data, `[[`, c('source'))

# extract URL and file name
id_name <- lapply(source, `[`, c('id', 'name'))

# bind rows into one dataframe for multiple notifications
data <- rbindlist(id_name, use.names = TRUE, fill = TRUE)

# paste id to end of full URL
data$id <- paste0("https://cadwr.app.box.com/file/", data$id)
