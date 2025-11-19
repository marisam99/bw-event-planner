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
  # Deadline should be date or character (will be processed by AI if empty)
  if ("Deadline" %in% names(template_data)) {
    if (!inherits(template_data$Deadline, "Date") && !is.character(template_data$Deadline)) {
      cli::cli_alert_info("Converting Deadline column to character format")
      template_data$Deadline <- as.character(template_data$Deadline)
    }
  }

  # Check for NAs in critical columns
  critical_cols <- c("Task", "Deadline")

  for (col in critical_cols) {
    if (col %in% names(template_data)) {
      na_count <- sum(is.na(template_data[[col]]) | template_data[[col]] == "")
      if (na_count > 0) {
        cli::cli_alert_warning("{na_count} rows have missing {col} values")
      }
    }
  }

  # Remove rows where both critical columns are NA/empty
  template_data <- template_data[
    !(is.na(template_data$Task) | template_data$Task == "") |
    !(is.na(template_data$Deadline) | template_data$Deadline == ""),
  ]

  # Fill NA optional columns with empty string
  if ("Notes" %in% names(template_data)) {
    template_data$Notes[is.na(template_data$Notes)] <- ""
  }
  if ("Existing Resources" %in% names(template_data)) {
    template_data$`Existing Resources`[is.na(template_data$`Existing Resources`)] <- ""
  }

  # Add row IDs for tracking
  template_data$row_id <- seq_len(nrow(template_data))

  # Summary statistics
  n_rows <- nrow(template_data)
  n_categories <- if ("Category" %in% names(template_data)) {
    length(unique(template_data$Category[!is.na(template_data$Category)]))
  } else {
    0
  }

  if (n_categories > 0) {
    cli::cli_alert_success(
      "Template validated: {n_rows} items across {n_categories} categories"
    )
  } else {
    cli::cli_alert_success(
      "Template validated: {n_rows} items"
    )
  }

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

  has_category <- "Category" %in% names(template_data)

  summary_stats <- list(
    total_items = nrow(template_data),
    has_category = has_category
  )

  if (has_category) {
    summary_stats$n_categories <- length(unique(template_data$Category[!is.na(template_data$Category)]))
    summary_stats$categories <- unique(template_data$Category[!is.na(template_data$Category)])
    summary_stats$items_by_category <- table(template_data$Category)
  }

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

  if (summary$has_category) {
    cli::cli_alert_info("Categories: {summary$n_categories}")
    cli::cli_h3("Items by Category")
    for (cat in names(summary$items_by_category)) {
      cli::cli_li("{cat}: {summary$items_by_category[cat]} items")
    }
  } else {
    cli::cli_alert_info("No category information in template")
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
  if (!"Category" %in% names(template_data)) {
    stop("Template does not have a Category column")
  }
  template_data[template_data$Category == category & !is.na(template_data$Category), ]
}

#' Get items by deadline date range
#'
#' @param template_data Data frame with template data
#' @param start_date Start date (Date or character)
#' @param end_date End date (Date or character)
#'
#' @return Data frame filtered to deadline range
#' @export
get_items_by_deadline_range <- function(template_data, start_date, end_date) {
  if (!"Deadline" %in% names(template_data)) {
    stop("Template does not have a Deadline column")
  }

  start_date <- as.Date(start_date)
  end_date <- as.Date(end_date)

  deadlines <- as.Date(template_data$Deadline)
  template_data[!is.na(deadlines) & deadlines >= start_date & deadlines <= end_date, ]
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
