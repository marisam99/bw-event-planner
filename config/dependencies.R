# dependencies.R
# Description: Centralized package loading for Event Planning Assistant. Sources all required packages for Shiny app development, data manipulation, Excel operations, and API communication.
# Output: Loaded packages and success message

# ============================================================================
# Package Check
# ============================================================================

# Required packages
required_packages <- c(
  "shiny",
  "bslib",
  "dplyr",
  "tidyr",
  "purrr",
  "openxlsx",
  "httr2",
  "jsonlite",
  "glue",
  "cli"
)

# Check for missing packages
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    "\n❌ Missing required packages: ", paste(missing_packages, collapse = ", "),
    "\n\n📦 Install them with:\n",
    "install.packages(c(", paste0("\"", missing_packages, "\"", collapse = ", "), "))",
    "\n"
  )
}

# ============================================================================
# Core Shiny packages
# ============================================================================
library(shiny)           # Web application framework
library(bslib)           # Modern UI theming and layout

# ============================================================================
# Data manipulation
# ============================================================================
library(dplyr)           # Data manipulation
library(tidyr)           # Data tidying
library(purrr)           # Functional programming tools

# ============================================================================
# Excel operations
# ============================================================================
library(openxlsx)        # Excel reading/writing with formatting support

# ============================================================================
# API communication
# ============================================================================
library(httr2)           # Modern HTTP client for API calls
library(jsonlite)        # JSON parsing

# ============================================================================
# String manipulation and prompts
# ============================================================================
library(glue)            # String interpolation

# ============================================================================
# UI enhancements (optional, load if available)
# ============================================================================
if (requireNamespace("shinyWidgets", quietly = TRUE)) {
  library(shinyWidgets)  # Enhanced input widgets
}

if (requireNamespace("waiter", quietly = TRUE)) {
  library(waiter)        # Loading indicators
}

# ============================================================================
# Utility
# ============================================================================
library(cli)             # Command line interface helpers

# ============================================================================
# Helper Functions
# ============================================================================

# Load system prompt from text file
load_system_prompt <- function(prompt_file = "config/system_prompt.txt") {
  if (!file.exists(prompt_file)) {
    stop("System prompt file not found: ", prompt_file)
  }

  prompt_text <- readLines(prompt_file, warn = FALSE)
  prompt <- paste(prompt_text, collapse = " ")

  return(prompt)
}

cli::cli_alert_success("All dependencies loaded successfully")
