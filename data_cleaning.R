# Load packages and clean the environment
library(pacman)
p_load(openxlsx, dplyr, janitor)

rm(list = ls())


# ---- Step 1: Condense data into a single df ----
# Load separate park data
input_folder <- paste0(getwd(), "/raw_data")
files <- list.files(input_folder, pattern = "\\.xlsx$", full.names = TRUE)

full_df <- do.call(rbind, lapply(files, function(file) {
  area_name <- tools::file_path_sans_ext(basename(file))
  
  do.call(rbind, lapply(getSheetNames(file), function(sheet) {
    df <- read.xlsx(file, sheet = sheet)
    df <- janitor::clean_names(df)
    df$protected_area <- area_name
    df$year <- as.integer(sheet)
    df
  }))
}))

# Fix colnames ### THIS IS UGLY, FIX THE ORIGINAL COLNAMES LATER
colnames(full_df)[2:6] <- c("classification", "correct", "notes", "error_type", "file_path") 

# Delete errors
df_correct <- subset(full_df, correct == 1)

# Create an excel file with all unique categories
data_fix <- data.frame(classification = sort(unique(df_correct$classification)),
                       sci_name = character(length = length(sort(unique(df_correct$classification)))),
                       tax_level = character(length = length(sort(unique(df_correct$classification)))),
                       notes = character(length = length(sort(unique(df_correct$classification)))),
                       protected_areas = sapply(sort(unique(df_correct$classification)), function(x) {
                         paste(unique(df_correct$protected_area[df_correct$classification == x]), collapse = ", ")
                       }))

write.xlsx(data_fix, "data_fix.xlsx")








