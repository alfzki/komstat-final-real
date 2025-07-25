# Results Panel Module
# Shiny module untuk panel hasil analisis

# Module UI function
results_panel_ui <- function(id) {
    ns <- NS(id)

    tagList(
        # Results panel with bslib card
        conditionalPanel(
            condition = paste0("output['", ns("show_results"), "'] == true"),
            bslib::card(
                bslib::card_header("📈 Hasil Analisis"),
                bslib::card_body(
                    verbatimTextOutput(ns("summary")),
                    hr(),
                    h4("📊 Visualisasi"),
                    fluidRow(
                        column(6, plotOutput(ns("main_plot"), height = "300px")),
                        column(6, plotOutput(ns("diff_plot"), height = "300px"))
                    )
                )
            )
        ),

        # Placeholder when no results
        conditionalPanel(
            condition = paste0("output['", ns("show_results"), "'] != true"),
            create_results_placeholder()
        )
    )
}

# Module server function
results_panel_server <- function(id, input_data, test_type, alpha, run_trigger) {
    moduleServer(id, function(input, output, session) {
        # Reactive values for results
        values <- reactiveValues(
            results = NULL,
            show_results = FALSE
        )

        # Run test when trigger is activated
        observeEvent(run_trigger(), {
            data <- input_data()

            if (is.null(data)) {
                show_data_required_notification()
                return()
            }

            tryCatch(
                {
                    # Perform the selected test
                    if (test_type() == "sign") {
                        results <- perform_sign_test(data$sample1, data$sample2, alpha())
                    } else if (test_type() == "wilcoxon") {
                        results <- perform_wilcoxon_test(data$sample1, data$sample2, alpha())
                    } else if (test_type() == "run") {
                        results <- perform_run_test(data$sample1, data$sample2, alpha())
                    } else if (test_type() == "mannwhitney") {
                        results <- perform_mannwhitney_test(data$sample1, data$sample2, alpha())
                    }

                    values$results <- results
                    values$show_results <- TRUE
                    show_analysis_complete_notification()
                },
                error = function(e) {
                    show_error_notification(paste("Error analisis:", e$message))
                }
            )
        })

        # Show results output
        output$show_results <- reactive({
            values$show_results
        })
        outputOptions(output, "show_results", suspendWhenHidden = FALSE)

        # Summary output
        output$summary <- renderPrint({
            req(values$results)
            render_test_summary(values$results)
        })

        # Main plot output
        output$main_plot <- renderPlot({
            req(values$results)
            create_main_plot(values$results)
        })

        # Difference plot output
        output$diff_plot <- renderPlot({
            req(values$results)
            create_difference_plot(values$results)
        })
    })
}
