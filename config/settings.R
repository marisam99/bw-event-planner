# ============================================================================
# settings.R
# ============================================================================
# Description: API configuration, model parameters, and prompt templates
# Author: Bellwether Analytics
# Date: 2025-11-18
# ============================================================================

# ============================================================================
# API Configuration
# ============================================================================

# OpenAI API settings
API_CONFIG <- list(
  base_url = "https://api.openai.com/v1",
  model = "chatgpt-5.1",  # ChatGPT 5.1 as specified in workplan
  max_tokens = 4000,
  temperature = 0.7,
  timeout_seconds = 120
)

# Get API key from environment variable
get_api_key <- function() {
  api_key <- Sys.getenv("OPENAI_API_KEY")

  if (api_key == "") {
    stop("OPENAI_API_KEY not found in environment variables. Please set it in .Renviron file.")
  }

  return(api_key)
}

# ============================================================================
# Template Validation Settings
# ============================================================================

# Required columns in template Excel file
REQUIRED_TEMPLATE_COLUMNS <- c(
  "category",
  "item",
  "deadline_weeks_before",
  "notes"
)

# Optional columns that can be included
OPTIONAL_TEMPLATE_COLUMNS <- c(
  "budget_estimate",
  "responsible_party",
  "priority"
)

# ============================================================================
# Prompt Templates
# ============================================================================

# System prompt for AI assistant
SYSTEM_PROMPT <- "You are an expert event planning assistant. Your role is to help expand and enhance event planning templates with detailed, actionable tasks and recommendations. You provide practical, professional advice based on event planning best practices. Keep your suggestions concrete, specific, and tailored to the event details provided."

# Main prompt template for worksheet expansion
# Uses glue syntax: {variable_name} for interpolation
EXPANSION_PROMPT_TEMPLATE <- "
I am planning an event and need help expanding my planning worksheet.

Event Details:
- Event Name: {event_name}
- Event Date: {event_date}
- Number of Attendees: {attendee_count}
- Budget Range: {budget_range}
- Event Type: {event_type}

I have a planning task that needs expansion:

Category: {category}
Task: {item}
Deadline: {deadline_weeks_before} weeks before event
Context Notes: {notes}

Please provide:
1. A detailed expansion of this task with 3-5 specific action items
2. Key considerations or potential challenges
3. Recommended resources or vendors to consider (if applicable)
4. Estimated budget range for this task (if applicable)
5. Any dependencies or prerequisites

Format your response as structured text that can be easily added to a planning worksheet. Be concise but comprehensive.
"

# Prompt for generating category summaries
CATEGORY_SUMMARY_PROMPT_TEMPLATE <- "
For the event planning category '{category}', provide a brief overview (2-3 sentences) of key priorities and timeline considerations for this type of event:

Event Type: {event_type}
Attendee Count: {attendee_count}
Budget Range: {budget_range}

Keep the response professional and actionable.
"

# ============================================================================
# Output Formatting Settings
# ============================================================================

# Excel formatting constants
EXCEL_FORMATS <- list(
  header_fill = "steelblue",
  header_font_color = "white",
  header_font_size = 12,
  header_bold = TRUE,

  category_fill = "lightgray",
  category_font_size = 11,
  category_bold = TRUE,

  body_font_size = 10,

  date_format = "yyyy-mm-dd",
  currency_format = "$#,##0.00",

  column_widths = c(15, 30, 15, 40, 15, 20)  # Adjust based on final column structure
)

# Sheet names for multi-sheet workbook
OUTPUT_SHEET_NAMES <- list(
  main = "Event Planning Worksheet",
  timeline = "Timeline View",
  budget = "Budget Summary",
  metadata = "Generation Details"
)

# ============================================================================
# Application Constants
# ============================================================================

# Event type options
EVENT_TYPES <- c(
  "Conference",
  "Workshop",
  "Networking Event",
  "Virtual Event",
  "Hybrid Event",
  "Seminar",
  "Gala",
  "Training Session",
  "Other"
)

# Budget range options
BUDGET_RANGES <- c(
  "Under $5,000",
  "$5,000 - $10,000",
  "$10,000 - $25,000",
  "$25,000 - $50,000",
  "$50,000 - $100,000",
  "Over $100,000"
)

# ============================================================================
# Validation Functions
# ============================================================================

# Validate event details
validate_event_details <- function(event_details) {
  required_fields <- c("name", "date", "attendee_count", "budget_range", "event_type")

  missing_fields <- setdiff(required_fields, names(event_details))

  if (length(missing_fields) > 0) {
    stop(paste("Missing required fields:", paste(missing_fields, collapse = ", ")))
  }

  # Validate attendee count is numeric
  if (!is.numeric(event_details$attendee_count) || event_details$attendee_count <= 0) {
    stop("Attendee count must be a positive number")
  }

  return(TRUE)
}

# ============================================================================
# Helper Functions
# ============================================================================

# Format prompt with event details
format_prompt <- function(template, ...) {
  glue::glue(template, ...)
}

# Calculate actual deadline date
calculate_deadline_date <- function(event_date, weeks_before) {
  event_date <- as.Date(event_date)
  deadline_date <- event_date - (weeks_before * 7)
  return(deadline_date)
}

# ============================================================================
# Configuration complete
# ============================================================================

cli::cli_alert_success("Settings and configuration loaded")
