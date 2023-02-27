## Loading Libraries
library(readr)
library(tidyverse)
library(janitor)
library(stringr)
library(readxl)
####################################################################
## Loading Datasets

setwd("C:/Users/PC/Documents/BFI_Movie_Project/raw_data/box_office2")

### IMDB dataset
movies <- clean_names(read_tsv("C:/Users/PC/Documents/BFI_Movie_Project/raw_data/imdb/data.tsv")) 
small_movies <- movies %>%
  filter(title_type=="movie") %>% 
  select(primary_title, is_adult, genres) %>% 
  mutate(genres = case_when(genres == "\\N" ~ " ", TRUE ~ genres)) %>%
  separate_rows(genres, sep = ",") %>% 
  write_csv("imdb_movies_unnested.csv")
  


### BFI dataset

# https://stackoverflow.com/questions/5758084/loop-in-r-to-read-many-files

list <- c(1:52)
for (i in list) {
  filename <- paste0("data ", "(", i, ")")
  wd <- paste0("data ", "(", i, ")", ".xls")
  assign(filename, read_xls(wd))
}
####################################################################
## Data Cleaning
#https://stackoverflow.com/questions/71694690/creating-variable-in-multiple-dataframes-with-different-number-with-r

file_names <- str_extract(list.files(pattern = "*.xls"), "[^.]+")
file_names

for (j in file_names) {
  tmp <- get(j)
  tmp$period <- str_sub(names(tmp)[1], -23,-1)
  names(tmp) <- tmp[1,]
  names(tmp)[ncol(tmp)] <- "period"
  tmp <- clean_names(tmp[-1,-11:-18])
  assign(j,tmp)
}

big_data <- bind_rows(mget(file_names))
big_data$rank <- as.numeric(big_data$rank)
str(big_data)

big_data <- big_data %>% 
  filter(rank>=1 & rank <=15)

write_csv(big_data,"uk_box_office.csv")
