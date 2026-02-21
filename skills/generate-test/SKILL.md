---
name: finalrun-generate-test
description: Generate test cases for mobile apps and upload them to FinalRun cloud
---

# FinalRun Test Generation

Generate user-focused test specifications for mobile/web apps and upload them to FinalRun cloud via MCP tools.

## MCP Preflight

Before generating tests:

1. Run `ping`.
2. If ping fails, the FinalRun MCP server may not be installed or configured. Ask the user to verify their MCP setup.
3. Continue test generation only after MCP is healthy.

## Core Principles

**Test user-facing functionality only:**
- ✅ User interactions, workflows, and navigation
- ✅ End-to-end page functionality
- ✅ Form validation, search, filters, and interactive features
- ❌ APIs, endpoints, or server logic
- ❌ Third-party auth (OAuth, Google, Facebook, GitHub)
- ❌ Metadata, SEO elements, or HTML structure
- ❌ Non-existent functionality

**Quality over quantity:**
- Maximum 5 tests per feature (adjust to actual complexity)
- Check for duplicate coverage before creating new tests (use `list_tests`)
- Focus on critical workflows users actually need

## Workflow Steps

### Step 1 — Analyze the Feature

Read relevant source files to understand the user-facing functionality:
- Identify all pages/screens involved
- Map out user flows and interactions
- Note form fields, buttons, navigation paths, and conditional states

### Step 2 — Plan the Tests

For each user flow identified, plan a test with:
- **Name**: A clear, user-action description (e.g. "User filters products by price range")
- **Prompt**: Natural-language instructions for the AI agent executing on a real device

#### Writing Good Prompts

The prompt drives the entire test execution. Guidelines:

- **Be specific**: "Tap the 'Add to Cart' button on the product detail screen" not "Add item"
- **Include verification**: "Verify the cart badge shows '1' after adding"
- **Describe the full flow**: Navigate → Interact → Assert
- **Reference actual UI elements**: Use text labels, button names, and screen titles from the source code
- **Keep it sequential**: Write steps in execution order
- **Include expected outcomes inline**: "After tapping Submit, a success toast should appear"

#### Example Prompt

**Name:** User filters products by price range

**Prompt:**
```
Open the app and navigate to the Products page.
Tap on the filter icon in the top-right corner.
Select the price range $50-$100 using the slider.
Choose "Electronics" from the category dropdown.
Tap "Apply Filters".
Verify the product list updates to show only electronics priced between $50 and $100.
Verify the active filter chips appear at the top of the list.
Verify the result count updates correctly.
```

### Step 3 — Check for Existing Tests

Before creating tests, check what already exists:

```
Use MCP tool: list_tests
Arguments: { "search": "<feature keyword>" }
```

Skip any test that duplicates existing coverage.

### Step 4 — Create Tests in FinalRun

For each planned test, create it via MCP:

```
Use MCP tool: create_test
Arguments:
  name: "<test name from spec>"
  prompt: "<full prompt from spec>"
```

The tool will return the test ID upon success. Keep track of all created test IDs.

### Step 5 — Organize into a Folder

Group the created tests into a folder for organization. First, check if a suitable folder already exists:

```
Use MCP tool: browse_folder
Arguments: {}  # browses root level
```

If no matching folder exists, create one:

```
Use MCP tool: create_folder
Arguments:
  name: "<Feature Name>"
  description: "Tests for <feature description>"
  # parentFolderId: "<id>"  # optional, for nesting under an existing folder
```

Then move all created tests into the folder:

```
Use MCP tool: bulk_move
Arguments:
  targetFolderId: "<folder-id-from-above>"
  testIds: ["<test-id-1>", "<test-id-2>", ...]
```

### Step 6 — Group into a Test Suite (Optional)

If multiple related tests were created, also group them into a test suite for execution:

```
Use MCP tool: create_test_suite
Arguments:
  name: "<Feature Name> Regression"
  description: "<Brief description of what the suite covers>"
  autoSelectPlatform: "android"  # or "ios"
```



## Test Prioritization

1. **Critical paths** — login, checkout, data submission
2. **Interactive features** — search, sorting, filtering
3. **Form validation** — required fields, error messages
4. **Navigation flows** — screen transitions, back behavior
5. **Conditional UI** — loading, empty, error states

## Quick Checklist

- [ ] Feature analyzed, all user flows mapped
- [ ] Existing tests checked via `list_tests` — no duplicates
- [ ] Each test name describes a user action (not implementation detail)
- [ ] Prompts are specific, sequential, and include verification steps
- [ ] Tests created via `create_test`
- [ ] Tests organized into a folder via `create_folder` + `bulk_move`
- [ ] Suite created via `create_test_suite` if multiple related tests

## Anti-Patterns

❌ **Vague prompts**: "Test the login" → No verification, no specifics
✅ **Good prompts**: "Open app, tap Login, enter user@test.com and password123, tap Submit, verify home screen loads with welcome message"

❌ **Testing implementation**: "Verify Redux store updates" → Backend/state concern
✅ **Testing user outcome**: "Verify the item count in the cart badge updates to 2"

❌ **One mega-test**: A single test covering 15 different features
✅ **Focused tests**: Each test covers one user workflow (3-8 steps)
