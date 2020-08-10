library(data.table) # rbindlist
library(tidyverse)
library(googlesheets)

url <-
  'https://docs.google.com/spreadsheets/d/1Nj4QjYX-NsL8wZoNtUZL3OLGnMmcNhAzBXK9u5x3JBc/edit?usp=sharing'

file <-
  read.csv(text = gsheet2text(url, format = 'csv'),
           stringsAsFactors = FALSE)

file <- file %>% select(X, X.5) %>% rename(Date = X, Information = X.5)

json_data <- lapply(file$Information, fromJSON)

source <- lapply(json_data, `[[`, c('source'))

id_name <- lapply(source, `[`, c('id', 'name'))

data <- rbindlist(id_name, use.names = TRUE, fill = TRUE)

data$id <- paste0("https://cadwr.app.box.com/file/", data$id)
