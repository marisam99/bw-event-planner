# ============================================================================
# dependencies.R
# ============================================================================
# Description: Centralized package loading for Event Planning Assistant
# Author: Bellwether Analytics
# Date: 2025-11-18
# ============================================================================

# Core Shiny packages
library(shiny)           # Web application framework
library(bslib)           # Modern UI theming and layout

# Data manipulation
library(dplyr)           # Data manipulation
library(tidyr)           # Data tidying
library(purrr)           # Functional programming tools

# Excel operations
library(openxlsx)        # Excel reading/writing with formatting support

# API communication
library(httr2)           # Modern HTTP client for API calls
library(jsonlite)        # JSON parsing

# String manipulation and prompts
library(glue)            # String interpolation

# UI enhancements (optional, load if available)
if (requireNamespace("shinyWidgets", quietly = TRUE)) {
  library(shinyWidgets)  # Enhanced input widgets
}

if (requireNamespace("waiter", quietly = TRUE)) {
  library(waiter)        # Loading indicators
}

# Utility
library(cli)             # Command line interface helpers

# Message on successful load
cli::cli_alert_success("All dependencies loaded successfully")

# ============================================================================
# Package version information
# ============================================================================
# Run this block to check installed versions:
# packageVersion("shiny")
# packageVersion("openxlsx")
# packageVersion("httr2")
# ============================================================================
