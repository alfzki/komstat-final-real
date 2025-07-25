# Input Panel Module
# Shiny module untuk panel input data

# Module UI function
input_panel_ui <- function(id) {
    ns <- NS(id)

    bslib::card(
        bslib::card_header("Kontrol Input & Analisis"),
        bslib::card_body(

            # Test selection
            create_test_selection(ns("test_type"), "sign"),
            hr(),

            # Emission data selection section
            create_emission_data_section(
                ns("emission_data_type"),
                ns("emission_analysis_type"),
                ns("emission_country1"),
                ns("emission_country2"),
                ns("emission_year1"),
                ns("emission_year2"),
                ns("use_emission_data")
            ),

            # Data info display for emission data
            conditionalPanel(
                condition = paste0("output['", ns("show_emission_info"), "']"),
                div(
                    h6("🌍 Data Emisi yang akan diproses:"),
                    verbatimTextOutput(ns("emission_data_info")),
                    style = get_info_box_style("data-info-box")
                )
            ),

            # File upload section
            conditionalPanel(
                condition = paste0("!input['", ns("use_emission_data"), "']"),
                create_file_upload_section(
                    ns("file_csv"),
                    ns("clear_file"),
                    ns("download_template"),
                    ns("file_status")
                )
            ),

            # Data info display (only show when CSV is loaded)
            conditionalPanel(
                condition = paste0("output['", ns("show_csv_info"), "'] && !input['", ns("use_emission_data"), "']"),
                div(
                    h6("📊 Data yang akan diproses:"),
                    verbatimTextOutput(ns("data_info")),
                    style = get_info_box_style("data-info-box")
                )
            ),

            # Manual input section
            conditionalPanel(
                condition = paste0("!input['", ns("use_emission_data"), "']"),
                create_manual_input_section(
                    ns("use_manual"),
                    ns("sample1"),
                    ns("sample2"),
                    ns("test_type")
                )
            ),

            # Alpha input
            numericInput(ns("alpha"), "Tingkat Signifikansi (α):",
                value = 0.05, min = 0.01, max = 0.1, step = 0.01
            ),
            br(),

            # Run test button
            actionButton(ns("run_test"), "🚀 Jalankan Uji",
                class = "btn btn-primary btn-block btn-lg"
            )
        )
    )
}

# Module server function
input_panel_server <- function(id, parent_session) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        # Reactive values for module state
        values <- reactiveValues(
            current_data = NULL,
            file_cleared = FALSE,
            force_manual = FALSE,
            emission_data = NULL,
            emission_utils_loaded = FALSE
        )

        # Load emission data utilities with proper error handling
        tryCatch(
            {
                source("utils/emission_utils.R", local = TRUE)
                values$emission_utils_loaded <- TRUE
            },
            error = function(e) {
                show_error_notification(paste("Error loading emission utilities:", e$message))
                values$emission_utils_loaded <- FALSE
            }
        )

        # Update countries and years when data type or analysis type changes
        observeEvent(list(input$emission_data_type, input$emission_analysis_type),
            {
                # Require that emission utilities are loaded
                req(values$emission_utils_loaded)

                if (input$emission_data_type != "") {
                    # Get analysis type (default to year_comparison if not set)
                    analysis_type <- if (is.null(input$emission_analysis_type) || input$emission_analysis_type == "") {
                        "year_comparison"
                    } else {
                        input$emission_analysis_type
                    }

                    if (analysis_type == "year_comparison") {
                        # Load years for year comparison
                        tryCatch(
                            {
                                # Get years in descending order (newest first)
                                years <- get_available_years(input$emission_data_type, descending = TRUE)
                                year_choices <- setNames(years, years)

                                # Update year dropdowns with no default selection
                                updateSelectInput(session, "emission_year1",
                                    choices = year_choices,
                                    selected = NULL
                                )
                                updateSelectInput(session, "emission_year2",
                                    choices = year_choices,
                                    selected = NULL
                                )
                            },
                            error = function(e) {
                                show_error_notification(paste("Error loading years:", e$message))
                                # Reset years dropdown on error
                                updateSelectInput(session, "emission_year1",
                                    choices = c(),
                                    selected = NULL
                                )
                                updateSelectInput(session, "emission_year2",
                                    choices = c(),
                                    selected = NULL
                                )
                            }
                        )

                        # Reset country dropdowns for year comparison mode
                        updateSelectInput(session, "emission_country1",
                            choices = c(),
                            selected = NULL
                        )
                        updateSelectInput(session, "emission_country2",
                            choices = c(),
                            selected = NULL
                        )
                    } else if (analysis_type == "country_comparison") {
                        # Load countries for country comparison
                        tryCatch(
                            {
                                countries <- get_available_countries(input$emission_data_type)

                                updateSelectInput(session, "emission_country1",
                                    choices = countries,
                                    selected = NULL
                                )
                                updateSelectInput(session, "emission_country2",
                                    choices = countries,
                                    selected = NULL
                                )
                            },
                            error = function(e) {
                                show_error_notification(paste("Error loading countries:", e$message))
                                # Reset countries dropdown on error
                                updateSelectInput(session, "emission_country1",
                                    choices = c(),
                                    selected = NULL
                                )
                                updateSelectInput(session, "emission_country2",
                                    choices = c(),
                                    selected = NULL
                                )
                            }
                        )

                        # Reset year dropdowns for country comparison mode
                        updateSelectInput(session, "emission_year1",
                            choices = c(),
                            selected = NULL
                        )
                        updateSelectInput(session, "emission_year2",
                            choices = c(),
                            selected = NULL
                        )
                    }
                } else {
                    # Reset all dropdowns when no data type selected
                    updateSelectInput(session, "emission_country1",
                        choices = c(),
                        selected = NULL
                    )
                    updateSelectInput(session, "emission_country2",
                        choices = c(),
                        selected = NULL
                    )
                    updateSelectInput(session, "emission_year1",
                        choices = c(),
                        selected = NULL
                    )
                    updateSelectInput(session, "emission_year2",
                        choices = c(),
                        selected = NULL
                    )
                }
            },
            ignoreInit = TRUE
        )

        # Reset dropdowns when emission checkbox is unchecked
        observeEvent(input$use_emission_data,
            {
                if (!input$use_emission_data) {
                    # Reset all emission-related dropdowns when checkbox unchecked
                    updateSelectInput(session, "emission_data_type", selected = NULL)
                    updateSelectInput(session, "emission_country1",
                        choices = c(),
                        selected = NULL
                    )
                    updateSelectInput(session, "emission_country2",
                        choices = c(),
                        selected = NULL
                    )
                    updateSelectInput(session, "emission_year1",
                        choices = c(),
                        selected = NULL
                    )
                    updateSelectInput(session, "emission_year2",
                        choices = c(),
                        selected = NULL
                    )
                }
            },
            ignoreInit = TRUE
        )

        # Get emission data reactive
        get_emission_data <- reactive({
            if (input$use_emission_data && input$emission_data_type != "") {
                if (input$emission_analysis_type == "year_comparison") {
                    # Year comparison mode
                    if (input$emission_year1 != "" && input$emission_year2 != "" &&
                        input$emission_year1 != input$emission_year2) {
                        tryCatch(
                            {
                                emission_data <- prepare_emission_samples_by_years(
                                    input$emission_data_type,
                                    as.numeric(input$emission_year1),
                                    as.numeric(input$emission_year2)
                                )
                                return(emission_data)
                            },
                            error = function(e) {
                                show_error_notification(paste("Error preparing emission data:", e$message))
                                return(NULL)
                            }
                        )
                    }
                } else if (input$emission_analysis_type == "country_comparison") {
                    # Country comparison mode
                    if (!is.null(input$emission_country1) &&
                        !is.null(input$emission_country2) &&
                        input$emission_country1 != "" &&
                        input$emission_country2 != "" &&
                        input$emission_country1 != input$emission_country2) {
                        tryCatch(
                            {
                                emission_data <- prepare_emission_samples_by_two_countries(
                                    input$emission_data_type,
                                    input$emission_country1,
                                    input$emission_country2
                                )
                                return(emission_data)
                            },
                            error = function(e) {
                                show_error_notification(paste("Error preparing emission data:", e$message))
                                return(NULL)
                            }
                        )
                    }
                }
            }
            return(NULL)
        })

        # Update emission data values
        observe({
            emission_data <- get_emission_data()
            values$emission_data <- emission_data
        })

        # Show emission info indicator
        output$show_emission_info <- reactive({
            !is.null(values$emission_data) && input$use_emission_data
        })
        outputOptions(output, "show_emission_info", suspendWhenHidden = FALSE)

        # Emission data info output
        output$emission_data_info <- renderText({
            if (!is.null(values$emission_data)) {
                if (values$emission_data$analysis_type == "year_comparison") {
                    get_emission_summary_years(
                        values$emission_data$data_type,
                        values$emission_data$year1,
                        values$emission_data$year2,
                        length(values$emission_data$countries)
                    )
                } else if (values$emission_data$analysis_type == "country_comparison") {
                    get_emission_summary_countries(
                        values$emission_data$data_type,
                        values$emission_data$country1,
                        values$emission_data$country2,
                        length(values$emission_data$years)
                    )
                }
            } else {
                ""
            }
        })

        # File status output
        output$file_status <- renderText({
            if (!is.null(input$file_csv) && !values$file_cleared && !values$force_manual && !input$use_emission_data) {
                input$file_csv$name
            } else {
                ""
            }
        })

        # Clear file functionality
        observeEvent(input$clear_file, {
            reset("file_csv")
            values$file_cleared <- TRUE
            values$force_manual <- FALSE
            show_file_cleared_notification()
        })

        # Use manual mode
        observeEvent(input$use_manual, {
            reset("file_csv")
            values$file_cleared <- TRUE
            values$force_manual <- TRUE
            show_manual_mode_notification()
        })

        # Download template handlers
        output$download_template <- downloadHandler(
            filename = function() {
                paste0("template-uji-nonparametrik-", Sys.Date(), ".csv")
            },
            content = function(file) {
                template_lines <- generate_csv_template()
                writeLines(template_lines, file)
            }
        )

        # Excel template download
        output$download_excel_template <- downloadHandler(
            filename = function() {
                paste0("template-uji-nonparametrik-", Sys.Date(), ".xlsx")
            },
            content = function(file) {
                # Check required packages
                if (!check_and_load_packages(c("readxl", "writexl"))) {
                    stop("Gagal memuat packages readxl dan writexl yang diperlukan")
                }

                # Create a data frame with the template data
                template_df <- data.frame(
                    Sebelum = c(78, 82, 85, 79, 88, 76, 84, 87, 81, 89),
                    Sesudah = c(75, 79, 82, 76, 85, 73, 81, 84, 78, 86)
                )

                # Write the data frame to the file
                writexl::write_xlsx(template_df, file)
            }
        )

        # SPSS template download
        output$download_spss_template <- downloadHandler(
            filename = function() {
                paste0("template-uji-nonparametrik-", Sys.Date(), ".sav")
            },
            content = function(file) {
                # Check required packages
                if (!check_and_load_packages("haven")) {
                    stop("Gagal memuat package haven yang diperlukan")
                }

                # Create a data frame with the template data
                template_df <- data.frame(
                    Sebelum = c(78, 82, 85, 79, 88, 76, 84, 87, 81, 89),
                    Sesudah = c(75, 79, 82, 76, 85, 73, 81, 84, 78, 86)
                )

                # Write the data frame to the file
                haven::write_sav(template_df, file)
            }
        )

        # Get data reactive
        get_data <- reactive({
            # Priority 1: Emission data
            if (input$use_emission_data && !is.null(values$emission_data)) {
                return(values$emission_data)
            }

            # Priority 2: CSV file
            use_csv <- !is.null(input$file_csv) &&
                !is.null(input$file_csv$datapath) &&
                !values$file_cleared &&
                !values$force_manual &&
                !input$use_emission_data

            if (use_csv) {
                tryCatch(
                    {
                        # Get the file extension to determine which reader to use
                        file_path <- input$file_csv$datapath
                        file_data <- read_data_file(file_path)

                        file_source <- file_data$source
                        show_file_success_notification(paste("File", file_source, "berhasil dibaca:"), file_data$n)

                        return(list(
                            sample1 = file_data$sample1,
                            sample2 = file_data$sample2,
                            source = file_source
                        ))
                    },
                    error = function(e) {
                        show_error_notification(paste("Error membaca file:", e$message))
                        return(NULL)
                    }
                )
            }

            # Priority 3: Manual input
            if (!input$use_emission_data) {
                sample1_text <- input$sample1
                sample2_text <- input$sample2

                if (!is.null(sample1_text) && !is.null(sample2_text) &&
                    nchar(trimws(sample1_text)) > 0 && nchar(trimws(sample2_text)) > 0) {
                    tryCatch(
                        {
                            result <- parse_manual_samples(sample1_text, sample2_text)
                            return(result)
                        },
                        error = function(e) {
                            show_error_notification(paste("Error input manual:", e$message))
                            return(NULL)
                        }
                    )
                }
            }

            return(NULL)
        })

        # Update current data
        observe({
            data <- get_data()
            values$current_data <- data
        })

        # Update text inputs when CSV data is loaded
        observe({
            if (!is.null(values$current_data) && values$current_data$source == "CSV") {
                # Convert numeric vectors to comma-separated strings
                sample1_text <- paste(values$current_data$sample1, collapse = ",")
                sample2_text <- paste(values$current_data$sample2, collapse = ",")

                # Update the text inputs
                updateTextInput(session, "sample1", value = sample1_text)
                updateTextInput(session, "sample2", value = sample2_text)
            }
        })

        # Reset file_cleared when new file uploaded
        observe({
            if (!is.null(input$file_csv)) {
                values$file_cleared <- FALSE
                values$force_manual <- FALSE
            }
        })

        # Show CSV info indicator
        output$show_csv_info <- reactive({
            !is.null(values$current_data) &&
                values$current_data$source == "CSV" &&
                !values$force_manual
        })
        outputOptions(output, "show_csv_info", suspendWhenHidden = FALSE)

        # Data info output
        output$data_info <- renderText({
            if (!is.null(values$current_data)) {
                source_icon <- ifelse(values$current_data$source == "CSV", "📁", "✏️")
                paste(
                    source_icon, "Sumber:", values$current_data$source, "\n",
                    "📊 Jumlah data:", length(values$current_data$sample1), "pasang\n",
                    "🔢 Sampel 1:", paste(head(values$current_data$sample1, 5), collapse = ", "),
                    ifelse(length(values$current_data$sample1) > 5, "...", ""), "\n",
                    "🔢 Sampel 2:", paste(head(values$current_data$sample2, 5), collapse = ", "),
                    ifelse(length(values$current_data$sample2) > 5, "...", "")
                )
            } else {
                ""
            }
        })

        # Return reactive values and inputs for parent
        return(list(
            data = get_data,
            test_type = reactive(input$test_type),
            alpha = reactive(input$alpha),
            run_test_trigger = reactive(input$run_test)
        ))
    })
}
