# Emission Data Utilities
# Functions untuk membaca dan memproses data emisi gas rumah kaca

#' Get available emission data types
#' @return List of emission data types with display names and file paths
get_emission_data_types <- function() {
    data_dir <- Sys.getenv("DATA_DIR", "../data")
    
    list(
        "CH4" = list(
            name = "Nilai emisi CH4 per tahun",
            file_path = file.path(data_dir, "CH4-excluding-LULUCF", "data_ch4.csv"),
            indicator = "Methane (CH4) emissions (total) excluding LULUCF (Mt CO2e)"
        ),
        "CO2" = list(
            name = "Nilai emisi CO2 per tahun", 
            file_path = file.path(data_dir, "CO2-excluding-LULUCF", "data_co2.csv"),
            indicator = "Carbon dioxide (CO2) emissions (total) excluding LULUCF (Mt CO2e)"
        ),
        "N2O" = list(
            name = "Nilai emisi N2O per tahun",
            file_path = file.path(data_dir, "N2O-excluding-LULUCF", "data_n2o.csv"), 
            indicator = "Nitrous oxide (N2O) emissions (total) excluding LULUCF (Mt CO2e)"
        ),
        "TOTAL" = list(
            name = "Nilai total emisi gas rumah kaca per tahun",
            file_path = file.path(data_dir, "TOTAL-Greenhouse-Gases", "data_total_greenhouse.csv"),
            indicator = "Total greenhouse gas emissions excluding LULUCF (Mt CO2e)"
        )
    )
}

#' Read emission data from CSV file
#' @param data_type Type of emission data (CH4, CO2, N2O, TOTAL)
#' @return Data frame with emission data
read_emission_data <- function(data_type) {
    data_types <- get_emission_data_types()
    
    if (!data_type %in% names(data_types)) {
        stop(paste("Tipe data tidak valid:", data_type))
    }
    
    file_path <- data_types[[data_type]]$file_path
    
    if (!file.exists(file_path)) {
        stop(paste("File data tidak ditemukan:", file_path))
    }
    
    tryCatch({
        data <- read.csv(file_path, stringsAsFactors = FALSE, check.names = FALSE)
        return(data)
    }, error = function(e) {
        stop(paste("Error membaca file:", e$message))
    })
}

#' Get available countries from emission data
#' @param data_type Type of emission data
#' @return Vector of country names
get_available_countries <- function(data_type) {
    data <- read_emission_data(data_type)
    
    # Handle different column naming conventions
    # CH4 uses "Country Name", while CO2 and TOTAL use "Country.Name"
    if ("Country Name" %in% colnames(data)) {
        countries <- data$`Country Name`
    } else if ("Country.Name" %in% colnames(data)) {
        countries <- data$`Country.Name`
    } else {
        # Fallback to first column which should be the country column
        countries <- data[[1]]
    }
    
    # Remove common regional aggregates, income classifications, and other non-country entities
    exclude_patterns <- c(
        "World", "Income", "Africa", "Asia", "Europe", "America", "Middle East",
        "Sub-Saharan", "North America", "Latin America", "Caribbean", "Pacific",
        "Arab World", "European Union", "OECD", "Fragile", "Least developed",
        "Small states", "Other small states", "Heavily indebted", "IDA", "IBRD",
        "demographic dividend", "Early-demographic", "Late-demographic", 
        "Pre-demographic", "Post-demographic", "High income", "Low income",
        "Lower middle income", "Upper middle income", "Middle income",
        "Low & middle income", "East Asia", "Central Asia", "island small",
        "Euro area", "Not classified"
    )
    
    # Filter out countries that match exclude patterns
    for (pattern in exclude_patterns) {
        countries <- countries[!grepl(pattern, countries, ignore.case = TRUE)]
    }
    
    # Sort alphabetically
    countries <- sort(countries)
    
    return(countries)
}

#' Get available years from emission data for a specific country
#' @param data_type Type of emission data
#' @param country Country name
#' @return Vector of available years with valid data for the country
get_available_years_for_country <- function(data_type, country) {
    data <- read_emission_data(data_type)
    
    # Handle different column naming conventions
    if ("Country Name" %in% colnames(data)) {
        country_row <- data[data$`Country Name` == country, ]
    } else if ("Country.Name" %in% colnames(data)) {
        country_row <- data[data$`Country.Name` == country, ]
    } else {
        # Fallback to first column
        country_row <- data[data[[1]] == country, ]
    }
    
    if (nrow(country_row) == 0) {
        return(numeric(0))
    }
    
    # Get year columns (exclude non-year columns)
    year_cols <- colnames(data)[5:ncol(data)]  # Years start from column 5
    
    # Check which years have valid data for this country
    valid_years <- c()
    for (year_col in year_cols) {
        year_value <- as.numeric(year_col)
        
        # Skip if not a valid year
        if (is.na(year_value)) next
        
        # Check if the country has data for this year
        country_value <- country_row[[year_col]]
        
        # Include year if value is not NA, not empty, and not "NA"
        if (!is.na(country_value) && country_value != "" && country_value != "NA") {
            valid_years <- c(valid_years, year_value)
        }
    }
    
    # Sort years
    valid_years <- sort(valid_years)
    
    return(valid_years)
}

#' Get available years from emission data
#' @param data_type Type of emission data
#' @param descending Whether to return years in descending order (newest first)
#' @return Vector of available years that have actual data
get_available_years <- function(data_type, descending = FALSE) {
    data <- read_emission_data(data_type)
    
    # Get year columns (exclude non-year columns)
    year_cols <- colnames(data)[5:ncol(data)]  # Years start from column 5
    
    valid_years <- c()
    
    # Check each year column to see if it has actual data
    for (year_col in year_cols) {
        year_value <- as.numeric(year_col)
        
        # Skip if not a valid year
        if (is.na(year_value)) next
        
        # Check if this year has data for any countries
        col_data <- data[[year_col]]
        non_empty_count <- sum(!is.na(col_data) & col_data != "" & col_data != "NA")
        
        # Only include years that have data for at least some countries
        if (non_empty_count > 0) {
            valid_years <- c(valid_years, year_value)
        }
    }
    
    # Sort years (ascending or descending)
    valid_years <- if (descending) sort(valid_years, decreasing = TRUE) else sort(valid_years)
    
    return(valid_years)
}

#' Get emission data for specific country and years
#' @param data_type Type of emission data
#' @param country Country name
#' @param years Vector of years to extract
#' @return List with emission values for each year
get_country_emission_data <- function(data_type, country, years) {
    data <- read_emission_data(data_type)
    
    # Handle different column naming conventions
    if ("Country Name" %in% colnames(data)) {
        country_row <- data[data$`Country Name` == country, ]
    } else if ("Country.Name" %in% colnames(data)) {
        country_row <- data[data$`Country.Name` == country, ]
    } else {
        # Fallback to first column
        country_row <- data[data[[1]] == country, ]
    }
    
    if (nrow(country_row) == 0) {
        stop(paste("Negara tidak ditemukan:", country))
    }
    
    # Extract emission values for specified years
    emission_values <- list()
    
    for (year in years) {
        year_col <- as.character(year)
        
        if (year_col %in% colnames(data)) {
            value <- country_row[[year_col]]
            
            # Handle missing values
            if (is.na(value) || value == "" || value == "NA") {
                emission_values[[as.character(year)]] <- NA
            } else {
                emission_values[[as.character(year)]] <- as.numeric(value)
            }
        } else {
            emission_values[[as.character(year)]] <- NA
        }
    }
    
    return(emission_values)
}

#' Prepare emission data for statistical analysis - Compare two years globally
#' @param data_type Type of emission data
#' @param year1 First year for comparison
#' @param year2 Second year for comparison
#' @return List with sample1 and sample2 for statistical tests
prepare_emission_samples_by_years <- function(data_type, year1, year2) {
    data <- read_emission_data(data_type)
    
    # Check if the requested years have valid data
    available_years <- get_available_years(data_type)
    if (!year1 %in% available_years) {
        stop(paste("Tahun", year1, "tidak memiliki data yang valid. Tahun yang tersedia:", min(available_years), "-", max(available_years)))
    }
    if (!year2 %in% available_years) {
        stop(paste("Tahun", year2, "tidak memiliki data yang valid. Tahun yang tersedia:", min(available_years), "-", max(available_years)))
    }
    
    # Get all countries (filter out regional aggregates)
    countries <- get_available_countries(data_type)
    
    sample1 <- c()
    sample2 <- c()
    valid_countries <- c()
    
    for (country in countries) {
        # Handle different column naming conventions
        if ("Country Name" %in% colnames(data)) {
            country_row <- data[data$`Country Name` == country, ]
        } else if ("Country.Name" %in% colnames(data)) {
            country_row <- data[data$`Country.Name` == country, ]
        } else {
            # Fallback to first column
            country_row <- data[data[[1]] == country, ]
        }
        
        if (nrow(country_row) > 0) {
            value1 <- country_row[[as.character(year1)]]
            value2 <- country_row[[as.character(year2)]]
            
            # Convert to numeric and check validity
            value1 <- as.numeric(value1)
            value2 <- as.numeric(value2)
            
            # Only include if both values are available and valid
            if (!is.na(value1) && !is.na(value2) && value1 > 0 && value2 > 0) {
                sample1 <- c(sample1, value1)
                sample2 <- c(sample2, value2)
                valid_countries <- c(valid_countries, country)
            }
        }
    }
    
    if (length(sample1) == 0) {
        stop("Tidak ada data yang valid untuk tahun yang dipilih")
    }
    
    return(list(
        sample1 = sample1,
        sample2 = sample2,
        n = length(sample1),
        source = "Emission Data - Year Comparison",
        data_type = data_type,
        year1 = year1,
        year2 = year2,
        countries = valid_countries,
        analysis_type = "year_comparison"
    ))
}

#' Prepare emission data for statistical analysis - Compare two countries across all years
#' @param data_type Type of emission data
#' @param country1 First country name
#' @param country2 Second country name
#' @return List with sample1 and sample2 for statistical tests
prepare_emission_samples_by_two_countries <- function(data_type, country1, country2) {
    data <- read_emission_data(data_type)
    
    # Handle different column naming conventions for both countries
    if ("Country Name" %in% colnames(data)) {
        country1_row <- data[data$`Country Name` == country1, ]
        country2_row <- data[data$`Country Name` == country2, ]
    } else if ("Country.Name" %in% colnames(data)) {
        country1_row <- data[data$`Country.Name` == country1, ]
        country2_row <- data[data$`Country.Name` == country2, ]
    } else {
        # Fallback to first column
        country1_row <- data[data[[1]] == country1, ]
        country2_row <- data[data[[1]] == country2, ]
    }
    
    if (nrow(country1_row) == 0) {
        stop(paste("Negara tidak ditemukan:", country1))
    }
    if (nrow(country2_row) == 0) {
        stop(paste("Negara tidak ditemukan:", country2))
    }
    
    # Get year columns (exclude non-year columns)
    year_cols <- colnames(data)[5:ncol(data)]  # Years start from column 5
    
    sample1 <- c()
    sample2 <- c()
    valid_years <- c()
    
    # Extract data for all available years where both countries have valid data
    for (year_col in year_cols) {
        year_value <- as.numeric(year_col)
        
        # Skip if not a valid year
        if (is.na(year_value)) next
        
        value1 <- country1_row[[year_col]]
        value2 <- country2_row[[year_col]]
        
        # Convert to numeric and check validity
        value1 <- as.numeric(value1)
        value2 <- as.numeric(value2)
        
        # Only include if both values are available and valid
        if (!is.na(value1) && !is.na(value2) && value1 > 0 && value2 > 0) {
            sample1 <- c(sample1, value1)
            sample2 <- c(sample2, value2)
            valid_years <- c(valid_years, year_value)
        }
    }
    
    if (length(sample1) == 0) {
        stop("Tidak ada data yang valid untuk kedua negara yang dipilih")
    }
    
    return(list(
        sample1 = sample1,
        sample2 = sample2,
        n = length(sample1),
        source = "Emission Data - Country Comparison",
        data_type = data_type,
        country1 = country1,
        country2 = country2,
        years = valid_years,
        analysis_type = "country_comparison"
    ))
}

#' Get emission data summary for year comparison
#' @param data_type Type of emission data
#' @param year1 First year
#' @param year2 Second year
#' @param country_count Number of countries with valid data
#' @return Summary text for display
get_emission_summary_years <- function(data_type, year1, year2, country_count) {
    data_types <- get_emission_data_types()
    type_name <- data_types[[data_type]]$name
    
    paste0(
        "🌍 Jenis Data: ", type_name, "\n",
        "📊 Analisis: Perbandingan Dua Tahun (Global)\n",
        "📅 Tahun 1: ", year1, "\n",
        "📅 Tahun 2: ", year2, "\n",
        "🏛️ Jumlah Negara: ", country_count, " negara"
    )
}

#' Get emission data summary for country comparison
#' @param data_type Type of emission data
#' @param country1 First country name
#' @param country2 Second country name
#' @param year_count Number of years with valid data
#' @return Summary text for display
get_emission_summary_countries <- function(data_type, country1, country2, year_count) {
    data_types <- get_emission_data_types()
    type_name <- data_types[[data_type]]$name
    
    paste0(
        "🌍 Jenis Data: ", type_name, "\n",
        "📊 Analisis: Perbandingan Dua Negara\n",
        "🏛️ Negara 1: ", country1, "\n",
        "🏛️ Negara 2: ", country2, "\n",
        "📅 Jumlah Tahun: ", year_count, " tahun"
    )
}
