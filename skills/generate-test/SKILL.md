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
- ✅ If sign-in is required for a flow, include app login as a prerequisite test and verify the in-app outcome after authentication
- ✅ App relaunch is allowed only when the scenario explicitly requires it; prompts must explain why relaunch is needed and what must be re-validated after relaunch
- ❌ APIs, backend endpoints, or server-side logic
- ❌ Validating third-party authentication provider internals (OAuth, Google, Facebook, GitHub)
- ❌ App internals, logs, background services, or implementation details
- ❌ Non-existent screens or functionality not accessible to users

**Quality over quantity:**
- Maximum 5 tests per feature (adjust to actual complexity)
- Understand the user flow thoroughly before generating tests
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
- Refer the **Test user-facing functionality only** checklist in **Core Principles**.
- If any part of the user flow is ambiguous, ask clarifying questions before continuing.

### Step 2 — Auth and Preconditions Intake (Required)

Before planning tests, explicitly collect setup requirements from the user:
- Determine whether authentication is required for any target flow.
- If authentication is required, ask for the approved login method and test credentials (or confirm how credentials will be supplied during execution).
- Ask for required account state, seed data, permissions, feature flags, and environment assumptions needed for the flows.
- Ask for MFA/OTP handling instructions if applicable.

Hard rules:
- Never invent credentials, OTP codes, user identities, or test data.
- Never guess login paths or random account details.
- If any required credential or precondition is missing, stop and ask the user before continuing.

### Step 3 — Plan the Tests

For each user flow identified, plan a test with:
- **Name**: A clear, user-action description (e.g. "User filters products by price range")
- **Prompt**: Natural-language instructions for the AI agent executing on a real device

### Step 4 — Review and Confirm the Test Plan

Present the planned tests to the user for review and confirmation:
- Display all planned feature tests with their **Name** and **Prompt**
- Display prerequisite tests and their mapped dependency types (`auth`, `navigation`, `data state`, `permissions`)
- Display exact planned suite execution order (prerequisites first, then feature tests)
- Confirm credential and precondition readiness status
- Allow the user to confirm, edit, add, or remove tests
- Incorporate the user’s feedback and finalize the test plan before execution
- Do not execute or upload tests until the user confirms the full plan (tests + prerequisites + order + readiness)


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

### Step 5 — Check for Existing Tests

Before creating tests, check what already exists:

```
Use MCP tool: list_tests
Arguments: { "search": "<feature keyword>" }
```

Also search for related test suites:

```
Use MCP tool: list_test_suites
Arguments: { "search": "<feature keyword>" }
```

Skip any test that duplicates existing coverage.

### Step 6 — Set Up the Folder

Before creating tests, ensure a folder exists to organize them. First, check if a suitable folder already exists:

```
Use MCP tool: browse_folder
Arguments: {}  # browses root level
```

A folder counts as a match only when its name equals `<Feature Name>` (case-insensitive).

- **If exactly one matching folder exists** — note its `folderId` and proceed to Step 7.
- **If multiple matching folders exist** — ask the user which folder to use.
- **If no matching folder exists** — create one:

```
Use MCP tool: create_folder
Arguments:
  name: "<Feature Name>"
  description: "Tests for <feature description>"
  # parentFolderId: "<id>"  # optional, for nesting under an existing folder
```

Note the returned `folderId` for use in the next step.

### Step 7 — Create Tests, Then Move Them Into the Folder

For each planned test, create it first:

```
Use MCP tool: create_test
Arguments:
  name: "<test name from spec>"
  prompt: "<full prompt from spec>"
```

The tool will return the test ID upon success. Keep track of all created test IDs.

After creating all tests for the feature, move them into the folder from Step 6:

```
Use MCP tool: bulk_move
Arguments:
  testIds: ["<test-id-1>", "<test-id-2>", ...]
  targetFolderId: "<folder-id-from-step-6>"
```

### Step 8 — Group into a Test Suite

A test suite is an **ordered sequence of tests** that run end-to-end on a device. To test a feature, the suite must include any **prerequisite tests** (e.g., login, navigation) that set up the required state, followed by the feature tests themselves — all in execution order.

#### 8a. Resolve app mapping prerequisite

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

#### 8a.1 Missing upload handling (Required)

If no suitable app upload exists for the target platform:
- Pause suite creation and ask the user to upload/provide an app version before continuing.
- Ask for required details: target platform, app name, and either:
  - app binary path for upload, or
  - existing `appId` + `appUploadId`.
- Continue with test/folder preparation if needed, but do not run `create_test_suite` until app mapping is confirmed.

Hard rules:
- Never invent or guess `appId`/`appUploadId`.
- Never proceed to Step 8d without a confirmed `appMapping`.

#### 8b. Identify prerequisite tests (Required)

For every feature test, classify preconditions using this checklist:
- `auth`: user must be signed in / signed out / in a specific account state
- `navigation`: user must already be on a specific screen/context
- `data state`: required entities, fixtures, or records must already exist
- `permissions`: camera/location/notification permissions must be granted or denied

Each required precondition must map to a prerequisite test in the suite.

Determine what tests must run before the feature tests. For example, to test a Product Details page you need: 

1. **Login** — authenticate into the app
2. **Navigate to product** — search for a product and open the details page
3. **Product details tests** — the actual feature tests created in Step 7

#### 8c. Check if prerequisite tests exist

Search for each prerequisite test:

```
Use MCP tool: list_tests
Arguments: { "search": "<prerequisite keyword>" }
```

- **If the test exists** — note its test ID.
- **If the test does not exist** — create it using `create_test`, note the returned test ID, then move it into the feature folder with `bulk_move`.

#### 8d. Create the test suite in order (Required)

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

Do not create the suite until all required preconditions are mapped to concrete prerequisite test IDs.

#### 8e. Stop conditions (Required)

Pause and ask the user instead of proceeding if any of the following is true:
- Missing or unconfirmed credentials for required login flows
- Unclear authentication path or unclear MFA/OTP handling
- Missing account state/data prerequisites needed for a flow
- Ambiguous prerequisite order between setup tests and feature tests
- Missing suitable app upload for the target platform or missing confirmed `appMapping`

## Test Prioritization

1. **Critical user flows** — onboarding, login, checkout, submissions
2. **Interactive features and gestures** — tap, swipe, scroll, search, filters
3. **Form input and validation** — errors, required fields, keyboard interaction
4. **Navigation flows** — screen transitions, back navigation, tab switching
5. **Conditional UI states** — loading, empty, error, success states
6. **Mobile-specific behaviors** — orientation changes, keyboard, dynamic UI

## Quick Checklist

- [ ] Feature analyzed, all user flows mapped
- [ ] Credentials and setup preconditions gathered for auth/data/permissions as needed
- [ ] Existing tests checked via `list_tests` — no duplicates
- [ ] Folder set up via `browse_folder` / `create_folder`
- [ ] Each test name describes a user action (not implementation detail)
- [ ] Prompts are specific, sequential, and include verification steps
- [ ] Tests created via `create_test`, then moved into folder via `bulk_move`
- [ ] Suite created via `create_test_suite` with `appMapping`
- [ ] Suitable app upload confirmed for target platform (or user prompted to provide/upload one)
- [ ] Every prerequisite dependency is mapped to a concrete prerequisite test ID
- [ ] Suite order confirmed: prerequisites first, then feature tests
- [ ] No invented credentials, OTPs, or random login attempts

## Anti-Patterns

❌ **Vague prompts**: "Test the login" → No verification, no specifics
✅ **Good prompts**: "Tap Login, enter the provided test credentials, tap Submit, verify home screen loads with welcome message"

❌ **Testing implementation**: "Verify store updates" → Backend/state concern
✅ **Testing user outcome**: "Verify the item count in the cart badge updates to 2"

❌ **One mega-test**: A single test covering 15 different features
✅ **Focused tests**: Each test covers one user workflow (3-8 steps)

❌ **Invented authentication data**: "Try a few emails and passwords until login works"
✅ **Controlled authentication**: Use only user-provided credentials and documented login handling

❌ **Unjustified relaunch**: "Relaunch app and continue" without reason or post-relaunch checks
✅ **Intentional relaunch**: Relaunch only when required and verify the expected restored state after relaunch

❌ **Assumed app mapping**: "Use any app mapping and create the suite"
✅ **Confirmed app mapping**: If upload is missing, ask the user to provide/upload app version and wait for `appMapping`
