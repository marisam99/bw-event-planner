# template_processor.R
# Description: Load and parse Excel templates with validation. Reads Excel files, validates required columns, performs data type checks, and provides template discovery and analysis functions.
# Output: Validated data frames, template summaries, filtered template subsets

# ============================================================================
# Template Reading Functions
# ============================================================================

#' Read Excel template file
#'
#' @param file_path Character string with path to Excel file
#' @param sheet Integer or character specifying which sheet to read (default: 1)
#'
#' @return Data frame with template data
#' @export
read_template <- function(file_path, sheet = 1) {

  # Check file exists
  if (!file.exists(file_path)) {
    stop(paste("Template file not found:", file_path))
  }

  # Check file extension
  if (!grepl("\\.xlsx?$", file_path, ignore.case = TRUE)) {
    stop("Template must be an Excel file (.xlsx or .xls)")
  }

  cli::cli_alert_info("Reading template from: {file_path}")

  # Read Excel file
  tryCatch({
    template_data <- openxlsx::read.xlsx(
      file_path,
      sheet = sheet,
      detectDates = TRUE
    )

    cli::cli_alert_success("Template file read successfully")

    # Validate template structure
    template_data <- validate_template(template_data)

    return(template_data)

  }, error = function(e) {
    stop(paste("Error reading Excel file:", conditionMessage(e)))
  })
}

#' Validate template structure
#'
#' @param template_data Data frame to validate
#'
#' @return Validated data frame (possibly with modifications)
#' @export
validate_template <- function(template_data) {

  cli::cli_alert_info("Validating template structure...")

  # Check for required columns
  missing_cols <- setdiff(REQUIRED_TEMPLATE_COLUMNS, names(template_data))

  if (length(missing_cols) > 0) {
    stop(paste(
      "Template is missing required columns:",
      paste(missing_cols, collapse = ", "),
      "\nRequired columns are:",
      paste(REQUIRED_TEMPLATE_COLUMNS, collapse = ", ")
    ))
  }

  # Check for data in required columns
  if (nrow(template_data) == 0) {
    stop("Template is empty. Please add at least one row of data.")
  }

  # Validate data types
  # deadline_weeks_before must be numeric
  if (!is.numeric(template_data$deadline_weeks_before)) {
    cli::cli_alert_warning("Converting deadline_weeks_before to numeric")
    template_data$deadline_weeks_before <- as.numeric(template_data$deadline_weeks_before)
  }

  # Check for NAs in critical columns
  critical_cols <- c("category", "item", "deadline_weeks_before")

  for (col in critical_cols) {
    na_count <- sum(is.na(template_data[[col]]))
    if (na_count > 0) {
      cli::cli_alert_warning("{na_count} rows have missing {col} values")
    }
  }

  # Remove rows where all critical columns are NA
  template_data <- template_data[
    !(is.na(template_data$category) &
      is.na(template_data$item) &
      is.na(template_data$deadline_weeks_before)),
  ]

  # Fill NA notes with empty string
  if ("notes" %in% names(template_data)) {
    template_data$notes[is.na(template_data$notes)] <- ""
  }

  # Add row IDs for tracking
  template_data$row_id <- seq_len(nrow(template_data))

  # Summary statistics
  n_rows <- nrow(template_data)
  n_categories <- length(unique(template_data$category))

  cli::cli_alert_success(
    "Template validated: {n_rows} items across {n_categories} categories"
  )

  return(template_data)
}

# ============================================================================
# Template Analysis Functions
# ============================================================================

#' Get summary statistics for template
#'
#' @param template_data Data frame with template data
#'
#' @return List with summary statistics
#' @export
get_template_summary <- function(template_data) {

  summary_stats <- list(
    total_items = nrow(template_data),
    n_categories = length(unique(template_data$category)),
    categories = unique(template_data$category),
    earliest_deadline = max(template_data$deadline_weeks_before, na.rm = TRUE),
    latest_deadline = min(template_data$deadline_weeks_before, na.rm = TRUE),
    items_by_category = table(template_data$category)
  )

  return(summary_stats)
}

#' Print template summary
#'
#' @param template_data Data frame with template data
#'
#' @export
print_template_summary <- function(template_data) {

  summary <- get_template_summary(template_data)

  cli::cli_h2("Template Summary")

  cli::cli_alert_info("Total Items: {summary$total_items}")
  cli::cli_alert_info("Categories: {summary$n_categories}")
  cli::cli_alert_info("Timeline: {summary$latest_deadline} to {summary$earliest_deadline} weeks before event")

  cli::cli_h3("Items by Category")
  for (cat in names(summary$items_by_category)) {
    cli::cli_li("{cat}: {summary$items_by_category[cat]} items")
  }
}

#' Get items by category
#'
#' @param template_data Data frame with template data
#' @param category Character string with category name
#'
#' @return Data frame filtered to specified category
#' @export
get_items_by_category <- function(template_data, category) {
  template_data[template_data$category == category, ]
}

#' Get items by deadline range
#'
#' @param template_data Data frame with template data
#' @param min_weeks Minimum weeks before event
#' @param max_weeks Maximum weeks before event
#'
#' @return Data frame filtered to deadline range
#' @export
get_items_by_deadline <- function(template_data, min_weeks, max_weeks) {
  template_data[
    template_data$deadline_weeks_before >= min_weeks &
    template_data$deadline_weeks_before <= max_weeks,
  ]
}

# ============================================================================
# Template Discovery Functions
# ============================================================================

#' List available templates in inputs directory
#'
#' @param inputs_dir Character string with path to inputs directory (default: "inputs")
#'
#' @return Character vector of template file paths
#' @export
list_templates <- function(inputs_dir = "inputs") {

  if (!dir.exists(inputs_dir)) {
    cli::cli_alert_warning("Inputs directory not found: {inputs_dir}")
    return(character(0))
  }

  template_files <- list.files(
    inputs_dir,
    pattern = "\\.xlsx?$",
    full.names = TRUE,
    ignore.case = TRUE
  )

  if (length(template_files) == 0) {
    cli::cli_alert_warning("No template files found in {inputs_dir}")
  } else {
    cli::cli_alert_success("Found {length(template_files)} template file(s)")
  }

  return(template_files)
}

#' Display available templates with details
#'
#' @param inputs_dir Character string with path to inputs directory (default: "inputs")
#'
#' @export
display_available_templates <- function(inputs_dir = "inputs") {

  templates <- list_templates(inputs_dir)

  if (length(templates) == 0) {
    return(invisible(NULL))
  }

  cli::cli_h2("Available Templates")

  for (template_path in templates) {
    template_name <- basename(template_path)
    file_size <- file.info(template_path)$size
    file_size_kb <- round(file_size / 1024, 1)

    cli::cli_li("{template_name} ({file_size_kb} KB)")
  }
}

# ============================================================================
# Template Conversion Functions
# ============================================================================

#' Convert template data frame to standard format
#'
#' Ensures all required columns exist and are in correct order
#'
#' @param template_data Data frame to standardize
#'
#' @return Standardized data frame
#' @export
standardize_template <- function(template_data) {

  # Ensure all required columns exist
  for (col in REQUIRED_TEMPLATE_COLUMNS) {
    if (!col %in% names(template_data)) {
      template_data[[col]] <- NA
    }
  }

  # Add optional columns if they don't exist
  for (col in OPTIONAL_TEMPLATE_COLUMNS) {
    if (!col %in% names(template_data)) {
      template_data[[col]] <- NA
    }
  }

  # Reorder columns
  all_expected_cols <- c(REQUIRED_TEMPLATE_COLUMNS, OPTIONAL_TEMPLATE_COLUMNS)
  existing_cols <- intersect(all_expected_cols, names(template_data))
  other_cols <- setdiff(names(template_data), all_expected_cols)

  template_data <- template_data[, c(existing_cols, other_cols)]

  return(template_data)
}

# ============================================================================
# Template processor loaded
# ============================================================================

cli::cli_alert_success("Template processor functions loaded")
