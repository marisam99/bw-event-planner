# api_client.R
# Description: Functions to interact with OpenAI ChatGPT 5.1 API. Handles API authentication, request formatting, error handling with retry logic, and batch processing of template items.
# Output: API responses, expanded content strings, batch-processed data frames

# ============================================================================
# Main API Functions
# ============================================================================

#' Call OpenAI ChatGPT API
#'
#' @param prompt Character string with the user prompt
#' @param system_prompt Character string with system instructions (optional)
#' @param model Character string specifying the model (default from config)
#' @param temperature Numeric value 0-1 controlling randomness (default from config)
#' @param max_tokens Integer maximum tokens in response (default from config)
#'
#' @return Character string with API response content
#' @export
call_chatgpt_api <- function(prompt,
                               system_prompt = SYSTEM_PROMPT,
                               model = API_CONFIG$model,
                               temperature = API_CONFIG$temperature,
                               max_tokens = API_CONFIG$max_tokens) {

  # Get API key
  api_key <- get_api_key()

  # Build messages array
  messages <- list()

  if (!is.null(system_prompt) && nchar(system_prompt) > 0) {
    messages[[length(messages) + 1]] <- list(
      role = "system",
      content = system_prompt
    )
  }

  messages[[length(messages) + 1]] <- list(
    role = "user",
    content = prompt
  )

  # Prepare request body
  body <- list(
    model = model,
    messages = messages,
    temperature = temperature,
    max_tokens = max_tokens
  )

  # Make API request with error handling
  tryCatch({
    response <- httr2::request(paste0(API_CONFIG$base_url, "/chat/completions")) |>
      httr2::req_headers(
        "Authorization" = paste("Bearer", api_key),
        "Content-Type" = "application/json"
      ) |>
      httr2::req_body_json(body) |>
      httr2::req_timeout(API_CONFIG$timeout_seconds) |>
      httr2::req_retry(
        max_tries = as.numeric(Sys.getenv("MAX_API_RETRIES", "3")),
        max_seconds = 30
      ) |>
      httr2::req_perform()

    # Parse response
    response_data <- response |>
      httr2::resp_body_json()

    # Extract content
    content <- response_data$choices[[1]]$message$content

    # Log token usage if in debug mode
    if (Sys.getenv("DEBUG_MODE", "FALSE") == "TRUE") {
      cli::cli_alert_info(
        "Tokens used: {response_data$usage$total_tokens} (prompt: {response_data$usage$prompt_tokens}, completion: {response_data$usage$completion_tokens})"
      )
    }

    return(content)

  }, error = function(e) {
    # Enhanced error handling
    error_message <- conditionMessage(e)

    if (grepl("401", error_message)) {
      stop("API Authentication Error: Invalid API key. Please check your OPENAI_API_KEY in .Renviron")
    } else if (grepl("429", error_message)) {
      stop("API Rate Limit Error: Too many requests. Please wait and try again.")
    } else if (grepl("timeout", error_message, ignore.case = TRUE)) {
      stop("API Timeout Error: Request took too long. Please try again.")
    } else {
      stop(paste("API Error:", error_message))
    }
  })
}

#' Expand a single template item using AI
#'
#' @param item List containing category, item, deadline_weeks_before, notes
#' @param event_details List containing event information
#'
#' @return Character string with expanded content
#' @export
expand_template_item <- function(item, event_details) {

  # Format prompt using template
  prompt <- format_prompt(
    EXPANSION_PROMPT_TEMPLATE,
    event_name = event_details$name,
    event_date = event_details$date,
    attendee_count = event_details$attendee_count,
    budget_range = event_details$budget_range,
    event_type = event_details$event_type,
    category = item$category,
    item = item$item,
    deadline_weeks_before = item$deadline_weeks_before,
    notes = ifelse(is.na(item$notes) || item$notes == "", "No additional context", item$notes)
  )

  # Call API
  response <- call_chatgpt_api(prompt)

  return(response)
}

#' Generate category summary using AI
#'
#' @param category Character string with category name
#' @param event_details List containing event information
#'
#' @return Character string with category summary
#' @export
generate_category_summary <- function(category, event_details) {

  # Format prompt using template
  prompt <- format_prompt(
    CATEGORY_SUMMARY_PROMPT_TEMPLATE,
    category = category,
    event_type = event_details$event_type,
    attendee_count = event_details$attendee_count,
    budget_range = event_details$budget_range
  )

  # Call API
  response <- call_chatgpt_api(prompt)

  return(response)
}

#' Test API connection
#'
#' @return Logical TRUE if connection successful, FALSE otherwise
#' @export
test_api_connection <- function() {
  tryCatch({
    response <- call_chatgpt_api(
      "Say 'Connection successful' if you can read this.",
      max_tokens = 50
    )

    cli::cli_alert_success("API connection test successful")
    cli::cli_alert_info("Response: {response}")

    return(TRUE)

  }, error = function(e) {
    cli::cli_alert_danger("API connection test failed: {conditionMessage(e)}")
    return(FALSE)
  })
}

# ============================================================================
# Batch Processing Functions
# ============================================================================

#' Expand multiple template items with progress tracking
#'
#' @param items Data frame with template items
#' @param event_details List containing event information
#' @param progress Optional progress callback function
#'
#' @return Data frame with expanded_content column added
#' @export
expand_template_items_batch <- function(items, event_details, progress = NULL) {

  n_items <- nrow(items)

  cli::cli_alert_info("Expanding {n_items} template items...")

  # Add expanded_content column
  items$expanded_content <- NA_character_

  # Process each item
  for (i in 1:n_items) {
    # Update progress
    if (!is.null(progress)) {
      progress(i / n_items, detail = paste("Processing item", i, "of", n_items))
    }

    # Expand item
    tryCatch({
      items$expanded_content[i] <- expand_template_item(
        list(
          category = items$category[i],
          item = items$item[i],
          deadline_weeks_before = items$deadline_weeks_before[i],
          notes = items$notes[i]
        ),
        event_details
      )

      cli::cli_alert_success("Expanded: {items$item[i]}")

    }, error = function(e) {
      cli::cli_alert_warning("Failed to expand '{items$item[i]}': {conditionMessage(e)}")
      items$expanded_content[i] <<- paste("Error:", conditionMessage(e))
    })

    # Small delay to avoid rate limiting
    Sys.sleep(0.5)
  }

  cli::cli_alert_success("Batch expansion complete")

  return(items)
}

# ============================================================================
# API client loaded
# ============================================================================

cli::cli_alert_success("API client functions loaded")
