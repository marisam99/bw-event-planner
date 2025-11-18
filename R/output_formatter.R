# ============================================================================
# output_formatter.R
# ============================================================================
# Description: Format and export worksheets to Excel with professional styling
# Author: Bellwether Analytics
# Date: 2025-11-18
# ============================================================================

# ============================================================================
# Main Export Function
# ============================================================================

#' Save worksheet to Excel file with formatting
#'
#' @param worksheet List containing worksheet data frames
#' @param output_path Character string with output file path
#' @param apply_formatting Logical whether to apply professional formatting (default: TRUE)
#'
#' @export
save_worksheet <- function(worksheet,
                             output_path,
                             apply_formatting = TRUE) {

  cli::cli_h2("Saving Worksheet to Excel")

  # Validate worksheet
  validate_worksheet(worksheet)

  # Create workbook
  wb <- openxlsx::createWorkbook()

  # Add sheets with data
  cli::cli_alert_info("Adding Main Planning Worksheet...")
  add_worksheet_sheet(wb, OUTPUT_SHEET_NAMES$main, worksheet$main, apply_formatting)

  cli::cli_alert_info("Adding Timeline View...")
  add_worksheet_sheet(wb, OUTPUT_SHEET_NAMES$timeline, worksheet$timeline, apply_formatting)

  cli::cli_alert_info("Adding Budget Summary...")
  add_worksheet_sheet(wb, OUTPUT_SHEET_NAMES$budget, worksheet$budget, apply_formatting)

  cli::cli_alert_info("Adding Metadata...")
  add_worksheet_sheet(wb, OUTPUT_SHEET_NAMES$metadata, worksheet$metadata, apply_formatting)

  # Ensure output directory exists
  output_dir <- dirname(output_path)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    cli::cli_alert_info("Created output directory: {output_dir}")
  }

  # Save workbook
  tryCatch({
    openxlsx::saveWorkbook(wb, output_path, overwrite = TRUE)
    cli::cli_alert_success("Worksheet saved to: {output_path}")

    # Print file size
    file_size <- file.info(output_path)$size
    file_size_kb <- round(file_size / 1024, 1)
    cli::cli_alert_info("File size: {file_size_kb} KB")

  }, error = function(e) {
    stop(paste("Error saving Excel file:", conditionMessage(e)))
  })

  return(invisible(output_path))
}

# ============================================================================
# Sheet Creation Functions
# ============================================================================

#' Add a formatted worksheet sheet to workbook
#'
#' @param wb Workbook object
#' @param sheet_name Character string with sheet name
#' @param data Data frame to write
#' @param apply_formatting Logical whether to apply formatting
#'
#' @keywords internal
add_worksheet_sheet <- function(wb, sheet_name, data, apply_formatting = TRUE) {

  # Add sheet
  openxlsx::addWorksheet(wb, sheet_name)

  # Write data
  openxlsx::writeData(wb, sheet_name, data, startRow = 1, startCol = 1)

  if (apply_formatting) {
    # Apply header formatting
    apply_header_formatting(wb, sheet_name, ncol(data))

    # Apply column formatting
    apply_column_formatting(wb, sheet_name, data)

    # Auto-size columns
    openxlsx::setColWidths(
      wb,
      sheet_name,
      cols = 1:ncol(data),
      widths = "auto"
    )

    # Freeze header row
    openxlsx::freezePane(wb, sheet_name, firstRow = TRUE)
  }
}

# ============================================================================
# Formatting Functions
# ============================================================================

#' Apply header row formatting
#'
#' @param wb Workbook object
#' @param sheet_name Character string with sheet name
#' @param n_cols Integer number of columns
#'
#' @keywords internal
apply_header_formatting <- function(wb, sheet_name, n_cols) {

  # Create header style
  header_style <- openxlsx::createStyle(
    fontSize = EXCEL_FORMATS$header_font_size,
    fontColour = EXCEL_FORMATS$header_font_color,
    fgFill = EXCEL_FORMATS$header_fill,
    halign = "center",
    valign = "center",
    textDecoration = "bold",
    border = "TopBottomLeftRight",
    borderStyle = "thin"
  )

  # Apply to header row
  openxlsx::addStyle(
    wb,
    sheet_name,
    style = header_style,
    rows = 1,
    cols = 1:n_cols,
    gridExpand = TRUE
  )
}

#' Apply column-specific formatting
#'
#' @param wb Workbook object
#' @param sheet_name Character string with sheet name
#' @param data Data frame
#'
#' @keywords internal
apply_column_formatting <- function(wb, sheet_name, data) {

  n_rows <- nrow(data)

  # Format date columns
  date_cols <- which(sapply(data, function(x) inherits(x, "Date")))
  if (length(date_cols) > 0) {
    date_style <- openxlsx::createStyle(numFmt = EXCEL_FORMATS$date_format)
    for (col in date_cols) {
      openxlsx::addStyle(
        wb,
        sheet_name,
        style = date_style,
        rows = 2:(n_rows + 1),
        cols = col,
        gridExpand = TRUE
      )
    }
  }

  # Format numeric/budget columns
  budget_cols <- grep("budget|cost|price", names(data), ignore.case = TRUE)
  if (length(budget_cols) > 0) {
    currency_style <- openxlsx::createStyle(numFmt = EXCEL_FORMATS$currency_format)
    for (col in budget_cols) {
      openxlsx::addStyle(
        wb,
        sheet_name,
        style = currency_style,
        rows = 2:(n_rows + 1),
        cols = col,
        gridExpand = TRUE
      )
    }
  }

  # Add conditional formatting for priority columns
  priority_cols <- grep("priority", names(data), ignore.case = TRUE)
  if (length(priority_cols) > 0) {
    apply_priority_conditional_formatting(wb, sheet_name, priority_cols[1], n_rows)
  }

  # Add conditional formatting for days until deadline
  days_cols <- grep("days until", names(data), ignore.case = TRUE)
  if (length(days_cols) > 0) {
    apply_deadline_conditional_formatting(wb, sheet_name, days_cols[1], n_rows)
  }
}

#' Apply conditional formatting for priority column
#'
#' @param wb Workbook object
#' @param sheet_name Character string with sheet name
#' @param priority_col Integer column number
#' @param n_rows Integer number of data rows
#'
#' @keywords internal
apply_priority_conditional_formatting <- function(wb, sheet_name, priority_col, n_rows) {

  # HIGH priority - red background
  high_style <- openxlsx::createStyle(
    fgFill = "#ffcccc",
    fontColour = "#cc0000"
  )

  # MEDIUM priority - yellow background
  medium_style <- openxlsx::createStyle(
    fgFill = "#ffffcc",
    fontColour = "#cc6600"
  )

  # LOW priority - green background
  low_style <- openxlsx::createStyle(
    fgFill = "#ccffcc",
    fontColour = "#006600"
  )

  # Apply conditional formatting
  openxlsx::conditionalFormatting(
    wb,
    sheet_name,
    cols = priority_col,
    rows = 2:(n_rows + 1),
    rule = "HIGH",
    style = high_style
  )

  openxlsx::conditionalFormatting(
    wb,
    sheet_name,
    cols = priority_col,
    rows = 2:(n_rows + 1),
    rule = "MEDIUM",
    style = medium_style
  )

  openxlsx::conditionalFormatting(
    wb,
    sheet_name,
    cols = priority_col,
    rows = 2:(n_rows + 1),
    rule = "LOW",
    style = low_style
  )
}

#' Apply conditional formatting for deadline urgency
#'
#' @param wb Workbook object
#' @param sheet_name Character string with sheet name
#' @param days_col Integer column number
#' @param n_rows Integer number of data rows
#'
#' @keywords internal
apply_deadline_conditional_formatting <- function(wb, sheet_name, days_col, n_rows) {

  # Urgent (< 7 days) - red background
  urgent_style <- openxlsx::createStyle(
    fgFill = "#ff9999",
    fontColour = "#990000"
  )

  # Soon (< 30 days) - orange background
  soon_style <- openxlsx::createStyle(
    fgFill = "#ffcc99",
    fontColour = "#cc6600"
  )

  # Apply conditional formatting
  openxlsx::conditionalFormatting(
    wb,
    sheet_name,
    cols = days_col,
    rows = 2:(n_rows + 1),
    rule = "<7",
    style = urgent_style
  )

  openxlsx::conditionalFormatting(
    wb,
    sheet_name,
    cols = days_col,
    rows = 2:(n_rows + 1),
    rule = "<30",
    style = soon_style
  )
}

# ============================================================================
# Quick Export Functions
# ============================================================================

#' Quick export with auto-generated filename
#'
#' @param worksheet List containing worksheet data frames
#' @param event_name Character string with event name (used in filename)
#' @param output_dir Character string with output directory (default: "outputs")
#'
#' @return Character string with output file path
#' @export
quick_export <- function(worksheet,
                          event_name,
                          output_dir = "outputs") {

  # Clean event name for filename
  clean_name <- gsub("[^A-Za-z0-9_-]", "_", event_name)
  clean_name <- gsub("_{2,}", "_", clean_name)  # Remove multiple underscores

  # Generate filename with timestamp
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- paste0(clean_name, "_", timestamp, ".xlsx")

  # Full path
  output_path <- file.path(output_dir, filename)

  # Save
  save_worksheet(worksheet, output_path)

  return(output_path)
}

#' Export with custom filename
#'
#' @param worksheet List containing worksheet data frames
#' @param filename Character string with desired filename (with or without .xlsx)
#' @param output_dir Character string with output directory (default: "outputs")
#'
#' @return Character string with output file path
#' @export
export_as <- function(worksheet,
                       filename,
                       output_dir = "outputs") {

  # Add .xlsx extension if not present
  if (!grepl("\\.xlsx$", filename, ignore.case = TRUE)) {
    filename <- paste0(filename, ".xlsx")
  }

  # Full path
  output_path <- file.path(output_dir, filename)

  # Save
  save_worksheet(worksheet, output_path)

  return(output_path)
}

# ============================================================================
# Template Export Functions
# ============================================================================

#' Create a blank template file
#'
#' @param output_path Character string with output file path
#' @param template_type Character string: "basic", "detailed" (default: "basic")
#'
#' @export
create_template_file <- function(output_path,
                                   template_type = "basic") {

  wb <- openxlsx::createWorkbook()

  if (template_type == "basic") {
    # Basic template with required columns only
    template_data <- data.frame(
      category = character(0),
      item = character(0),
      deadline_weeks_before = numeric(0),
      notes = character(0),
      stringsAsFactors = FALSE
    )

    # Add example rows
    template_data <- rbind(
      template_data,
      data.frame(
        category = "Venue",
        item = "Book conference room",
        deadline_weeks_before = 12,
        notes = "Consider capacity, AV needs, accessibility"
      ),
      data.frame(
        category = "Catering",
        item = "Select catering vendor",
        deadline_weeks_before = 8,
        notes = "Get quotes from 3 vendors, check dietary options"
      )
    )
  } else {
    # Detailed template with optional columns
    template_data <- data.frame(
      category = character(0),
      item = character(0),
      deadline_weeks_before = numeric(0),
      notes = character(0),
      budget_estimate = numeric(0),
      responsible_party = character(0),
      priority = character(0),
      stringsAsFactors = FALSE
    )
  }

  openxlsx::addWorksheet(wb, "Template")
  openxlsx::writeData(wb, "Template", template_data)

  # Apply header formatting
  apply_header_formatting(wb, "Template", ncol(template_data))

  openxlsx::saveWorkbook(wb, output_path, overwrite = TRUE)

  cli::cli_alert_success("Template created: {output_path}")

  return(invisible(output_path))
}

# ============================================================================
# Output formatter loaded
# ============================================================================

cli::cli_alert_success("Output formatter functions loaded")
