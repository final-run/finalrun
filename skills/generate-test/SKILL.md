---
name: finalrun-generate-test
description: Generate test cases for native mobile apps and mobile web apps (accessed via mobile browsers), and upload them to the FinalRun cloud.
---

# FinalRun Test Generation

Generate user-focused test specifications for native mobile apps and mobile web apps, and upload them to the FinalRun cloud via MCP tools.

## MCP Preflight

Before generating tests:

1. Run `ping`.
2. If ping fails, the FinalRun MCP server may not be installed or configured. Ask the user to verify their MCP setup.
3. Continue test generation only after MCP is healthy.

## Core Principles

**Test user-facing functionality only:**
- ✅ User interactions, gestures, and navigation (tap, swipe, scroll, back navigation)
- ✅ End-to-end screen and feature functionality
- ✅ Form input, validation, search, filters, and interactive UI elements
- ✅ Mobile-specific behaviors (keyboard input, screen transitions, orientation changes)
- ❌ APIs, backend endpoints, or server-side logic
- ❌ Third-party authentication providers (OAuth, Google, Facebook, GitHub)
- ❌ App internals, logs, background services, or implementation details
- ❌ Non-existent screens or functionality not accessible to users
- ❌ Relaunching or closing/reopening the app mid-test or mid-suite

**Quality over quantity:**
- Maximum 5 tests per feature (adjust to actual complexity)
- Check for duplicate coverage before creating new tests (use `list_tests`)
- Focus on critical workflows users actually need

## User Input & Credentials

Test prompts often reference user-specific data such as login credentials, form values, or environment-specific details. Follow these rules:

1. **Never guess or fabricate** credentials, emails, passwords, or account-specific values when writing prompts.
2. **Ask the user** if any required test input is unknown — this includes but is not limited to:
   - Login credentials (username, email, password)
   - Form field values (addresses, phone numbers, payment details)
   - Environment-specific URLs or endpoints
   - Account-specific data (user IDs, org names, project names)
3. **Ask during Step 2 (Plan the Tests)** — identify all required user inputs while planning and resolve them before writing prompts.
4. **Use the exact values provided** by the user in test prompts — do not substitute or anonymize them.

> Not asking the user for unknown inputs is a **blocker** — do not skip this step or use placeholder values like `user@test.com` / `password123` unless the user explicitly provides them.

## Workflow Steps

### Step 1 — Analyze the Feature

Read relevant source files to understand the user-facing functionality:
- Identify all pages/screens involved
- Map out user flows and interactions
- Note form fields, buttons, navigation paths, and conditional states
- Refer `Test user-facing functionality` section

### Step 2 — Plan the Tests

For each user flow identified, plan a test with:
- **Name**: A clear, user-action description (e.g. "User filters products by price range")
- **Prompt**: Natural-language instructions for the AI agent executing on a real device

### Step 3 — Review and Confirm the Test Plan

Present the planned tests to the user for review and confirmation:
- Display all planned tests with their **Name** and **Prompt**
- Allow the user to confirm, edit, add, or remove tests
- Incorporate the user’s feedback and finalize the test plan before execution
- Do not execute or upload tests until the user confirms the plan


#### Writing Good Prompts

The prompt drives the entire test execution. Guidelines:

- **Be specific**: "Tap the 'Add to Cart' button on the product detail screen" not "Add item"
- **Include verification**: "Verify the cart badge shows '1' after adding"
- **Describe the full flow**: Navigate → Interact → Assert
- **Reference actual UI elements**: Use text labels, button names, and screen titles from the source code
- **Keep it sequential**: Write steps in execution order
- **Include expected outcomes inline**: "After tapping Submit, a success toast should appear"
- **Do not Add "open or launch the app" in the prompt**: The FinalRun runner automatically launches the app before executing tests. Never start prompts with "Open the app", "Launch the app", or similar. Begin directly with navigation or interaction steps.

#### Example Prompt

**Name:** User filters products by price range

**Prompt:**
```
Navigate to the Products page.
Tap on the filter icon in the top-right corner.
Select the price range $50-$100 using the slider.
Choose "Electronics" from the category dropdown.
Tap "Apply Filters".
Verify the product list updates to show only electronics priced between $50 and $100.
Verify the active filter chips appear at the top of the list.
Verify the result count updates correctly.
```

### Step 4 — Check for Existing Tests

Before creating tests, check what already exists:

```
Use MCP tool: list_tests
Arguments: { "search": "<feature keyword>" }
```

Skip any test that duplicates existing coverage.

### Step 5 — Set Up the Folder

Before creating tests, ensure a folder exists to organize them. First, check if a suitable folder already exists:

```
Use MCP tool: browse_folder
Arguments: {}  # browses root level
```

- **If a matching folder exists** — note its `folderId` and proceed to Step 6.
- **If no matching folder exists** — create one:

```
Use MCP tool: create_folder
Arguments:
  name: "<Feature Name>"
  description: "Tests for <feature description>"
  # parentFolderId: "<id>"  # optional, for nesting under an existing folder
```

Note the returned `folderId` for use in the next step.

### Step 6 — Create Tests, Then Move Them Into the Folder

For each planned test, create it first:

```
Use MCP tool: create_test
Arguments:
  name: "<test name from spec>"
  prompt: "<full prompt from spec>"
```

The tool will return the test ID upon success. Keep track of all created test IDs.

After creating all tests for the feature, move them into the folder from Step 5:

```
Use MCP tool: bulk_move
Arguments:
  testIds: ["<test-id-1>", "<test-id-2>", ...]
  targetFolderId: "<folder-id-from-step-5>"
```

### Step 7 — Group into a Test Suite

A test suite is an **ordered sequence of tests** that run end-to-end on a device. To test a feature, the suite must include any **prerequisite tests** (e.g., login, navigation) that set up the required state, followed by the feature tests themselves — all in execution order.

#### 7a. Resolve app mapping prerequisite

`create_test_suite` requires an app mapping up front.

Collect app mapping before suite creation:

```
Use MCP tool: available_apps
Arguments: { "search": "<app name>", "platform": "Android" }  # or "IOS"
```

Build:

```
appMapping: { "<appId>": "<appUploadId>" }
```

If no suitable upload exists yet, defer Step 7d. Continue creating/moving tests, and return to Step 7d after an app upload is available.

#### 7b. Identify prerequisite tests

Determine what tests must run before the feature tests. For example, to test a Product Details page you need: 

1. **Login** — authenticate into the app
2. **Navigate to product** — search for a product and open the details page
3. **Product details tests** — the actual feature tests created in Step 6

#### 7c. Check if prerequisite tests exist

Search for each prerequisite test:

```
Use MCP tool: list_tests
Arguments: { "search": "<prerequisite keyword>" }
```

- **If the test exists** — note its test ID.
- **If the test does not exist** — create it using `create_test`, note the returned test ID, then move it into the feature folder with `bulk_move`.

#### 7d. Create the test suite in order

Assemble all test IDs — prerequisites first, then feature tests — in execution order:

```
Use MCP tool: create_test_suite
Arguments:
  name: "<Feature Name>"
  description: "<Brief description of what the suite covers>"
  autoSelectPlatform: "Android"  # or "IOS"
  testIds: ["<prerequisite-test-id-1>", "<prerequisite-test-id-2>", ..., "<feature-test-id-1>", "<feature-test-id-2>", ...]
  appMapping: { "<appId>": "<appUploadId>" }
```

## Test Prioritization

1. **Critical user flows** — onboarding, login, checkout, submissions
2. **Interactive features and gestures** — tap, swipe, scroll, search, filters
3. **Form input and validation** — errors, required fields, keyboard interaction
4. **Navigation flows** — screen transitions, back navigation, tab switching
5. **Conditional UI states** — loading, empty, error, success states
6. **Mobile-specific behaviors** — orientation changes, keyboard, dynamic UI

## Quick Checklist

- [ ] Feature analyzed, all user flows mapped
- [ ] Existing tests checked via `list_tests` — no duplicates
- [ ] Folder set up via `browse_folder` / `create_folder`
- [ ] Each test name describes a user action (not implementation detail)
- [ ] Prompts are specific, sequential, and include verification steps
- [ ] Tests created via `create_test`, then moved into folder via `bulk_move`
- [ ] Suite created via `create_test_suite` with prerequisite + feature tests in order, plus `appMapping`

## Anti-Patterns

❌ **Vague prompts**: "Test the login" → No verification, no specifics
✅ **Good prompts**: "Tap Login, enter user@test.com and password123, tap Submit, verify home screen loads with welcome message"

❌ **Testing implementation**: "Verify store updates" → Backend/state concern
✅ **Testing user outcome**: "Verify the item count in the cart badge updates to 2"

❌ **One mega-test**: A single test covering 15 different features
✅ **Focused tests**: Each test covers one user workflow (3-8 steps)

❌ **App relaunch mid-suite**: "Close the app and reopen it, then navigate to settings"
✅ **Continuous flow**: Each test in a suite continues from where the previous test left off
