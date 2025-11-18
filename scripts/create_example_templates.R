# ============================================================================
# create_example_templates.R
# ============================================================================
# Description: Script to create example Excel templates
# Author: Bellwether Analytics
# Date: 2025-11-18
# ============================================================================

# Load required package
library(openxlsx)

# ============================================================================
# Conference Template
# ============================================================================

conference_template <- data.frame(
  category = c(
    "Venue", "Venue", "Venue",
    "Catering", "Catering", "Catering",
    "Marketing", "Marketing", "Marketing", "Marketing",
    "Speakers", "Speakers", "Speakers",
    "Registration", "Registration", "Registration",
    "Technology", "Technology", "Technology",
    "Materials", "Materials",
    "Logistics", "Logistics", "Logistics"
  ),
  item = c(
    # Venue
    "Book main conference venue",
    "Arrange breakout rooms",
    "Conduct venue walkthrough",
    # Catering
    "Select catering vendor",
    "Finalize menu and dietary options",
    "Confirm final headcount with caterer",
    # Marketing
    "Design event website and registration page",
    "Create promotional materials",
    "Launch social media campaign",
    "Send final event reminders",
    # Speakers
    "Confirm keynote speakers",
    "Collect speaker bios and photos",
    "Conduct speaker tech checks",
    # Registration
    "Set up registration system",
    "Send confirmation emails to registrants",
    "Prepare name badges and materials",
    # Technology
    "Arrange AV equipment rental",
    "Test presentation systems",
    "Prepare backup tech solutions",
    # Materials
    "Print conference programs",
    "Prepare attendee swag bags",
    # Logistics
    "Arrange parking and transportation",
    "Coordinate volunteer schedule",
    "Create day-of event timeline"
  ),
  deadline_weeks_before = c(
    # Venue
    16, 12, 2,
    # Catering
    12, 6, 2,
    # Marketing
    14, 10, 8, 1,
    # Speakers
    20, 8, 2,
    # Registration
    12, 3, 1,
    # Technology
    8, 1, 1,
    # Materials
    4, 2,
    # Logistics
    6, 3, 2
  ),
  notes = c(
    # Venue
    "Consider capacity for 150+ attendees, AV capabilities, accessibility",
    "Need 3-4 rooms for concurrent sessions",
    "Verify setup, emergency exits, accessibility features",
    # Catering
    "Get quotes from 3 vendors, ensure variety of options",
    "Include vegetarian, vegan, gluten-free, and allergy-friendly options",
    "Account for 10% buffer in headcount",
    # Marketing
    "Include agenda, speaker bios, registration form, hotel info",
    "Flyers, social media graphics, email templates",
    "LinkedIn, Twitter, relevant professional groups",
    "One week before and one day before event",
    # Speakers
    "Secure commitments with contracts",
    "High-resolution photos, 100-word bios",
    "Confirm presentation format, screen sharing, Q&A setup",
    # Registration
    "Use platform like Eventbrite or custom solution",
    "Include event details, parking, agenda",
    "Print on cardstock with lanyards",
    # Technology
    "Projectors, microphones, screens, laptops",
    "Day before event, verify all systems operational",
    "Extra adapters, batteries, spare laptop",
    # Materials
    "Design professionally, include sponsor logos",
    "Pens, notepads, USB drives, promotional items",
    # Logistics
    "Provide clear directions, arrange shuttle if needed",
    "Assign roles: registration desk, room monitors, AV support",
    "Minute-by-minute schedule for staff"
  ),
  stringsAsFactors = FALSE
)

# Save conference template
wb_conf <- createWorkbook()
addWorksheet(wb_conf, "Template")
writeData(wb_conf, "Template", conference_template)

# Format header
header_style <- createStyle(
  fontSize = 12,
  fontColour = "white",
  fgFill = "steelblue",
  halign = "center",
  textDecoration = "bold"
)

addStyle(
  wb_conf,
  "Template",
  style = header_style,
  rows = 1,
  cols = 1:ncol(conference_template),
  gridExpand = TRUE
)

setColWidths(wb_conf, "Template", cols = 1:ncol(conference_template), widths = "auto")
freezePane(wb_conf, "Template", firstRow = TRUE)

saveWorkbook(wb_conf, "inputs/conference_template.xlsx", overwrite = TRUE)

cat("✓ Created: inputs/conference_template.xlsx\n")

# ============================================================================
# Workshop Template
# ============================================================================

workshop_template <- data.frame(
  category = c(
    "Venue", "Venue",
    "Materials", "Materials", "Materials",
    "Facilitators", "Facilitators",
    "Marketing", "Marketing",
    "Registration", "Registration",
    "Technology", "Technology",
    "Catering", "Catering",
    "Logistics", "Logistics"
  ),
  item = c(
    # Venue
    "Book workshop venue",
    "Arrange room setup (tables, chairs)",
    # Materials
    "Prepare workshop handouts and workbooks",
    "Order supplies (markers, flip charts, post-its)",
    "Print certificates of completion",
    # Facilitators
    "Confirm facilitator availability",
    "Send facilitator guide and materials",
    # Marketing
    "Create workshop description and registration page",
    "Send promotional emails to target audience",
    # Registration
    "Set up registration system with payment",
    "Send pre-workshop materials to participants",
    # Technology
    "Test presentation and collaboration tools",
    "Prepare digital resources (slides, templates)",
    # Catering
    "Arrange coffee, snacks, and lunch",
    "Confirm dietary restrictions with participants",
    # Logistics
    "Send reminder emails with logistics info",
    "Prepare participant name tents and materials"
  ),
  deadline_weeks_before = c(
    # Venue
    10, 2,
    # Materials
    4, 3, 2,
    # Facilitators
    12, 3,
    # Marketing
    8, 6,
    # Registration
    8, 1,
    # Technology
    2, 2,
    # Catering
    4, 2,
    # Logistics
    1, 1
  ),
  notes = c(
    # Venue
    "Room for 25-30 participants, natural light preferred, whiteboard/projector",
    "U-shape or small group tables for collaboration",
    # Materials
    "Include exercises, templates, reference materials",
    "Ensure enough supplies for all participants plus extras",
    "Professional design with participant names",
    # Facilitators
    "Ideally 2 facilitators for interactive sessions",
    "Include timing, learning objectives, facilitation tips",
    # Marketing
    "Highlight learning outcomes, agenda, instructor bio",
    "Target professional networks, industry groups",
    # Registration
    "Collect emergency contacts and accessibility needs",
    "Reading materials, prep exercises if applicable",
    # Technology
    "Zoom/Miro for hybrid elements, polling tools",
    "Make available in shared folder 2 days before",
    # Catering
    "Morning coffee, afternoon snacks, working lunch",
    "Account for allergies, dietary preferences",
    # Logistics
    "Parking, building access, contact info",
    "Print name tents, prepare welcome packets"
  ),
  stringsAsFactors = FALSE
)

# Save workshop template
wb_work <- createWorkbook()
addWorksheet(wb_work, "Template")
writeData(wb_work, "Template", workshop_template)

addStyle(
  wb_work,
  "Template",
  style = header_style,
  rows = 1,
  cols = 1:ncol(workshop_template),
  gridExpand = TRUE
)

setColWidths(wb_work, "Template", cols = 1:ncol(workshop_template), widths = "auto")
freezePane(wb_work, "Template", firstRow = TRUE)

saveWorkbook(wb_work, "inputs/workshop_template.xlsx", overwrite = TRUE)

cat("✓ Created: inputs/workshop_template.xlsx\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n")
cat("Example templates created successfully!\n")
cat("Location: inputs/\n")
cat("  - conference_template.xlsx (", nrow(conference_template), " items)\n", sep = "")
cat("  - workshop_template.xlsx (", nrow(workshop_template), " items)\n", sep = "")
