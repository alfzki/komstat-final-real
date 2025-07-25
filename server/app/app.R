# Modular Shiny App for Non-Parametric Statistical Tests
# Main app entry point

# Load required libraries
library(shiny)
library(shinyjs)
library(bslib)

# Optional packages for file formats - will be installed on demand if needed
required_packages <- c("readxl", "writexl", "haven")
for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        message("Package '", pkg, "' is not installed.")
    }
}

# Source utility functions
source("utils/stat_tests.R")
source("utils/csv_utils.R")
source("utils/plot_utils.R")
source("utils/ui_helpers.R")
source("utils/notification_helpers.R")
source("utils/emission_utils.R")

# Source Shiny modules
source("modules/input_panel_module.R")
source("modules/results_panel_module.R")

# Define UI
ui <- fluidPage(
    # Enable bslib Material UI theme with enhanced Material Design tokens
    theme = bs_theme(
        version = 5,
        base_font = font_google("Roboto", local = FALSE),
        heading_font = font_google("Roboto", wght = c(300, 400, 500), local = FALSE),
        code_font = font_google("Roboto Mono", local = FALSE),
        # Material Design color system
        bg = "#fafafa", # Material surface
        fg = "#212121", # Material on-surface
        primary = "#1976d2", # Material blue 700
        secondary = "#424242", # Material grey 800
        success = "#388e3c", # Material green 700
        info = "#0288d1", # Material light blue 700
        warning = "#f57c00", # Material orange 700
        danger = "#d32f2f", # Material red 700
        # Enhanced card styling with Material Design elevation
        card_border_width = 0,
        card_border_radius = "0.5rem", # 8dp
        card_shadow = "0 2px 1px -1px rgba(0,0,0,.2), 0 1px 1px 0 rgba(0,0,0,.14), 0 1px 3px 0 rgba(0,0,0,.12)"
    ),

    # Enable shinyjs
    useShinyjs(),

    # App title and custom CSS for depth
    tags$head(
        tags$title("Analisis Emisi Gas Rumah Kaca Global"),

        # Enhanced CSS for Material UI styling and dark mode
        tags$style(HTML("
            /* Material Design Typography Scale */
            body {
                font-family: 'Roboto', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                font-weight: 400;
                line-height: 1.5;
                letter-spacing: 0.00938em;
            }

            h1, .h1 { font-size: 2.125rem; font-weight: 300; line-height: 1.235; letter-spacing: -0.00833em; }
            h2, .h2 { font-size: 1.5rem; font-weight: 400; line-height: 1.334; letter-spacing: 0em; }
            h3, .h3 { font-size: 1.25rem; font-weight: 400; line-height: 1.6; letter-spacing: 0.0075em; }
            h4, .h4 { font-size: 1.125rem; font-weight: 400; line-height: 1.5; letter-spacing: 0.00714em; }

            /* Material UI App Bar */
            .navbar, .app-bar {
                background: linear-gradient(135deg, #1976d2 0%, #1565c0 100%);
                color: white;
                padding: 16px 24px;
                margin-bottom: 24px;
                box-shadow: 0 2px 4px -1px rgba(0,0,0,.2), 0 4px 5px 0 rgba(0,0,0,.14), 0 1px 10px 0 rgba(0,0,0,.12);
                border-radius: 0;
            }

            /* Enhanced Material UI buttons */
            .btn {
                height: 36px;
                min-width: 64px;
                padding: 6px 16px;
                border-radius: 4px;
                font-size: 0.875rem;
                font-weight: 500;
                line-height: 1.75;
                letter-spacing: 0.02857em;
                text-transform: uppercase;
                border: none;
                cursor: pointer;
                outline: none;
                position: relative;
                overflow: hidden;
                transition: background-color 250ms cubic-bezier(0.4, 0, 0.2, 1) 0ms,
                           box-shadow 250ms cubic-bezier(0.4, 0, 0.2, 1) 0ms;
            }

            .btn:hover {
                box-shadow: 0 2px 4px -1px rgba(0,0,0,.2), 0 4px 5px 0 rgba(0,0,0,.14), 0 1px 10px 0 rgba(0,0,0,.12);
            }

            .btn:active {
                box-shadow: 0 5px 5px -3px rgba(0,0,0,.2), 0 8px 10px 1px rgba(0,0,0,.14), 0 3px 14px 2px rgba(0,0,0,.12);
            }

            .btn-primary {
                background-color: #1976d2;
                color: #fff;
                box-shadow: 0 3px 1px -2px rgba(0,0,0,.2), 0 2px 2px 0 rgba(0,0,0,.14), 0 1px 5px 0 rgba(0,0,0,.12);
            }

            .btn-primary:hover {
                background-color: #1565c0;
            }

            /* Material UI Form Controls */
            .form-control, .form-select {
                height: 56px;
                padding: 16px 12px 8px;
                border: 1px solid rgba(0, 0, 0, 0.23);
                border-radius: 4px;
                background: transparent;
                font-size: 1rem;
                line-height: 1.5;
                transition: border-color 200ms cubic-bezier(0.0, 0, 0.2, 1) 0ms,
                           box-shadow 200ms cubic-bezier(0.0, 0, 0.2, 1) 0ms;
            }

            .form-control:focus, .form-select:focus {
                border-color: #1976d2;
                border-width: 2px;
                box-shadow: none;
                outline: none;
            }

            .form-control:hover:not(:focus), .form-select:hover:not(:focus) {
                border-color: rgba(0, 0, 0, 0.87);
            }

            /* Form Labels */
            .control-label {
                font-size: 0.75rem;
                font-weight: 400;
                line-height: 1.66;
                letter-spacing: 0.03333em;
                color: rgba(0, 0, 0, 0.6);
                margin-bottom: 8px;
                display: block;
            }

            /* File input styling with depth and consistent sizing */
            .file-input-container .form-control-file {
                height: 56px;
                padding: 16px 12px;
                border: 1px solid rgba(0, 0, 0, 0.23);
                border-radius: 4px;
                background: transparent;
                font-size: 1rem;
                line-height: 1.5;
                transition: border-color 200ms cubic-bezier(0.0, 0, 0.2, 1) 0ms,
                           box-shadow 200ms cubic-bezier(0.0, 0, 0.2, 1) 0ms;
                display: flex;
                align-items: center;
            }

            .file-input-container .form-control-file:focus {
                border-color: #1976d2;
                border-width: 2px;
                box-shadow: none;
                outline: none;
            }

            .file-input-container .form-control-file:hover:not(:focus) {
                border-color: rgba(0, 0, 0, 0.87);
            }

            /* Ensure file input components have consistent heights */
            .file-input-container .input-group .form-control,
            .file-input-container .input-group .btn {
                height: 48px !important;
                border-radius: 4px;
                font-size: 0.875rem;
            }

            /* File input browse button styling */
            .file-input-container .btn-outline-secondary {
                background-color: #f5f5f5;
                border-color: rgba(0, 0, 0, 0.23);
                color: rgba(0, 0, 0, 0.87);
                height: 48px;
                padding: 12px 16px;
                transition: all 200ms cubic-bezier(0.0, 0, 0.2, 1) 0ms;
            }

            .file-input-container .btn-outline-secondary:hover {
                background-color: #eeeeee;
                border-color: rgba(0, 0, 0, 0.87);
                color: rgba(0, 0, 0, 0.87);
            }

            /* File input text field styling */
            .file-input-container .form-control {
                height: 48px !important;
                padding: 12px 16px;
                background-color: #fafafa;
                border-color: rgba(0, 0, 0, 0.23);
                color: rgba(0, 0, 0, 0.6);
                font-size: 0.875rem;
            }

            /* Button text truncation fix */
            .btn-sm {
                font-size: 0.8125rem !important;
                padding: 8px 12px !important;
                min-height: 36px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                line-height: 1.2;
            }

            /* Ensure download button text is fully visible */
            @media (max-width: 768px) {
                .btn-sm {
                    font-size: 0.75rem !important;
                    padding: 6px 8px !important;
                }
            }

            /* Radio button and checkbox enhancements */
            .form-check-input {
                box-shadow: 0 1px 2px rgba(0,0,0,0.1);
                border: 2px solid #dee2e6;
                transition: all 0.2s ease;
            }

            .form-check-input:checked {
                background-color: #2196F3;
                border-color: #2196F3;
                box-shadow: 0 2px 4px rgba(33, 150, 243, 0.3);
            }

            /* Enhanced card depth */
            .card {
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            }

            .card:hover {
                box-shadow: 0 4px 8px rgba(0,0,0,0.15), 0 8px 16px rgba(0,0,0,0.1) !important;
                transform: translateY(-1px);
            }

            /* Textarea depth */
            textarea.form-control {
                background: linear-gradient(to bottom, #ffffff 0%, #fafafa 100%);
                resize: vertical;
            }

            textarea.form-control:focus {
                background: #ffffff;
            }

            /* Select dropdown depth */
            select.form-select {
                background-image: linear-gradient(45deg, transparent 50%, #6c757d 50%),
                                 linear-gradient(135deg, #6c757d 50%, transparent 50%);
                background-position: calc(100% - 20px) calc(1em + 2px), calc(100% - 15px) calc(1em + 2px);
                background-size: 5px 5px, 5px 5px;
                background-repeat: no-repeat;
            }

            /* Material UI Snackbar/Notification System */
            .shiny-notification {
                background-color: #323232;
                color: #fff;
                border-radius: 4px;
                padding: 14px 16px;
                margin: 8px;
                box-shadow: 0 3px 5px -1px rgba(0,0,0,.2), 0 6px 10px 0 rgba(0,0,0,.14), 0 1px 18px 0 rgba(0,0,0,.12);
                font-size: 0.875rem;
                line-height: 1.43;
                letter-spacing: 0.01071em;
                min-width: 288px;
                max-width: 568px;
            }

            .shiny-notification-error {
                background-color: #d32f2f;
            }

            .shiny-notification-warning {
                background-color: #f57c00;
            }

            .shiny-notification-message {
                background-color: #1976d2;
            }

            /* Material UI Progress Indicators */
            .progress {
                height: 4px;
                border-radius: 2px;
                background-color: rgba(25, 118, 210, 0.12);
                overflow: hidden;
            }

            .progress-bar {
                background-color: #1976d2;
                height: 100%;
                transition: width 250ms cubic-bezier(0.4, 0, 0.2, 1) 0ms;
            }

            /* Loading Spinner */
            .loading-spinner {
                border: 3px solid rgba(25, 118, 210, 0.3);
                border-top: 3px solid #1976d2;
                border-radius: 50%;
                width: 24px;
                height: 24px;
                animation: spin 1s linear infinite;
                display: inline-block;
                margin-right: 8px;
            }

            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }

            /* Enhanced Accessibility */
            .sr-only {
                position: absolute;
                width: 1px;
                height: 1px;
                padding: 0;
                margin: -1px;
                overflow: hidden;
                clip: rect(0, 0, 0, 0);
                white-space: nowrap;
                border: 0;
            }

            /* Focus management */
            .btn:focus,
            .form-control:focus,
            .form-select:focus,
            .form-check-input:focus {
                outline: 2px solid #1976d2;
                outline-offset: 2px;
            }

            /* Material UI Helper Text */
            .form-text {
                font-size: 0.75rem;
                line-height: 1.66;
                letter-spacing: 0.03333em;
                color: rgba(0, 0, 0, 0.6);
                margin-top: 3px;
            }

            .form-text.text-danger {
                color: #d32f2f;
            }

            /* Material UI Dividers */
            hr {
                border: none;
                height: 1px;
                background-color: rgba(0, 0, 0, 0.12);
                margin: 24px 0;
            }

            /* Better Mobile Responsiveness */
            @media (max-width: 576px) {
                .container-fluid { padding: 8px; }
                .card-body { padding: 16px; }
                .app-bar { padding: 12px 16px; margin-bottom: 16px; }
                .app-bar h1 { font-size: 1.125rem; }
                .btn { min-width: 48px; height: 32px; padding: 4px 12px; font-size: 0.8125rem; }
                .form-control, .form-select { height: 48px; padding: 12px 8px 4px; }
            }

            /* Print Styles */
            @media print {
                .app-bar, .sidebar { display: none; }
                .main-content { width: 100%; padding: 0; }
                .card { box-shadow: none; border: 1px solid rgba(0, 0, 0, 0.12); }
            }

            /* Reset and base styles */
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Roboto', 'Helvetica', 'Arial', sans-serif;
                line-height: 1.6;
                transition: background-color 0.3s ease, color 0.3s ease;
                background-color: #ffffff;
                color: #212529;
            }

            /* App bar styling */
            .app-bar {
                background: linear-gradient(135deg, #1976d2 0%, #1565c0 100%);
                color: white;
                padding: 16px 24px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 24px;
                border-radius: 0;
                position: sticky;
                top: 0;
                z-index: 1000;
            }

            .app-bar h1 {
                font-size: 1.5rem;
                font-weight: 500;
                margin: 0;
                display: flex;
                align-items: center;
                gap: 12px;
            }

            /* Layout improvements */
            .container-fluid {
                max-width: 1400px;
                margin: 0 auto;
                padding: 0 20px;
            }

            .sidebar {
                background: #f8f9fa;
                border-radius: 8px;
                padding: 20px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                margin-bottom: 20px;
                height: fit-content;
                position: sticky;
                top: 120px;
            }

            .main-content {
                background: #ffffff;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                min-height: 600px;
                padding: 24px;
            }

            /* Card styling */
            .card {
                background: #ffffff;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                border: 1px solid rgba(0, 0, 0, 0.06);
                margin-bottom: 20px;
                overflow: hidden;
                transition: box-shadow 0.3s ease;
            }

            .card:hover {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            }

            .card-header {
                background: #f8f9fa;
                padding: 16px 20px;
                border-bottom: 1px solid rgba(0, 0, 0, 0.06);
                font-weight: 500;
            }

            .card-body {
                padding: 20px;
            }

            /* Form styling */
            .form-control, .form-select {
                border-radius: 6px;
                border: 1px solid #d1d5db;
                padding: 10px 12px;
                font-size: 14px;
                transition: border-color 0.3s ease, box-shadow 0.3s ease;
                background-color: #ffffff;
            }

            .form-control:focus, .form-select:focus {
                border-color: #1976d2;
                box-shadow: 0 0 0 3px rgba(25, 118, 210, 0.1);
                outline: none;
            }

            .control-label {
                font-weight: 500;
                margin-bottom: 6px;
                display: block;
                color: #374151;
            }

            /* Button styling */
            .btn {
                border-radius: 6px;
                padding: 10px 20px;
                font-weight: 500;
                border: none;
                cursor: pointer;
                transition: all 0.3s ease;
                font-size: 14px;
            }

            .btn-primary {
                background: linear-gradient(135deg, #1976d2 0%, #1565c0 100%);
                color: white;
            }

            .btn-primary:hover {
                background: linear-gradient(135deg, #1565c0 0%, #0d47a1 100%);
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(25, 118, 210, 0.3);
            }

            .btn-secondary {
                background: #6c757d;
                color: white;
            }

            .btn-success {
                background: linear-gradient(135deg, #388e3c 0%, #2e7d32 100%);
                color: white;
            }

            .btn-warning {
                background: linear-gradient(135deg, #f57c00 0%, #ef6c00 100%);
                color: white;
            }

            .btn-info {
                background: linear-gradient(135deg, #0288d1 0%, #0277bd 100%);
                color: white;
            }

            /* Alert styling */
            .alert {
                border-radius: 6px;
                padding: 12px 16px;
                margin-bottom: 16px;
                border-left: 4px solid;
            }

            .alert-info {
                background-color: #e3f2fd;
                border-left-color: #2196f3;
                color: #0d47a1;
            }

            .alert-warning {
                background-color: #fff3e0;
                border-left-color: #ff9800;
                color: #e65100;
            }

            .alert-success {
                background-color: #e8f5e8;
                border-left-color: #4caf50;
                color: #2e7d32;
            }

            .alert-danger {
                background-color: #ffebee;
                border-left-color: #f44336;
                color: #c62828;
            }

            /* Progress bar */
            .progress {
                background-color: rgba(25, 118, 210, 0.1);
                border-radius: 4px;
                overflow: hidden;
            }

            .progress-bar {
                background: linear-gradient(90deg, #1976d2, #42a5f5);
                transition: width 0.3s ease;
            }

            /* Responsive design */
            @media (max-width: 768px) {
                .sidebar { position: static; }
                .main-content { width: 100%; padding: 0; }
                .card { box-shadow: none; border: 1px solid rgba(0, 0, 0, 0.12); }
            }

            /* Dark Mode Styles */
            body.dark-mode {
                background-color: #181818 !important;
                color: #f0f0f0 !important;
            }

            body.dark-mode .container-fluid {
                background-color: #181818;
            }

            body.dark-mode .card,
            body.dark-mode .card-header,
            body.dark-mode .card-body {
                background-color: #2d2d2d !important;
                color: #f0f0f0 !important;
                border-color: #404040 !important;
            }

            body.dark-mode .app-bar {
                background: linear-gradient(135deg, #1565c0 0%, #0d47a1 100%) !important;
                color: #ffffff !important;
            }

            body.dark-mode .sidebar {
                background-color: #1e1e1e !important;
            }

            body.dark-mode .main-content {
                background-color: #181818 !important;
            }

            body.dark-mode .form-control,
            body.dark-mode .form-select {
                background-color: #ffffff !important;
                color: #212529 !important;
                border-color: #404040 !important;
            }

            body.dark-mode .form-control:focus,
            body.dark-mode .form-select:focus {
                background-color: #ffffff !important;
                color: #212529 !important;
                border-color: #1976d2 !important;
                box-shadow: 0 0 0 0.2rem rgba(25, 118, 210, 0.25) !important;
            }

            /* Selectize input styling for dark mode */
            body.dark-mode .selectize-input,
            body.dark-mode .selectize-input.has-items {
                background-color: #ffffff !important;
                color: #212529 !important;
                border-color: #404040 !important;
            }

            body.dark-mode .selectize-input:focus,
            body.dark-mode .selectize-input.focus {
                background-color: #ffffff !important;
                color: #212529 !important;
                border-color: #1976d2 !important;
                box-shadow: 0 0 0 0.2rem rgba(25, 118, 210, 0.25) !important;
            }

            body.dark-mode .selectize-input > input {
                color: #212529 !important;
            }

            body.dark-mode .selectize-dropdown {
                background-color: #ffffff !important;
                border-color: #404040 !important;
            }

            body.dark-mode .selectize-dropdown .option {
                background-color: #ffffff !important;
                color: #212529 !important;
            }

            body.dark-mode .selectize-dropdown .option:hover,
            body.dark-mode .selectize-dropdown .option.active {
                background-color: #f8f9fa !important;
                color: #212529 !important;
            }

            body.dark-mode .selectize-input .item {
                background-color: #e9ecef !important;
                color: #212529 !important;
                border-color: #ced4da !important;
            }

            body.dark-mode .btn-primary {
                background-color: #1976d2 !important;
                border-color: #1976d2 !important;
                color: #ffffff !important;
            }

            body.dark-mode .btn-primary:hover {
                background-color: #1565c0 !important;
                border-color: #1565c0 !important;
            }

            body.dark-mode .btn-secondary,
            body.dark-mode .btn-outline-secondary {
                background-color: #404040 !important;
                border-color: #404040 !important;
                color: #f0f0f0 !important;
            }

            body.dark-mode .btn-success {
                background-color: #388e3c !important;
                border-color: #388e3c !important;
            }

            body.dark-mode .btn-warning {
                background-color: #f57c00 !important;
                border-color: #f57c00 !important;
            }

            body.dark-mode .btn-info {
                background-color: #0288d1 !important;
                border-color: #0288d1 !important;
            }

            body.dark-mode .alert-info {
                background-color: #1e3a5f !important;
                border-color: #0288d1 !important;
                color: #b3d4fc !important;
            }

            body.dark-mode .alert-warning {
                background-color: #4a3728 !important;
                border-color: #f57c00 !important;
                color: #ffcc80 !important;
            }

            body.dark-mode .alert-success {
                background-color: #2e5c30 !important;
                border-color: #388e3c !important;
                color: #c8e6c9 !important;
            }

            body.dark-mode .alert-danger {
                background-color: #5c2e2e !important;
                border-color: #d32f2f !important;
                color: #ffcdd2 !important;
            }

            body.dark-mode .control-label {
                color: #e0e0e0 !important; /* Improved contrast from #b0b0b0 */
            }

            body.dark-mode .form-text {
                color: #c0c0c0 !important; /* Improved contrast from #909090 */
            }

            body.dark-mode .form-check-input {
                background-color: #2d2d2d !important;
                border-color: #404040 !important;
            }

            body.dark-mode .form-check-input:checked {
                background-color: #1976d2 !important;
                border-color: #1976d2 !important;
            }

            body.dark-mode .form-check-label {
                color: #f0f0f0 !important;
            }

            body.dark-mode hr {
                background-color: #404040 !important;
                border-color: #404040 !important;
            }

            body.dark-mode .shiny-notification {
                background-color: #1e1e1e !important;
                color: #f0f0f0 !important;
                border-color: #404040 !important;
            }

            body.dark-mode .shiny-notification-error {
                background-color: #d32f2f !important;
            }

            body.dark-mode .shiny-notification-warning {
                background-color: #f57c00 !important;
            }

            body.dark-mode .shiny-notification-message {
                background-color: #1976d2 !important;
            }

            body.dark-mode .progress {
                background-color: rgba(25, 118, 210, 0.2) !important;
            }

            body.dark-mode .progress-bar {
                background-color: #1976d2 !important;
            }

            body.dark-mode .navbar-nav .nav-link {
                color: #f0f0f0 !important;
            }

            body.dark-mode .dropdown-menu {
                background-color: #2d2d2d !important;
                border-color: #404040 !important;
            }

            body.dark-mode .dropdown-item {
                color: #f0f0f0 !important;
            }

            body.dark-mode .dropdown-item:hover {
                background-color: #404040 !important;
                color: #ffffff !important;
            }

            body.dark-mode .table {
                color: #f0f0f0 !important;
            }

            body.dark-mode .table th,
            body.dark-mode .table td {
                border-color: #404040 !important;
            }

            body.dark-mode .table-striped tbody tr:nth-of-type(odd) {
                background-color: rgba(255, 255, 255, 0.05) !important;
            }

            body.dark-mode .border {
                border-color: #404040 !important;
            }

            body.dark-mode h1, body.dark-mode h2, body.dark-mode h3,
            body.dark-mode h4, body.dark-mode h5, body.dark-mode h6 {
                color: #f0f0f0 !important;
            }

            body.dark-mode p, body.dark-mode span, body.dark-mode div {
                color: #f0f0f0;
            }

            /* Plot backgrounds for dark mode */
            body.dark-mode .plotly {
                background-color: #2d2d2d !important;
            }

            /* Info box styles for both light and dark modes */
            .info-box-light {
                background-color: #d4edda;
                border-color: #c3e6cb;
                color: #155724;
            }

            .warning-box-light {
                background-color: #fff3cd;
                border-left-color: #ffc107;
                color: #856404;
            }

            .note-box-light {
                background-color: #d1ecf1;
                border-left-color: #17a2b8;
                color: #0c5460;
            }

            .data-info-box-light {
                background-color: #f8f9fa;
                border-left-color: #007bff;
                color: #212529;
            }

            /* Dark mode styles for info boxes */
            body.dark-mode .info-box-light {
                background-color: #1e3a2e !important;
                border-color: #2d5a3d !important;
                color: #b3d4c4 !important;
            }

            body.dark-mode .warning-box-light {
                background-color: #4a3728 !important;
                border-left-color: #f57c00 !important;
                color: #ffcc80 !important;
            }

            body.dark-mode .note-box-light {
                background-color: #1e3a5f !important;
                border-left-color: #0288d1 !important;
                color: #b3d4fc !important;
            }

            body.dark-mode .data-info-box-light {
                background-color: #1e2a3a !important;
                border-left-color: #1976d2 !important;
                color: #e3f2fd !important;
            }

            /* Ensure all text elements have proper contrast in dark mode */
            body.dark-mode .text-muted,
            body.dark-mode .small,
            body.dark-mode small {
                color: #c0c0c0 !important;
            }

            body.dark-mode .text-info {
                color: #64b5f6 !important;
            }

            body.dark-mode .text-success {
                color: #81c784 !important;
            }

            body.dark-mode .text-warning {
                color: #ffb74d !important;
            }

            body.dark-mode .text-danger {
                color: #e57373 !important;
            }

            /* Improve readability for help text and descriptions */
            body.dark-mode .help-block,
            body.dark-mode .form-text {
                color: #c0c0c0 !important;
            }

            /* Ensure proper contrast for all headings and paragraphs */
            body.dark-mode h1, body.dark-mode h2, body.dark-mode h3,
            body.dark-mode h4, body.dark-mode h5, body.dark-mode h6,
            body.dark-mode p, body.dark-mode span, body.dark-mode div,
            body.dark-mode li, body.dark-mode td, body.dark-mode th {
                color: #f0f0f0 !important;
            }

            /* Override any remaining hardcoded colors */
            body.dark-mode [style*='color:#'],
            body.dark-mode [style*='color: #'] {
                color: #f0f0f0 !important;
            }
        "))
    ),

    # JavaScript for dark mode communication
    tags$script(HTML("
        // Enhanced Dark mode communication script
        // Listen for postMessage events from the React frontend

        let currentDarkMode = false;
        let communicationReady = false;

        // Check URL parameters for dark mode on load
        function checkUrlDarkMode() {
            try {
                const urlParams = new URLSearchParams(window.location.search);
                const darkModeParam = urlParams.get('dark_mode');

                if (darkModeParam !== null) {
                    const isDarkMode = darkModeParam === '1' || darkModeParam === 'true';
                    console.log('Dark mode detected from URL parameter:', isDarkMode);

                    if (currentDarkMode !== isDarkMode) {
                        currentDarkMode = isDarkMode;
                        applyDarkMode(isDarkMode);
                        // Store in localStorage for persistence
                        try {
                            localStorage.setItem('darkMode', isDarkMode ? '1' : '0');
                        } catch (e) {
                            console.warn('Could not save to localStorage:', e);
                        }
                    }
                    return true;
                }

                // Fallback: check localStorage
                try {
                    const storedDarkMode = localStorage.getItem('darkMode');
                    if (storedDarkMode !== null) {
                        const isDarkMode = storedDarkMode === '1';
                        console.log('Dark mode detected from localStorage:', isDarkMode);

                        if (currentDarkMode !== isDarkMode) {
                            currentDarkMode = isDarkMode;
                            applyDarkMode(isDarkMode);
                        }
                        return true;
                    }
                } catch (e) {
                    console.warn('Could not read from localStorage:', e);
                }
            } catch (error) {
                console.warn('Error checking URL dark mode parameter:', error);
            }
            return false;
        }

        // Initialize dark mode communication
        function initializeDarkModeListener() {
            window.addEventListener('message', function(event) {
                // Security check: only accept messages from trusted frontend origins
                const trustedOrigins = getTrustedOrigins();

                if (!trustedOrigins.includes(event.origin)) {
                    console.log('Ignored message from untrusted origin:', event.origin);
                    return;
                }

                // Handle different message types
                if (event.data && typeof event.data === 'object') {
                    handleIncomingMessage(event.data, event.origin);
                }
            });

            console.log('Dark mode message listener initialized');
        }

        // Get trusted origins dynamically based on environment
        function getTrustedOrigins() {
            const localOrigins = [
                'http://localhost:3000',
                'http://127.0.0.1:3000',
                'http://localhost:5173', // Vite dev server
                'http://127.0.0.1:5173'  // Vite dev server
            ];

            const productionOrigins = [
                'https://komstat-frontend.onrender.com',
                'https://komstat-dashboard-final-banget.onrender.com' // Alternative domain pattern
            ];

            // Try to get frontend URL from R environment variable
            try {
                if (typeof Shiny !== 'undefined' && Shiny.shinyapp && Shiny.shinyapp.config) {
                    const frontendUrl = Shiny.shinyapp.config.frontendUrl;
                    if (frontendUrl && !productionOrigins.includes(frontendUrl)) {
                        productionOrigins.push(frontendUrl);
                    }
                }
            } catch (error) {
                console.log('Could not read frontend URL from Shiny config:', error);
            }

            // Check if we're in production environment
            const isProduction = window.location.hostname.includes('onrender.com') ||
                                 window.location.protocol === 'https:';

            const allOrigins = isProduction ? [...localOrigins, ...productionOrigins] : localOrigins;
            console.log('Trusted origins:', allOrigins);
            return allOrigins;
        }

        // Handle incoming messages from React frontend
        function handleIncomingMessage(data, origin) {
            const { type, value, timestamp, source } = data;

            switch(type) {
                case 'DARK_MODE':
                    handleDarkModeMessage(value, source);
                    break;
                case 'REQUEST_READY':
                    handleReadyRequest(origin);
                    break;
                default:
                    console.log('Unknown message type:', type);
            }
        }

        // Handle dark mode toggle message
        function handleDarkModeMessage(isDarkMode, source) {
            console.log('Received dark mode message:', isDarkMode, 'from:', source);

            if (currentDarkMode !== isDarkMode) {
                currentDarkMode = isDarkMode;
                applyDarkMode(isDarkMode);

                // Store in localStorage for persistence across reloads
                try {
                    localStorage.setItem('darkMode', isDarkMode ? '1' : '0');
                } catch (e) {
                    console.warn('Could not save to localStorage:', e);
                }
            }
        }

        // Apply dark mode to the document
        function applyDarkMode(isDarkMode) {
            if (isDarkMode) {
                document.body.classList.add('dark-mode');
                console.log('Applied dark mode');
            } else {
                document.body.classList.remove('dark-mode');
                console.log('Applied light mode');
            }

            // Optionally, update a Shiny input for server-side awareness
            if (typeof Shiny !== 'undefined' && Shiny.setInputValue) {
                Shiny.setInputValue('dark_mode', isDarkMode, {priority: 'event'});
            }

            // Trigger custom event for other scripts
            const event = new CustomEvent('darkModeChanged', {
                detail: { isDarkMode: isDarkMode }
            });
            document.dispatchEvent(event);
        }

        // Handle ready request from frontend
        function handleReadyRequest(origin) {
            console.log('Frontend requested ready state');
            sendReadyMessage(origin);
        }

        // Send ready message to parent window
        function sendReadyMessage(targetOrigin) {
            try {
                const message = {
                    type: 'SHINY_READY',
                    currentDarkMode: currentDarkMode,
                    timestamp: Date.now(),
                    source: 'shiny-app'
                };

                window.parent.postMessage(message, targetOrigin);
                console.log('Sent SHINY_READY message to:', targetOrigin);
                communicationReady = true;
            } catch(error) {
                console.error('Error sending ready message:', error);
            }
        }

        // Request dark mode state on load
        function requestInitialDarkMode() {
            console.log('Shiny app loaded, requesting dark mode state from parent...');

            const trustedParents = getTrustedOrigins();

            trustedParents.forEach(origin => {
                sendReadyMessage(origin);
            });
        }

        // Initialize when DOM is loaded
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
                // Check URL parameter first
                checkUrlDarkMode();
                initializeDarkModeListener();
                setTimeout(requestInitialDarkMode, 100);
            });
        } else {
            // Check URL parameter first
            checkUrlDarkMode();
            initializeDarkModeListener();
            setTimeout(requestInitialDarkMode, 100);
        }

        // Also trigger on window load as backup
        window.addEventListener('load', function() {
            if (!communicationReady) {
                setTimeout(requestInitialDarkMode, 200);
            }
        });

        // Listen for URL changes (for SPAs)
        window.addEventListener('popstate', function() {
            checkUrlDarkMode();
        });
    ")),

    # Material UI App Bar instead of titlePanel
    div(
        class = "app-bar",
        h1("Analisis Emisi Gas Rumah Kaca Global")
    ),

    # Material UI Container Layout
    div(
        class = "container-fluid",
        div(
            class = "row",
            # Input panel (sidebar)
            div(
                class = "col-md-4 sidebar",
                input_panel_ui("input_panel")
            ),

            # Results panel (main area)
            div(
                class = "col-md-8 main-content",
                results_panel_ui("results_panel")
            )
        )
    )
)

# Define server logic
server <- function(input, output, session) {
    # Initialize input panel module
    input_panel_values <- input_panel_server("input_panel", session)

    # Initialize results panel module
    results_panel_server(
        "results_panel",
        input_data = input_panel_values$data,
        test_type = input_panel_values$test_type,
        alpha = input_panel_values$alpha,
        run_trigger = input_panel_values$run_test_trigger
    )
}

# Run the application
shinyApp(ui = ui, server = server)
