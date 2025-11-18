# worksheet_generator.R
# Description: Main logic to generate expanded event planning worksheets. Orchestrates AI expansion, deadline calculation, and creation of multiple worksheet views (main, timeline, budget, metadata).
# Output: List containing data frames for each worksheet view

# ============================================================================
# Main Generation Function
# ============================================================================

#' Generate complete event planning worksheet
#'
#' Main function that orchestrates the entire worksheet generation process
#'
#' @param template_data Data frame with template items (from read_template)
#' @param event_details List with event information (name, date, attendee_count, budget_range, event_type)
#' @param expand_items Logical whether to expand items with AI (default: TRUE)
#' @param progress Optional progress callback function
#'
#' @return List containing multiple data frames for different worksheet views
#' @export
generate_worksheet <- function(template_data,
                                 event_details,
                                 expand_items = TRUE,
                                 progress = NULL) {

  cli::cli_h1("Generating Event Planning Worksheet")

  # Validate inputs
  validate_event_details(event_details)

  cli::cli_alert_info("Event: {event_details$name}")
  cli::cli_alert_info("Date: {event_details$date}")
  cli::cli_alert_info("Type: {event_details$event_type}")

  # Initialize result list
  worksheet <- list()

  # Step 1: Process template data
  if (!is.null(progress)) {
    progress(0.1, detail = "Processing template")
  }

  processed_data <- template_data

  # Step 2: Calculate actual deadlines
  if (!is.null(progress)) {
    progress(0.2, detail = "Calculating deadlines")
  }

  processed_data <- add_deadline_dates(processed_data, event_details$date)

  # Step 3: Expand items with AI (if requested)
  if (expand_items) {
    if (!is.null(progress)) {
      progress(0.3, detail = "Expanding items with AI")
    }

    processed_data <- expand_template_items_batch(
      processed_data,
      event_details,
      progress = progress
    )
  }

  # Step 4: Create main worksheet
  if (!is.null(progress)) {
    progress(0.8, detail = "Creating main worksheet")
  }

  worksheet$main <- create_main_worksheet(processed_data, event_details)

  # Step 5: Create timeline view
  if (!is.null(progress)) {
    progress(0.85, detail = "Creating timeline view")
  }

  worksheet$timeline <- create_timeline_view(processed_data, event_details)

  # Step 6: Create budget summary (if budget info exists)
  if (!is.null(progress)) {
    progress(0.9, detail = "Creating budget summary")
  }

  worksheet$budget <- create_budget_summary(processed_data, event_details)

  # Step 7: Create metadata sheet
  if (!is.null(progress)) {
    progress(0.95, detail = "Creating metadata")
  }

  worksheet$metadata <- create_metadata_sheet(event_details, processed_data)

  # Complete
  if (!is.null(progress)) {
    progress(1.0, detail = "Complete")
  }

  cli::cli_alert_success("Worksheet generation complete!")

  return(worksheet)
}

# ============================================================================
# Data Processing Functions
# ============================================================================

#' Add actual deadline dates to template data
#'
#' @param template_data Data frame with template items
#' @param event_date Character or Date with event date
#'
#' @return Data frame with deadline_date column added
#' @export
add_deadline_dates <- function(template_data, event_date) {

  template_data$deadline_date <- sapply(
    template_data$deadline_weeks_before,
    function(weeks) {
      calculate_deadline_date(event_date, weeks)
    }
  )

  # Calculate days until deadline from today
  template_data$days_until_deadline <- as.numeric(
    as.Date(template_data$deadline_date) - Sys.Date()
  )

  return(template_data)
}

#' Add priority flags based on deadline proximity
#'
#' @param template_data Data frame with template items
#'
#' @return Data frame with priority column added
#' @export
add_priority_flags <- function(template_data) {

  template_data$priority <- ifelse(
    template_data$days_until_deadline < 30, "HIGH",
    ifelse(
      template_data$days_until_deadline < 90, "MEDIUM",
      "LOW"
    )
  )

  return(template_data)
}

# ============================================================================
# Worksheet View Creation Functions
# ============================================================================

#' Create main planning worksheet
#'
#' @param processed_data Data frame with processed template data
#' @param event_details List with event information
#'
#' @return Data frame formatted for main worksheet
#' @export
create_main_worksheet <- function(processed_data, event_details) {

  main_ws <- processed_data |>
    dplyr::arrange(deadline_weeks_before, category) |>
    dplyr::select(
      Category = category,
      Task = item,
      `Weeks Before Event` = deadline_weeks_before,
      `Deadline Date` = deadline_date,
      `Days Until Deadline` = days_until_deadline,
      Notes = notes,
      tidyselect::any_of("expanded_content"),
      tidyselect::any_of("budget_estimate"),
      tidyselect::any_of("responsible_party")
    )

  # Rename expanded_content if it exists
  if ("expanded_content" %in% names(main_ws)) {
    names(main_ws)[names(main_ws) == "expanded_content"] <- "AI Recommendations"
  }

  return(main_ws)
}

#' Create timeline view worksheet
#'
#' @param processed_data Data frame with processed template data
#' @param event_details List with event information
#'
#' @return Data frame formatted for timeline view
#' @export
create_timeline_view <- function(processed_data, event_details) {

  timeline_ws <- processed_data |>
    add_priority_flags() |>
    dplyr::arrange(deadline_date) |>
    dplyr::select(
      `Deadline Date` = deadline_date,
      `Days Until` = days_until_deadline,
      Priority = priority,
      Category = category,
      Task = item,
      tidyselect::any_of("responsible_party")
    )

  return(timeline_ws)
}

#' Create budget summary worksheet
#'
#' @param processed_data Data frame with processed template data
#' @param event_details List with event information
#'
#' @return Data frame formatted for budget view
#' @export
create_budget_summary <- function(processed_data, event_details) {

  # Check if budget_estimate column exists
  if (!"budget_estimate" %in% names(processed_data)) {
    # Create minimal budget worksheet
    budget_ws <- data.frame(
      Category = "Event Budget",
      `Budget Range` = event_details$budget_range,
      Notes = "Add budget estimates to template for detailed tracking",
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
  } else {
    # Create detailed budget worksheet
    budget_ws <- processed_data |>
      dplyr::filter(!is.na(budget_estimate)) |>
      dplyr::group_by(category) |>
      dplyr::summarise(
        `Number of Items` = dplyr::n(),
        `Estimated Budget` = sum(as.numeric(budget_estimate), na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::rename(Category = category)

    # Add total row
    total_row <- data.frame(
      Category = "TOTAL",
      `Number of Items` = sum(budget_ws$`Number of Items`),
      `Estimated Budget` = sum(budget_ws$`Estimated Budget`),
      check.names = FALSE,
      stringsAsFactors = FALSE
    )

    budget_ws <- rbind(budget_ws, total_row)
  }

  return(budget_ws)
}

#' Create metadata information sheet
#'
#' @param event_details List with event information
#' @param processed_data Data frame with processed template data
#'
#' @return Data frame with generation metadata
#' @export
create_metadata_sheet <- function(event_details, processed_data) {

  metadata <- data.frame(
    Field = c(
      "Event Name",
      "Event Date",
      "Event Type",
      "Attendee Count",
      "Budget Range",
      "Worksheet Generated",
      "Total Planning Items",
      "Number of Categories",
      "Planning Timeline (weeks)",
      "AI Model Used",
      "Generated By"
    ),
    Value = c(
      event_details$name,
      as.character(event_details$date),
      event_details$event_type,
      as.character(event_details$attendee_count),
      event_details$budget_range,
      as.character(Sys.time()),
      as.character(nrow(processed_data)),
      as.character(length(unique(processed_data$category))),
      paste(
        min(processed_data$deadline_weeks_before, na.rm = TRUE),
        "to",
        max(processed_data$deadline_weeks_before, na.rm = TRUE)
      ),
      API_CONFIG$model,
      "Event Planning Assistant v1.0"
    ),
    stringsAsFactors = FALSE
  )

  return(metadata)
}

# ============================================================================
# Utility Functions
# ============================================================================

#' Validate worksheet structure before output
#'
#' @param worksheet List with worksheet data frames
#'
#' @return Logical TRUE if valid, stops with error otherwise
#' @export
validate_worksheet <- function(worksheet) {

  required_sheets <- c("main", "timeline", "budget", "metadata")

  missing_sheets <- setdiff(required_sheets, names(worksheet))

  if (length(missing_sheets) > 0) {
    stop(paste(
      "Worksheet is missing required sheets:",
      paste(missing_sheets, collapse = ", ")
    ))
  }

  # Check each sheet has data
  for (sheet_name in required_sheets) {
    if (nrow(worksheet[[sheet_name]]) == 0) {
      cli::cli_alert_warning("Sheet '{sheet_name}' is empty")
    }
  }

  return(TRUE)
}

#' Get worksheet summary statistics
#'
#' @param worksheet List with worksheet data frames
#'
#' @return List with summary statistics
#' @export
get_worksheet_summary <- function(worksheet) {

  summary <- list(
    n_sheets = length(worksheet),
    sheet_names = names(worksheet),
    total_items = nrow(worksheet$main),
    categories = unique(worksheet$main$Category),
    earliest_deadline = min(worksheet$timeline$`Deadline Date`, na.rm = TRUE),
    latest_deadline = max(worksheet$timeline$`Deadline Date`, na.rm = TRUE)
  )

  return(summary)
}

#' Print worksheet summary
#'
#' @param worksheet List with worksheet data frames
#'
#' @export
print_worksheet_summary <- function(worksheet) {

  summary <- get_worksheet_summary(worksheet)

  cli::cli_h2("Generated Worksheet Summary")

  cli::cli_alert_info("Sheets Created: {summary$n_sheets}")
  cli::cli_li("Sheet Names: {paste(summary$sheet_names, collapse = ', ')}")

  cli::cli_alert_info("Total Planning Items: {summary$total_items}")
  cli::cli_alert_info("Categories: {length(summary$categories)}")
  cli::cli_alert_info("Timeline: {summary$earliest_deadline} to {summary$latest_deadline}")
}

# ============================================================================
# Worksheet generator loaded
# ============================================================================

cli::cli_alert_success("Worksheet generator functions loaded")
