library(tidyverse)
library(openxlsx)

# loading current database


# Extracting from lpm-file
dir_path <- choose.dir(
	#"H:/Projekte/Python/METER",
	"T:/Leuchten",
	caption = "Ordner mit *.txt EMV-Dateien auswählen."
)
#dir_path <- "H:/Projekte/Python/METER"
files_path <- list.files(
	path = dir_path, 
	pattern = ".txt$", 
	full.names = TRUE, 
	recursive = TRUE
)

df_emc <- data.frame(datetime = character())
for (file in files_path) {
	first_line <- readLines(file, n = 1)
	if (is_empty(first_line)) {
		first_line = "empty txt-file"
	}
	
	if (first_line == "               Current Harmonic Test Report") {
		datetime <- reader::n.readLines(file, n = 1, skip = 2) %>% 
			read.table(text = ., header = F, sep = "\t", strip.white = T) %>% 
			pivot_wider(names_from = V1, values_from = V2) %>% 
			rename(datetime = `Date/Time:`)
		
		filename <- file %>% 
			basename() %>% 
			tools::file_path_sans_ext() 
		
		type <- data.frame(filename) %>% 
			rename(`type description` = filename)
		
		setting <- reader::n.readLines(file, n = 4, skip = 5) %>% 
			read.table(text = ., header = F, sep = "\t", strip.white = T) %>% 
			pivot_wider(names_from = V1, values_from = V2)

		
		reading_test_results <- reader::n.readLines(file, n = 3, skip = 10) %>% 
			read.table(text = ., header = F, sep = "\t", strip.white = T) %>% 
			pivot_wider(names_from = V1, values_from = V2)

		reading_measurments <- reader::n.readLines(file, n = 8, skip = 12) %>% 
			read_table(col_names = FALSE) %>% 
			mutate(X2 = as.numeric(scan(
				text = X2, 
				dec = ",", 
				sep = ".", 
				quiet = T
				))) %>% 
			pivot_wider(names_from = X1, values_from = X2)
		
		df_emc <- bind_cols(
				datetime, 
				type,
				setting, 
				reading_test_results, 
				reading_measurments
			) %>% 
			bind_rows(df_emc, .)
	}
}


	
# for (file in files_path) {
# 	doc <- readr::read_file(file) %>% 
# 		read_xml()
# 	
# 	# Eindeutige Datumszeit aus der kalten Raumtemperaturmessung beziehen
# 	datetime <- xml_find_all(doc, ".//Raumtemperatur_kalt") %>%
# 		xml_attr("Time") %>%
# 		lubridate::dmy_hms(tz = "CET")
# 	# Kontrolle der eingelesenen Datumszeit 
# 	if (is.na(datetime)) {
# 		datetime <- lubridate::dmy("01.01.1999", tz = "CET")
# 	}
# 	
# 	if (datetime > lubridate::dmy("01.01.2000", tz = "CET")) {
# 		if (!max(datetime == df$datetime)) {
# 			# Leuchtendaten extrahieren
# 			df_luminaire <- xml_find_all(doc, ".//Leuchtendaten") %>% 
# 				xml_attrs() %>% 
# 				data.frame() %>% 
# 				t() %>% 
# 				data.frame() %>% 
# 				remove_rownames()
# 			
# 			# Leuchtenfamilie extrahieren
# 			product_family <- xml_find_all(doc, ".//Allgemein") %>% 
# 				xml_attr("Produktserie")
# 			
# 			# Textblöcke Schutartprüfung, Bemerkungen, Verteiler extrahieren
# 			notes_nodes <- xml_find_all(doc, ".//Weitere_Daten")
# 			note_schutzart <- xml_attr(notes_nodes, "Schutzartpruefung") %>% 
# 				gsub("/;/", "\n", .)
# 			note_bemerkung <- xml_attr(notes_nodes, "Bemerkungen") %>% 
# 				gsub("/;/", "\n", .)
# 			note_verteiler <- xml_attr(notes_nodes, "Verteiler") %>% 
# 				gsub("/;/", "\n", .)
# 			
# 			# Namespace der einzelnen Prüfschritte extrahieren
# 			norm_desc <- xml_find_all(doc, ".//Pruefschritte") %>% 
# 				xml_children() %>% 
# 				xml_name()
# 			
# 			# extracting codename of thermoelements
# 			thermoelement <- xml_find_all(doc, ".//Thermoelemente") %>% 
# 				xml_children()
# 			
# 			thermo_name <- xml_name(thermoelement)
# 			code <- xml_attr(thermoelement, "Code") %>% 
# 				gsub(" ", "_", .) %>% # Ersetzt Leerzeichen
# 				gsub("LED_tc", "LED_Tc", .) %>% # replace incase sensitive names
# 				gsub("LED_TC", "LED_Tc", .) %>% # replace incase sensitive names
# 				paste0("T_", .)
# 			
# 			# Mit den einzelnen Prüfschritte die einzelnen Messergebnisse extrahieren
# 			df_lpm <- data.frame(description = character())
# 			for (desc in norm_desc) {
# 				measurements <- paste0(".//", desc, "/Messergebnisse") %>% 
# 					xml_find_all(doc, .) %>% 
# 					xml_children() %>% 
# 					xml_children()
# 				description <- xml_name(measurements)
# 				description[grep("Thermo", description)] <- code # replace with code
# 				desc_unique <- unique(description)
# 				values <- xml_attr(measurements, "Value") %>% 
# 					gsub("\\.", "", .) %>% 
# 					gsub(",", ".", .) %>% 
# 					as.numeric()
# 				desc <- gsub("Norm", "U", desc) %>%
# 					gsub("Anorm", "UA", .)
# 				df_lpm <- data.frame(description, values) %>% 
# 					group_by(description) %>% 
# 					arrange(desc(values)) %>% # only maximum temperature value
# 					distinct(description, .keep_all = TRUE) %>% # removing duplicate codes
# 					arrange(match(description, desc_unique)) %>% 
# 					mutate(norm = desc) %>% 
# 					bind_rows(df_lpm, .)
# 			}
# 			
# 			# additional columns
# 			df_lpm <- df_lpm %>% 
# 				mutate(
# 					datetime = datetime,
# 					family = product_family,
# 					luminaire = df_luminaire$Leuchtenart,
# 					mounting = df_luminaire$Montageart,
# 					SK = df_luminaire$Schutzklasse,
# 					IP = df_luminaire$IP.Schutzart,
# 					notes1 = note_schutzart,
# 					notes2 = note_bemerkung,
# 					notes3 = note_verteiler,
# 					filepath = file
# 				)
# 			
# 			print(file)
# 			
# 			# reshape from long to wide
# 			df <- df_lpm %>% 
# 				pivot_wider(names_from = c(norm, description), values_from = values) %>% 
# 				bind_rows(df) %>% 
# 				arrange(desc(datetime)) %>% 
# 				relocate(sort(names(.))) %>% 
# 				relocate(
# 					datetime, family, luminaire, mounting, SK, IP, 
# 					notes1, notes2, notes3
# 					) %>% 
# 				relocate(filepath, .after = last_col())
# 		} else {
# 			print(paste("Temperaturmessung", datetime, "bereits eingetragen"))
# 		}	
# 	}
# }
# 
# ## Saving Excel database
# wb <- createWorkbook()
# sheet_name <- "LPG_DB"
# 
# addWorksheet(wb, sheet_name)
# 
# writeDataTable(wb, sheet_name, df, tableStyle = "TableStyleMedium9")
# 
# baseStyle <- createStyle(valign = "top")
# addStyle(
# 	wb, 
# 	sheet_name, 
# 	baseStyle, 
# 	rows = 1:nrow(df) + 1, 
# 	cols = 1:ncol(df), 
# 	gridExpand = TRUE
# )
# 
# wrapStyle <- createStyle(wrapText = TRUE, valign = "top")
# notes_colidx <- grep("notes", colnames(df))
# addStyle(
# 	wb, 
# 	sheet_name, 
# 	wrapStyle, 
# 	rows = 1:nrow(df) + 1, 
# 	cols = notes_colidx, 
# 	gridExpand = TRUE
# )
# 
# dateStyle <- createStyle(numFmt = "dd.mm.yyyy hh:mm:ss", valign = "top")
# date_colidx <- grep("datetime", colnames(df))
# addStyle(
# 	wb, 
# 	sheet_name, 
# 	dateStyle, 
# 	rows = 1:nrow(df) + 1,
# 	cols = date_colidx,
# 	gridExpand = TRUE
# )
# 
# setColWidths(wb, sheet_name, cols = 1:ncol(df), widths = "auto")
# setColWidths(wb, sheet_name, cols = notes_colidx, widths = c(50, 50, 20))
# setColWidths(wb, sheet_name, cols = date_colidx, widths = 17)
# 
# #openXL(wb)
# saveWorkbook(wb, "LPG_Temperatur_DB.xlsx", overwrite = TRUE)
# 
# ## Session Info
# print(sessionInfo())
