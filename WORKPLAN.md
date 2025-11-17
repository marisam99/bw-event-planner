# Event Planning Assistant - Workplan

## Project Summary

**Goal**: A Shiny web application that uses AI to assist nontechnical users in creating comprehensive event planning worksheets from Excel templates.

**Target Users**: Individual contributors planning large events (convenings, conferences, workshops) who need structured planning support but lack technical expertise.

**Core Value Proposition**: Transform a basic Excel event template into a detailed, customized planning worksheet through AI assistance, reducing planning overhead and ensuring nothing is overlooked.

---

## Development Phases

### Phase 1: Backend Core Functionality

**Objective**: Build the core R functions that power the tool - AI integration, template processing, and worksheet generation.

#### Deliverables:
1. **Project Structure**
   - `/config` - API keys, model settings, constants
   - `/R` - Main scripts and helper functions
   - `/inputs` - Example Excel templates
   - `/outputs` - Generated worksheets (for testing)
   - `/tests` - Manual test cases and examples

2. **Core R Functions**
   - `config/dependencies.R` - Centralized package loading (shiny, openxlsx, httr2, dplyr, cli, etc.)
   - `config/settings.R` - API configuration, model parameters, prompt templates
   - `R/api_client.R` - Functions to interact with AI model API
   - `R/template_processor.R` - Load and parse Excel templates
   - `R/worksheet_generator.R` - Main logic to generate expanded worksheets
   - `R/output_formatter.R` - Format and export to Excel with styling

3. **Excel Template System**
   - Define expected template structure (columns: category, item, deadline_weeks_before, notes)
   - Read Excel files using `openxlsx` or `readxl`
   - Validate template format and provide helpful error messages
   - Create 1-2 example templates (conference, workshop)

4. **AI Integration**
   - Connect to OpenAI API (ChatGPT 5.1)
   - Implement prompt engineering to expand template items with context
   - Pass event details (name, date, attendee count, budget, type) to personalize output
   - Handle API errors gracefully with fallback messages

5. **Testing with Scripts**
   - Create test script that calls core functions directly
   - Verify Excel input/output workflow works end-to-end
   - Validate formatting, formulas, multi-sheet structure

#### Tasks:
- [ ] Set up project directory structure (config, R, inputs, outputs, tests)
- [ ] Create config/dependencies.R with all required packages
- [ ] Create config/settings.R with API configuration and prompt templates
- [ ] Create .Renviron file for API key storage (git-ignored)
- [ ] Build R/api_client.R to connect to OpenAI ChatGPT 5.1 API
- [ ] Build R/template_processor.R to read and validate Excel templates
- [ ] Create 1-2 example Excel templates (conference, workshop)
- [ ] Build R/worksheet_generator.R with core generation logic
- [ ] Build R/output_formatter.R to format and export Excel
- [ ] Develop prompt engineering strategy for template expansion
- [ ] Create test script to verify end-to-end workflow
- [ ] Test with multiple template variations
- [ ] Document code following standards (headers, sections, comments)

---

### Phase 2: Basic Shiny Interface

**Objective**: Create a simple, functional web interface that allows users to upload templates and download generated worksheets.

#### Deliverables:
1. **UI Layout**
   - Clean, single-page layout with logical sections
   - File upload widget for Excel template
   - Input fields for event details (name, date, attendee count, budget range, event type)
   - Generate button
   - Download button for completed worksheet
   - Progress indicators during AI generation

2. **Server Logic**
   - Handle file upload and validate Excel format
   - Collect user inputs and validate
   - Call backend functions from Phase 1
   - Display progress/status messages
   - Provide download handler for Excel output

3. **Basic Error Handling**
   - Clear error messages for invalid uploads
   - API failure handling with user-friendly notifications
   - Input validation feedback

4. **Styling**
   - Clean, professional appearance (bslib or shinydashboard)
   - Responsive layout
   - Bellwether branding (optional)

#### Tasks:
- [ ] Create app.R file with basic Shiny structure
- [ ] Design UI layout with sections for upload, inputs, and output
- [ ] Add file upload widget for Excel templates
- [ ] Add input fields (event name, date, attendee count, budget range, event type)
- [ ] Add generate button with appropriate styling
- [ ] Add download button for completed worksheets
- [ ] Implement file upload handler and Excel validation
- [ ] Implement input validation with user-friendly feedback
- [ ] Connect UI to backend functions from Phase 1
- [ ] Add progress indicators during AI generation
- [ ] Implement error handling for API failures
- [ ] Implement error handling for invalid uploads
- [ ] Add styling with bslib or shinydashboard
- [ ] Test locally with example templates and inputs
- [ ] Verify download functionality works correctly

---

### Phase 3: Enhanced UX & Features

**Objective**: Polish the user experience and add features that make the tool more flexible and powerful.

#### Deliverables:
1. **Template Library**
   - Pre-loaded template options (conference, workshop, virtual event, networking event)
   - Users can select from library OR upload custom template
   - Template preview before generation

2. **Improved Input Experience**
   - Event type dropdown with descriptions
   - Date picker for event date
   - Budget slider or range input
   - Optional fields for venue type, audience, special requirements
   - Tooltips/help text for each field

3. **Better Output Formatting**
   - Conditional formatting in Excel (highlight deadlines, budget items)
   - Auto-calculated formulas (budget totals, days until deadline)
   - Professional styling (headers, colors, fonts)
   - Include metadata sheet with generation details

4. **Iterative Refinement (Optional)**
   - Preview generated worksheet in-app
   - Option to regenerate specific sections
   - Custom instructions field for additional AI guidance

5. **User Feedback**
   - Satisfaction rating after generation
   - Optional comments/suggestions
   - Log usage for improvement insights

#### Tasks:
- [ ] Create pre-loaded template library (conference, workshop, virtual event, networking event)
- [ ] Add UI option to select from library OR upload custom template
- [ ] Implement template preview functionality
- [ ] Enhance event type dropdown with descriptions
- [ ] Replace text input with date picker for event date
- [ ] Add budget slider or range input widget
- [ ] Add optional fields (venue type, audience, special requirements)
- [ ] Add tooltips/help text for each input field
- [ ] Implement conditional formatting in Excel output (deadlines, budget)
- [ ] Add auto-calculated formulas (budget totals, days until deadline)
- [ ] Enhance Excel styling (headers, colors, fonts)
- [ ] Add metadata sheet with generation details
- [ ] (Optional) Add in-app preview of generated worksheet
- [ ] (Optional) Add option to regenerate specific sections
- [ ] (Optional) Add custom instructions field for additional AI guidance
- [ ] (Optional) Add satisfaction rating after generation
- [ ] (Optional) Add comments/suggestions collection
- [ ] (Optional) Implement usage logging

---

## Technical Stack (Proposed)

### Core Dependencies
- **shiny** - Web application framework
- **bslib** or **shinydashboard** - UI theming and layout
- **httr2** - API communication with AI service
- **jsonlite** - JSON parsing for API responses
- **dplyr**, **tidyr**, **purrr** - Data manipulation
- **openxlsx** - Excel reading/writing with formatting support (preferred over readxl/writexl for styling)
- **glue** - String interpolation for prompts
- **shinyWidgets** - Enhanced input widgets (optional)
- **waiter** or **shinycssloaders** - Loading indicators

### AI Model
- **OpenAI ChatGPT 5.1** - Primary model for prompt processing and content generation

### Configuration Management
- `.Renviron` file for API keys (git-ignored)
- Environment variables for sensitive data
- `config/settings.R` for app-level configurations

---

## Key Design Decisions

### 1. Excel-Based Templates
Use Excel (.xlsx) files as both input templates and output format:
- Familiar format for nontechnical users
- Supports multi-sheet workbooks for organization
- Allows formatting, formulas, and conditional styling
- Easy to edit post-generation in Excel

### 2. Template-First Approach
Rather than generating plans from scratch, start with structured templates:
- Ensures consistency across events
- Makes output predictable and trustworthy
- Allows organizations to encode their standards
- Reduces AI hallucination risk

### 3. Shiny Web Interface
Web-based UI instead of CLI or R package:
- No R knowledge required for end users
- Can be deployed to server for team access
- Interactive, visual experience
- Easier to add features like file upload/download

### 4. Progressive Development
Build backend functions first, then add UI:
- Core logic can be tested independently
- UI can iterate without touching backend
- Easier to maintain and debug

### 5. Human-in-the-Loop
AI assists but doesn't replace human judgment:
- Generated content is always downloadable for review
- Users maintain full control over final worksheet
- Clear about what AI is doing during generation

---

## Risk Mitigation

### Technical Risks
- **API costs**: Implement token counting, set reasonable limits, monitor usage
- **API reliability**: Graceful error handling, retry logic with backoff, clear user messaging
- **Output quality**: Extensive prompt testing, example templates, iterative refinement
- **Excel compatibility**: Test across Excel versions (Office 365, 2019, 2016)

### User Adoption Risks
- **Complexity**: Keep initial interface extremely simple (upload, fill form, download)
- **Trust**: Provide example templates and outputs, show before/after comparison
- **Template creation**: Clear documentation with examples of good template structure

### Data/Privacy Risks
- **Sensitive information**: Document what gets sent to AI (template + basic event details only)
- **API key security**: Use .Renviron (git-ignored), clear setup instructions
- **Data retention**: Understand and document AI provider's data policies
- **File uploads**: Ensure uploaded files aren't permanently stored on server

---

## Appendix: Example Workflows

### End User Experience (Phase 2+)

1. **Launch the app**
   ```r
   # In R console or RStudio
   shiny::runApp("app.R")
   ```

2. **In the browser**
   - Upload Excel template (or select from pre-loaded templates)
   - Fill in form:
     - Event name: "Annual Research Symposium 2025"
     - Event date: June 15, 2025
     - Attendee count: 150
     - Budget range: $25,000 - $30,000
     - Event type: Conference
   - Click "Generate Plan"
   - Wait for AI processing (progress bar shows status)
   - Click "Download" to get completed Excel worksheet

3. **Review output**
   - Open downloaded Excel file
   - Review multiple sheets: Overview, Timeline, Budget, Logistics
   - Make any manual edits as needed
   - Share with team

### Developer Experience (Testing Backend - Phase 1)

```r
# Load dependencies and functions
source("config/dependencies.R")
source("config/settings.R")
source("R/api_client.R")
source("R/template_processor.R")
source("R/worksheet_generator.R")
source("R/output_formatter.R")

# Test workflow
template <- read_template("inputs/conference_template.xlsx")
event_details <- list(
  name = "Annual Research Symposium 2025",
  date = "2025-06-15",
  attendee_count = 150,
  budget_range = "$25,000 - $30,000",
  event_type = "conference"
)

worksheet <- generate_worksheet(template, event_details)
save_worksheet(worksheet, "outputs/test_output.xlsx")

# ✅ Worksheet generated successfully!
```

### Creating Custom Template

1. **Create Excel file with these columns** (on first sheet):
   - `category` - Section name (e.g., "Venue", "Catering", "Marketing")
   - `item` - Task description (e.g., "Book conference room")
   - `deadline_weeks_before` - Numeric value (e.g., 12 for 12 weeks before event)
   - `notes` - Optional context for AI to expand upon

2. **Example rows**:
   | category | item | deadline_weeks_before | notes |
   |----------|------|----------------------|-------|
   | Venue | Book conference room | 12 | Consider capacity, AV needs, accessibility |
   | Catering | Select catering vendor | 8 | Get quotes from 3 vendors, check dietary options |
   | Marketing | Design event website | 10 | Include registration form, agenda, speaker bios |

3. **Save as** `inputs/my_custom_template.xlsx`

4. **Upload in app** or place in template library folder

---

**Document Version**: 2.0
**Last Updated**: 2025-11-17
**Status**: Revised - Focused on Shiny app development
