# UI Helper Functions
# Functions untuk membuat komponen UI yang dapat digunakan kembali

#' Create info box with icon and content
#' @param icon Icon character (emoji)
#' @param title Title text
#' @param content Content text (HTML allowed)
#' @param style_class CSS style class
#' @return Div element
create_info_box <- function(icon, title, content, style_class = "info-box") {
    css_class <- switch(style_class,
        "info-box" = "info-box-light",
        "warning-box" = "warning-box-light",
        "note-box" = "note-box-light",
        "data-info-box" = "data-info-box-light",
        "info-box-light"
    )

    div(
        class = css_class,
        style = "padding: 8px; border-radius: 4px; border-left: 4px solid; margin: 5px 0;",
        HTML(paste0("<strong>", icon, " ", title, ":</strong><br/>", content))
    )
}

#' Get info box CSS style
#' @param style_class Style class name
#' @return CSS style string
get_info_box_style <- function(style_class) {
    switch(style_class,
        "info-box" = "padding: 8px; border-radius: 4px; border: 1px solid; margin: 5px 0; class: 'info-box-light';",
        "warning-box" = "padding: 8px; border-radius: 4px; border-left: 4px solid; margin: 5px 0; class: 'warning-box-light';",
        "note-box" = "padding: 8px; border-radius: 4px; border-left: 4px solid; margin: 5px 0; class: 'note-box-light';",
        "data-info-box" = "padding: 10px; border-radius: 5px; font-size: 12px; border-left: 4px solid; margin: 5px 0; class: 'data-info-box-light';"
    )
}

#' Create test selection radio buttons
#' @param input_id Input ID
#' @param selected Default selection
#' @return Radio button group
create_test_selection <- function(input_id, selected = "sign") {
    radioButtons(input_id, "Pilih Jenis Uji:",
        choices = list(
            "Uji Tanda (Sign Test)" = "sign",
            "Uji Wilcoxon Signed-Rank" = "wilcoxon",
            "Uji Runs (Runs Test)" = "run",
            "Uji Mann-Whitney U" = "mannwhitney"
        ),
        selected = selected
    )
}

#' Create file upload section
#' @param file_input_id File input ID
#' @param clear_button_id Clear button ID
#' @param download_button_id Download button ID
#' @param file_status_output_id File status output ID (namespaced)
#' @return Div containing file upload UI
create_file_upload_section <- function(file_input_id, clear_button_id, download_button_id, file_status_output_id) {
    div(
        class = "file-input-container",
        h5("📁 Upload File Data:"),
        fileInput(file_input_id, NULL,
            accept = c(".csv", ".xls", ".xlsx", ".sav"),
            buttonLabel = "Browse..."
        ),

        # Buttons for file management
        div(
            class = "row",
            div(
                class = "col-12 col-md-6 mb-2 px-2",
                downloadButton(download_button_id, "Download Template CSV",
                    class = "btn btn-success btn-sm w-100 text-truncate"
                )
            ),
            div(
                class = "col-12 col-md-6 mb-2 px-2",
                actionButton(clear_button_id, "🗑️ Clear File",
                    class = "btn btn-warning btn-sm w-100"
                )
            )
        ),
        helpText("Format: File CSV, Excel (.xlsx/.xls), atau SPSS (.sav) dengan 2 kolom data numerik dan 5 baris"),
        br()
    )
}

#' Create manual input section
#' @param use_manual_id Use manual button ID
#' @param sample1_id Sample 1 input ID
#' @param sample2_id Sample 2 input ID
#' @param test_type_input_id Test type input ID (namespaced)
#' @return Div containing manual input UI
create_manual_input_section <- function(use_manual_id, sample1_id, sample2_id, test_type_input_id) {
    div(
        h5("✏️ Atau Input Manual:"),

        # Manual mode button
        actionButton(use_manual_id, "🔄 Gunakan Input Manual",
            class = "btn btn-info btn-sm",
            style = "margin-bottom: 10px;"
        ),

        # Sample input fields
        textInput(sample1_id, "Sampel 1 (pisahkan dengan koma):",
            value = "", placeholder = "78,82,85,79,88"
        ),
        textInput(sample2_id, "Sampel 2 (pisahkan dengan koma):",
            value = "", placeholder = "75,79,82,76,85"
        ),

        # Conditional notes for different test types
        conditionalPanel(
            condition = paste0("input['", test_type_input_id, "'] == 'sign'"),
            create_info_box(
                "📝", "Catatan Uji Tanda (Sign Test)",
                "<b>Tujuan:</b> Menguji apakah terdapat perbedaan median antara dua pengukuran berpasangan.<br/>
<b>Jenis Sampel:</b> Berpasangan (dependen).<br/>
<b>H0:</b> Tidak ada perbedaan median antara dua kondisi (median perbedaan = 0).<br/>
<b>H1:</b> Ada perbedaan median antara dua kondisi (median perbedaan ≠ 0).<br/>
Digunakan untuk data ordinal atau interval yang tidak berdistribusi normal.",
                "note-box"
            )
        ),
        conditionalPanel(
            condition = paste0("input['", test_type_input_id, "'] == 'wilcoxon'"),
            create_info_box(
                "📝", "Catatan Wilcoxon Signed-Rank",
                "<b>Tujuan:</b> Menguji perbedaan median antara dua pengukuran berpasangan dengan memperhitungkan besar dan arah perbedaan.<br/>
<b>Jenis Sampel:</b> Berpasangan (dependen).<br/>
<b>H0:</b> Distribusi perbedaan berpusat di nol (tidak ada perbedaan).<br/>
<b>H1:</b> Distribusi perbedaan tidak berpusat di nol (ada perbedaan).<br/>
Lebih sensitif daripada Uji Tanda karena memperhitungkan ranking perbedaan.",
                "note-box"
            )
        ),
        conditionalPanel(
            condition = paste0("input['", test_type_input_id, "'] == 'run'"),
            create_info_box(
                "📝", "Catatan Runs (Runs Test)",
                "<b>Tujuan:</b> Menguji apakah urutan data (misal: tanda perbedaan) bersifat random.<br/>
<b>Jenis Sampel:</b> Berpasangan (dependen).<br/>
<b>H0:</b> Urutan perbedaan bersifat random.<br/>
<b>H1:</b> Urutan perbedaan tidak random.<br/>
Digunakan untuk mendeteksi pola non-random pada data berurutan.",
                "note-box"
            )
        ),
        conditionalPanel(
            condition = paste0("input['", test_type_input_id, "'] == 'mannwhitney'"),
            create_info_box(
                "📝", "Catatan Mann-Whitney U",
                "<b>Tujuan:</b> Menguji apakah dua kelompok independen memiliki distribusi/median yang sama.<br/>
<b>Jenis Sampel:</b> Dua kelompok independen.<br/>
<b>H0:</b> Distribusi/median kedua kelompok sama.<br/>
<b>H1:</b> Distribusi/median kedua kelompok berbeda.<br/>
Alternatif nonparametrik dari uji t dua sampel independen.",
                "note-box"
            )
        ),
        br(), br()
    )
}

#' Create emission data selection section
#' @param data_type_id ID for data type selection
#' @param analysis_type_id ID for analysis type selection
#' @param country1_id ID for first country selection
#' @param country2_id ID for second country selection
#' @param year1_id ID for year1 selection (for year comparison)
#' @param year2_id ID for year2 selection (for year comparison)
#' @param use_emission_id ID for use emission data checkbox
#' @return Div containing emission data selection UI
create_emission_data_section <- function(data_type_id, analysis_type_id, country1_id, country2_id, year1_id, year2_id, use_emission_id) {
    div(
        h6("🌍 Data Emisi Gas Rumah Kaca", style = "font-weight: bold;"),
        checkboxInput(use_emission_id, "Gunakan Data Emisi", value = FALSE),
        conditionalPanel(
            condition = paste0("input['", use_emission_id, "']"),

            # Data type selection
            selectizeInput(data_type_id, "Jenis Data Emisi:",
                choices = list(
                    "Nilai emisi CH4" = "CH4",
                    "Nilai emisi CO2" = "CO2",
                    "Nilai emisi N2O" = "N2O",
                    "Nilai total emisi gas rumah kaca" = "TOTAL"
                ),
                selected = NULL,
                options = list(
                    placeholder = "Pilih jenis data...",
                    onInitialize = I('function() { this.setValue(""); }')
                )
            ),

            # Analysis type selection
            conditionalPanel(
                condition = paste0("input['", data_type_id, "'] != ''"),
                radioButtons(analysis_type_id, "Jenis Analisis:",
                    choices = list(
                        "Bandingkan Dua Tahun Berbeda" = "year_comparison",
                        "Bandingkan Dua Negara Berbeda" = "country_comparison"
                    ),
                    selected = "year_comparison"
                )
            ),

            # Year comparison options
            conditionalPanel(
                condition = paste0("input['", data_type_id, "'] != '' && input['", analysis_type_id, "'] == 'year_comparison'"),
                h6("📅 Perbandingan Tahun:"),
                fluidRow(
                    column(
                        6,
                        selectizeInput(year1_id, "Tahun 1:",
                            choices = c(),
                            selected = NULL,
                            options = list(
                                placeholder = "Pilih tahun...",
                                onInitialize = I('function() { this.setValue(""); }')
                            )
                        )
                    ),
                    column(
                        6,
                        selectizeInput(year2_id, "Tahun 2:",
                            choices = c(),
                            selected = NULL,
                            options = list(
                                placeholder = "Pilih tahun...",
                                onInitialize = I('function() { this.setValue(""); }')
                            )
                        )
                    )
                ),
                helpText("Membandingkan emisi semua negara antara dua tahun yang dipilih")
            ),

            # Country comparison options
            conditionalPanel(
                condition = paste0("input['", data_type_id, "'] != '' && input['", analysis_type_id, "'] == 'country_comparison'"),
                h6("🏛️ Perbandingan Negara:"),
                fluidRow(
                    column(
                        6,
                        selectizeInput(country1_id, "Negara 1:",
                            choices = c(),
                            selected = NULL,
                            multiple = FALSE,
                            options = list(
                                placeholder = "Pilih negara...",
                                onInitialize = I('function() { this.setValue(""); }')
                            )
                        )
                    ),
                    column(
                        6,
                        selectizeInput(country2_id, "Negara 2:",
                            choices = c(),
                            selected = NULL,
                            multiple = FALSE,
                            options = list(
                                placeholder = "Pilih negara...",
                                onInitialize = I('function() { this.setValue(""); }')
                            )
                        )
                    )
                ),
                helpText("Membandingkan emisi dua negara menggunakan semua tahun yang tersedia")
            )
        ),
        br()
    )
}

#' Create placeholder content for results area
#' @return Div containing placeholder content
create_results_placeholder <- function() {
    div(
        style = "text-align: center; margin-top: 100px;",
        h4("⏳ Siap untuk Analisis"),
        p("Unggah file data (CSV, Excel, atau SPSS) atau masukkan data secara manual."),
        p("Pilih jenis uji statistik yang diinginkan dan klik 'Jalankan Uji'."),
        p("Anda juga dapat menganalisis data emisi gas rumah kaca dengan memilih opsi 'Gunakan Data Emisi'."),
        p("Pastikan data yang diinput minimal terdiri dari 2 kolom numerik dan 5 baris untuk hasil analisis yang valid."),
        div(
            style = "margin-top: 30px;",
            span("💡 Tips: ", style = "font-weight: bold;"),
            "Gunakan tombol 'Clear File' untuk beralih dari CSV ke input manual"
        )
    )
}
