# test_workflow.R
# Description: Comprehensive test suite to verify end-to-end workflow. Tests configuration, template reading, API connection, and full worksheet generation with and without AI expansion.
# Output: Test results printed to console, example Excel files in outputs/

# ============================================================================
# Setup
# ============================================================================

cat("\n")
cat("======================================\n")
cat("Event Planning Assistant - Test Suite\n")
cat("======================================\n\n")

# Load dependencies
cat("Loading dependencies...\n")
source("config/dependencies.R")
source("config/settings.R")

# Load functions
cat("Loading functions...\n")
source("R/api_client.R")
source("R/template_processor.R")
source("R/worksheet_generator.R")
source("R/output_formatter.R")

cat("\n")

# ============================================================================
# Test 1: Configuration and Setup
# ============================================================================

cat("TEST 1: Configuration and Setup\n")
cat("--------------------------------\n")

# Check if API key is set
tryCatch({
  api_key <- get_api_key()
  if (nchar(api_key) > 0) {
    cat("✓ API key found\n")
  }
}, error = function(e) {
  cat("✗ API key not found - Please set OPENAI_API_KEY in .Renviron\n")
  cat("  Error:", conditionMessage(e), "\n")
})

# Check directories
dirs_to_check <- c("config", "R", "inputs", "outputs", "tests")
for (dir in dirs_to_check) {
  if (dir.exists(dir)) {
    cat("✓ Directory exists:", dir, "\n")
  } else {
    cat("✗ Directory missing:", dir, "\n")
  }
}

cat("\n")

# ============================================================================
# Test 2: Template Discovery and Reading
# ============================================================================

cat("TEST 2: Template Discovery and Reading\n")
cat("---------------------------------------\n")

# List available templates
templates <- list_templates("inputs")

if (length(templates) > 0) {
  cat("✓ Found", length(templates), "template(s)\n")

  for (template_path in templates) {
    cat("\nTesting template:", basename(template_path), "\n")

    # Read template
    tryCatch({
      template_data <- read_template(template_path)
      cat("✓ Template read successfully\n")
      cat("  - Rows:", nrow(template_data), "\n")
      cat("  - Categories:", length(unique(template_data$category)), "\n")

      # Print summary
      print_template_summary(template_data)

    }, error = function(e) {
      cat("✗ Error reading template:", conditionMessage(e), "\n")
    })
  }
} else {
  cat("✗ No templates found\n")
  cat("  Run scripts/create_example_templates.R to create example templates\n")
}

cat("\n")

# ============================================================================
# Test 3: API Connection (Optional - requires valid API key)
# ============================================================================

cat("TEST 3: API Connection Test\n")
cat("----------------------------\n")
cat("Testing connection to OpenAI API...\n")

tryCatch({
  result <- test_api_connection()
  if (result) {
    cat("✓ API connection successful\n")
  }
}, error = function(e) {
  cat("✗ API connection failed\n")
  cat("  Error:", conditionMessage(e), "\n")
  cat("  Note: This is optional for basic testing\n")
})

cat("\n")

# ============================================================================
# Test 4: End-to-End Workflow (Without AI)
# ============================================================================

cat("TEST 4: End-to-End Workflow (Without AI)\n")
cat("-----------------------------------------\n")

if (length(templates) > 0) {
  # Use first template
  test_template_path <- templates[1]
  cat("Using template:", basename(test_template_path), "\n\n")

  tryCatch({
    # Read template
    template_data <- read_template(test_template_path)
    cat("✓ Step 1: Template loaded\n")

    # Define event details
    event_details <- list(
      name = "Annual Research Symposium 2025",
      date = "2025-06-15",
      attendee_count = 150,
      budget_range = "$25,000 - $30,000",
      event_type = "Conference"
    )

    cat("✓ Step 2: Event details defined\n")

    # Validate event details
    validate_event_details(event_details)
    cat("✓ Step 3: Event details validated\n")

    # Generate worksheet (without AI expansion)
    cat("\nGenerating worksheet without AI expansion...\n")
    worksheet <- generate_worksheet(
      template_data,
      event_details,
      expand_items = FALSE  # Skip AI to test basic workflow
    )
    cat("✓ Step 4: Worksheet generated\n")

    # Validate worksheet
    validate_worksheet(worksheet)
    cat("✓ Step 5: Worksheet validated\n")

    # Print summary
    print_worksheet_summary(worksheet)

    # Save worksheet
    output_path <- "outputs/test_output.xlsx"
    save_worksheet(worksheet, output_path)
    cat("✓ Step 6: Worksheet saved to", output_path, "\n")

    # Verify file exists
    if (file.exists(output_path)) {
      file_size <- file.info(output_path)$size
      cat("✓ Step 7: Output file verified (", round(file_size/1024, 1), " KB)\n", sep = "")
    }

    cat("\n✓✓✓ END-TO-END TEST PASSED ✓✓✓\n")

  }, error = function(e) {
    cat("✗ End-to-end test failed\n")
    cat("  Error:", conditionMessage(e), "\n")
    traceback()
  })

} else {
  cat("✗ Cannot run end-to-end test - no templates available\n")
}

cat("\n")

# ============================================================================
# Test 5: End-to-End Workflow (With AI) - Optional
# ============================================================================

cat("TEST 5: End-to-End Workflow (With AI) - OPTIONAL\n")
cat("-------------------------------------------------\n")
cat("This test requires a valid OpenAI API key and will make API calls.\n")
cat("It will expand 2 items from the template using AI.\n\n")

run_ai_test <- readline(prompt = "Run AI expansion test? (y/n): ")

if (tolower(run_ai_test) == "y" && length(templates) > 0) {

  tryCatch({
    # Read template
    template_data <- read_template(templates[1])

    # Limit to first 2 items for testing
    template_data_subset <- template_data[1:min(2, nrow(template_data)), ]

    cat("\nTesting with", nrow(template_data_subset), "items...\n\n")

    # Define event details
    event_details <- list(
      name = "Tech Innovation Summit 2025",
      date = "2025-08-20",
      attendee_count = 200,
      budget_range = "$50,000 - $75,000",
      event_type = "Conference"
    )

    # Generate worksheet with AI expansion
    worksheet_ai <- generate_worksheet(
      template_data_subset,
      event_details,
      expand_items = TRUE
    )

    # Save worksheet
    output_path_ai <- "outputs/test_output_with_ai.xlsx"
    save_worksheet(worksheet_ai, output_path_ai)

    cat("\n✓✓✓ AI EXPANSION TEST PASSED ✓✓✓\n")
    cat("Check", output_path_ai, "to see AI-generated content\n")

  }, error = function(e) {
    cat("✗ AI expansion test failed\n")
    cat("  Error:", conditionMessage(e), "\n")
  })

} else {
  cat("Skipping AI expansion test\n")
}

cat("\n")

# ============================================================================
# Summary
# ============================================================================

cat("======================================\n")
cat("Test Suite Complete\n")
cat("======================================\n\n")

cat("Next steps:\n")
cat("1. Review generated outputs in outputs/ directory\n")
cat("2. Verify Excel files open correctly\n")
cat("3. Check formatting and data integrity\n")
cat("4. If AI test passed, review AI-generated content quality\n")
cat("5. Proceed to Phase 2: Shiny Interface Development\n\n")
