# Visualize measurement data of LPG ----


## Load libraries ----

# Wokr horse packages
library(tidyverse)
library(lubridate)

# theme_tq()
library(tidyquant)

# Excel files
library(readxl)
library(writexl)


## Importing files ----

LPG_tbl <- read_excel("data_extracted/LPG_Temperatur_DB.xlsx")

glimpse(LPG_tbl)


## Wrangling data ----

df <- LPG_tbl %>% 
	pivot_longer(
		U090_INenn:UA110_VG_BWQuotient,
		names_to = c("V", "sensor"),
		#names_sep = "_"
		names_pattern = '(.*?)_(.*)', 
	)





