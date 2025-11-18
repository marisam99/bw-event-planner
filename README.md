# Event Planning Assistant

An AI-powered Shiny web application that helps nontechnical users create comprehensive event planning worksheets from Excel templates.

## Overview

The Event Planning Assistant transforms basic Excel event templates into detailed, customized planning worksheets through AI assistance. It reduces planning overhead and ensures nothing is overlooked when organizing large events like conferences, workshops, and convenings.

**Current Status**: Phase 1 Complete - Backend Core Functionality ✓

## Features

- **Excel-Based Templates**: Use familiar Excel format for both input and output
- **AI-Powered Expansion**: ChatGPT 5.1 expands template items with detailed recommendations
- **Professional Formatting**: Auto-formatted Excel outputs with conditional formatting
- **Multi-Sheet Workbooks**: Organized views including timeline, budget, and metadata
- **Flexible Templates**: Support for custom templates or use pre-built examples

## Project Structure

```
bw-event-planner/
├── config/              # Configuration files
│   ├── dependencies.R   # Package loading
│   └── settings.R       # API config and prompt templates
├── R/                   # Core R functions
│   ├── api_client.R         # OpenAI API integration
│   ├── template_processor.R # Excel template reading/validation
│   ├── worksheet_generator.R # Main generation logic
│   └── output_formatter.R   # Excel formatting and export
├── inputs/              # Excel template files
│   ├── conference_template.xlsx
│   ├── workshop_template.xlsx
│   └── template_event.xlsx
├── outputs/             # Generated worksheets (git-ignored)
├── tests/               # Test scripts
│   └── test_workflow.R  # End-to-end testing
├── scripts/             # Utility scripts
│   └── create_example_templates.R
├── .Renviron            # API keys (git-ignored)
├── .Renviron.template   # Template for API key setup
└── WORKPLAN.md          # Detailed project workplan
```

## Prerequisites

### Required Software
- **R** (version 4.0 or higher)
- **RStudio** (recommended)

### Required R Packages
```r
install.packages(c(
  "shiny",       # Web application framework
  "bslib",       # UI theming
  "dplyr",       # Data manipulation
  "tidyr",       # Data tidying
  "purrr",       # Functional programming
  "openxlsx",    # Excel operations
  "httr2",       # API communication
  "jsonlite",    # JSON parsing
  "glue",        # String interpolation
  "cli"          # Command line interface
))

# Optional packages
install.packages(c("shinyWidgets", "waiter"))
```

### OpenAI API Access
- An OpenAI API key with access to ChatGPT 5.1
- Get your key at: https://platform.openai.com/api-keys

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd bw-event-planner
```

### 2. Install R Packages
Open R or RStudio and run:
```r
source("config/dependencies.R")
```

### 3. Configure API Key
1. Copy the template file:
   ```r
   file.copy(".Renviron.template", ".Renviron")
   ```

2. Edit `.Renviron` and add your OpenAI API key:
   ```
   OPENAI_API_KEY=your_actual_api_key_here
   ```

3. Restart R session for changes to take effect

### 4. Create Example Templates
Generate example templates (conference and workshop):
```r
source("scripts/create_example_templates.R")
```

This creates:
- `inputs/conference_template.xlsx` - Template for conferences (24 items)
- `inputs/workshop_template.xlsx` - Template for workshops (17 items)

### 5. Run Tests
Verify everything works:
```r
source("tests/test_workflow.R")
```

The test suite will:
- ✓ Check configuration and API key
- ✓ Test template reading and validation
- ✓ Test API connection
- ✓ Run end-to-end workflow without AI
- ✓ Optionally test with AI expansion

## Usage

### Basic Workflow (R Console)

```r
# Load all dependencies and functions
source("config/dependencies.R")
source("config/settings.R")
source("R/api_client.R")
source("R/template_processor.R")
source("R/worksheet_generator.R")
source("R/output_formatter.R")

# Step 1: Read template
template <- read_template("inputs/conference_template.xlsx")

# Step 2: Define event details
event_details <- list(
  name = "Annual Research Symposium 2025",
  date = "2025-06-15",
  attendee_count = 150,
  budget_range = "$25,000 - $30,000",
  event_type = "Conference"
)

# Step 3: Generate worksheet with AI expansion
worksheet <- generate_worksheet(template, event_details, expand_items = TRUE)

# Step 4: Save to Excel
save_worksheet(worksheet, "outputs/research_symposium_plan.xlsx")

# Or use quick export with auto-generated filename
quick_export(worksheet, event_details$name)
```

### Without AI Expansion

For testing or if you don't want AI recommendations:
```r
worksheet <- generate_worksheet(template, event_details, expand_items = FALSE)
```

## Template Format

Excel templates must include these columns:

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `category` | Text | Yes | Planning category (e.g., "Venue", "Catering") |
| `item` | Text | Yes | Task description |
| `deadline_weeks_before` | Number | Yes | Weeks before event date |
| `notes` | Text | No | Context for AI to expand upon |
| `budget_estimate` | Number | No | Estimated cost |
| `responsible_party` | Text | No | Who is responsible |
| `priority` | Text | No | Priority level |

### Example Template Row
```
category: Venue
item: Book conference room
deadline_weeks_before: 12
notes: Consider capacity for 150+ attendees, AV capabilities, accessibility
```

## Output Format

Generated worksheets include multiple sheets:

1. **Event Planning Worksheet** - Main view with all tasks, deadlines, and AI recommendations
2. **Timeline View** - Chronological view sorted by deadline with priority flags
3. **Budget Summary** - Budget breakdown by category
4. **Generation Details** - Metadata about the generated worksheet

Features:
- Conditional formatting for deadlines and priorities
- Auto-calculated deadline dates
- Professional styling with headers and colors
- Frozen header rows for easy scrolling

## API Configuration

### Model Settings
Located in `config/settings.R`:
- **Model**: chatgpt-5.1
- **Max Tokens**: 4000
- **Temperature**: 0.7
- **Timeout**: 120 seconds

### Prompt Engineering
The system uses carefully crafted prompts to:
- Expand template items with 3-5 specific action items
- Identify key considerations and challenges
- Recommend resources and vendors
- Estimate budget ranges
- Note dependencies and prerequisites

Modify prompts in `config/settings.R` under `EXPANSION_PROMPT_TEMPLATE`.

## Core Functions Reference

### Template Processing
```r
# Read and validate template
template <- read_template("path/to/template.xlsx")

# Get template summary
summary <- get_template_summary(template)
print_template_summary(template)

# List available templates
templates <- list_templates("inputs")
display_available_templates("inputs")
```

### Worksheet Generation
```r
# Generate complete worksheet
worksheet <- generate_worksheet(template, event_details, expand_items = TRUE)

# Validate worksheet structure
validate_worksheet(worksheet)

# Get worksheet summary
print_worksheet_summary(worksheet)
```

### Output & Export
```r
# Save with formatting
save_worksheet(worksheet, "outputs/my_event.xlsx")

# Quick export with auto-filename
quick_export(worksheet, "Event Name")

# Export with custom filename
export_as(worksheet, "custom_name", output_dir = "outputs")
```

### API Functions
```r
# Test API connection
test_api_connection()

# Expand single item
expanded <- expand_template_item(item, event_details)

# Batch expansion with progress
expanded_data <- expand_template_items_batch(items, event_details)

# Generate category summary
summary <- generate_category_summary("Venue", event_details)
```

## Development Roadmap

### ✅ Phase 1: Backend Core Functionality (COMPLETE)
- [x] Project structure setup
- [x] Configuration management
- [x] API integration with ChatGPT 5.1
- [x] Template processing system
- [x] Worksheet generation logic
- [x] Excel formatting and export
- [x] Example templates
- [x] Comprehensive testing

### 🚧 Phase 2: Basic Shiny Interface (NEXT)
- [ ] UI layout design
- [ ] File upload functionality
- [ ] Input forms for event details
- [ ] Progress indicators
- [ ] Download functionality
- [ ] Error handling
- [ ] Basic styling

### 📋 Phase 3: Enhanced UX & Features (PLANNED)
- [ ] Template library
- [ ] Improved input widgets
- [ ] Advanced Excel formatting
- [ ] In-app preview
- [ ] User feedback collection

## Troubleshooting

### API Key Issues
```
Error: OPENAI_API_KEY not found
```
**Solution**: Ensure `.Renviron` file exists with valid API key, then restart R session.

### Template Validation Errors
```
Error: Template is missing required columns
```
**Solution**: Verify template has columns: category, item, deadline_weeks_before, notes

### Package Installation Issues
```
Error: package 'httr2' is not available
```
**Solution**: Update R to version 4.0+ and install from CRAN:
```r
install.packages("httr2")
```

### API Connection Failures
```
Error: API Authentication Error
```
**Solution**:
1. Verify API key is correct
2. Check OpenAI account has available credits
3. Ensure internet connection is working

## Best Practices

### Template Design
- Use clear, specific task descriptions
- Group related tasks into logical categories
- Set realistic deadlines (in weeks before event)
- Provide context in notes for better AI expansion
- Include 15-30 items for comprehensive planning

### Event Details
- Use specific dates (YYYY-MM-DD format)
- Provide accurate attendee counts
- Be specific with budget ranges
- Choose appropriate event type

### AI Expansion
- Review AI-generated content before finalizing
- Edit recommendations to match your specific needs
- Use AI suggestions as starting points, not final solutions
- Consider organization-specific requirements

## Contributing

This is an internal Bellwether Analytics project. For questions or suggestions:
- Review the WORKPLAN.md for detailed specifications
- Check existing issues before creating new ones
- Follow R coding standards and style guides

## Testing

### Run Full Test Suite
```r
source("tests/test_workflow.R")
```

### Quick Tests
```r
# Test template reading
template <- read_template("inputs/conference_template.xlsx")
print_template_summary(template)

# Test without API
worksheet <- generate_worksheet(template, event_details, expand_items = FALSE)
save_worksheet(worksheet, "outputs/test.xlsx")

# Test API only
test_api_connection()
```

## Performance Notes

### API Costs
- Each template item expansion = 1 API call
- Typical conference template (24 items) ≈ 24 API calls
- Estimated cost per template: $0.50 - $2.00 (varies by model pricing)

### Processing Time
- Without AI: < 5 seconds
- With AI expansion: ~1-2 seconds per item + network latency
- Typical 24-item template: 30-60 seconds

### Rate Limits
- Built-in retry logic with exponential backoff
- 0.5 second delay between API calls to avoid rate limiting
- Configurable in `R/api_client.R`

## Security Notes

- `.Renviron` is git-ignored to protect API keys
- Never commit API keys to version control
- Templates and outputs may contain event details - handle appropriately
- API calls send template content to OpenAI - review privacy policies

## License

Internal Bellwether Analytics project. All rights reserved.

## Support

For technical support:
- Check documentation in `WORKPLAN.md`
- Review function documentation in R files
- Run test suite to diagnose issues

---

**Version**: 1.0.0 (Phase 1 Complete)
**Last Updated**: 2025-11-18
**Status**: Backend Complete, Ready for Phase 2
