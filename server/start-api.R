#!/usr/bin/env Rscript

# Startup script for Plumber API
cat("Starting Greenhouse Gas Emissions API...\n")

# Load environment variables
data_dir <- Sys.getenv("DATA_DIR", "./data")
api_port <- as.numeric(Sys.getenv("API_PORT", "8000"))
api_host <- Sys.getenv("API_HOST", "0.0.0.0")

cat(sprintf("Configuration:\n"))
cat(sprintf("  Data directory: %s\n", data_dir))
cat(sprintf("  API port: %d\n", api_port))
cat(sprintf("  API host: %s\n", api_host))

# Check if data files exist
required_files <- c(
    file.path(data_dir, "global_complete_data.json"),
    file.path(data_dir, "TOTAL-Greenhouse-Gases", "data_total_greenhouse.csv"),
    file.path(data_dir, "country-code-and-numeric.json")
)

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
    cat("ERROR: Missing required data files:\n")
    for (file in missing_files) {
        cat(sprintf("  - %s\n", file))
    }
    stop("Cannot start API without required data files")
}

cat("All required data files found.\n")

# Load and start the API
library(plumber)
cat("Loading API definition...\n")
pr <- plumber::pr("api.R")

cat(sprintf("Starting API server on %s:%d...\n", api_host, api_port))
pr$run(host = api_host, port = api_port)
