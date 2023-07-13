# --------------- R script to create the Data_Clean.csv file ---------------
# Run from the command line using RScript create_data_clean_csv_files.R or RScript create_data_clean_csv_files.R wta
# set working directory
setwd("/Users/rorybunker/Google Drive/Research/Bogey Teams in Sport/bogey-phenomenon-sport")

# install welo package if it is not already installed
list.of.packages <- c("welo")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# load the welo library
library("welo")

# Get the command-line argument
args <- commandArgs(trailingOnly = TRUE)

# Set the default dataset to ATP if no argument is provided
dataset <- ifelse(length(args) > 0, tolower(args[1]), "atp")

# Set the file names and load the corresponding RData file
if (dataset == "atp") {
  rdata_file <- "./RData/atp_2005_2020.RData"
  output_csv <- "Data_Clean.csv"
} else if (dataset == "wta") {
  rdata_file <- "./RData/wta_2007_2020.RData"
  output_csv <- "Data_Clean_WTA.csv"
} else {
  stop("Invalid dataset argument. Please use 'atp' or 'wta'.")
}

# Load the RData file
load(rdata_file)

# Apply the welo package's clean function to the loaded data
db_clean <- clean(db)
# Calculate Elo/WElo rating columns
res<-welofit(db_clean)

# Output the cleaned dataset to a CSV file
write.csv(res$dataset, output_csv, row.names = FALSE)
