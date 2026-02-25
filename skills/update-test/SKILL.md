---
name: finalrun-update-test
description: Update existing FinalRun test prompts when code changes break them. The tests are for native mobile apps and mobile web apps (accessed via mobile browsers).
---

# FinalRun Test Update

Update existing tests via MCP tools **only when code changes break them**. Update in place, preserve intent.

## MCP Preflight

Before updating tests:

1. Run `ping`.
2. If ping fails, the FinalRun MCP server may not be installed or configured. Ask the user to verify their MCP setup.
3. Resume this workflow only after MCP is healthy.

## Critical Rules

1. **Tests are natural-language AI prompts** — No selectors, no locators, no technical details
2. **NEVER modify code** — Only read code, only update tests via MCP
3. **If test still valid, do nothing** — Don't fix what works
4. **Update in place** — Same test, same folder — preserve name unless scope fundamentally changed
5. **No app relaunch** — Never include "close app", "relaunch app", or "reopen app" steps in prompts

## User Input & Credentials

When updating test prompts that reference user-specific data (login credentials, form values, environment details), follow these rules:

1. **Never guess or fabricate** credentials, emails, passwords, or account-specific values in updated prompts.
2. **Ask the user** if an updated flow requires new inputs that are unknown — this includes but is not limited to:
   - Login credentials (username, email, password)
   - Form field values (addresses, phone numbers, payment details)
   - Environment-specific URLs or endpoints
   - Account-specific data (user IDs, org names, project names)
3. **Preserve existing values** — if the original prompt already contains credentials or user data and the flow hasn't changed for those fields, keep them as-is.
4. **Ask during Step 4 (Review the Update Plan)** — identify any new required user inputs and resolve them before executing updates.

> Not asking the user for unknown inputs is a **blocker** — do not skip this step or invent placeholder values.

## Your Only Job

1. **Read** the code changes
2. **Find** the existing tests via MCP
3. **Decide** if each test needs updating (valid, outdated, or obsolete)
4. **If all tests are still valid** → Stop here, nothing to do
5. **Present** the update plan to the user for confirmation
6. **Update** outdated test prompts via MCP (never touch code)
7. **Delete** obsolete tests if features were removed
8. **Create** new tests for new flows (via `generate-test`)

## When to Update

**✅ Update if:**
- User flow changed (added/removed/reordered steps)
- Button or field labels changed
- Expected behavior different (new success message, different screen transition, or navigation outcome)
- Screen layout reorganized (form moved, navigation structure changed, or elements repositioned)
- Navigation patterns changed (tab bar, back navigation, or screen hierarchy updated)
- Interactive elements changed (gestures, input behavior, or user interaction patterns)

**❌ Don't update if:**
- Code refactored, same UI
- Only styling changed
- Backend changes, frontend unchanged
- Third-party authentication flows (OAuth, Google, Facebook, GitHub)
- **Test still accurately describes current flow**

## Natural Language Prompts

FinalRun tests use **plain language AI prompts**, not technical selectors:

✅ **Good — Natural language:**
```
Navigate to the Products page.
Enter "laptop" in the search box.
Tap the search button.
Select "Electronics" from the category dropdown.
Verify products display correctly.
```

❌ **Bad — Technical selectors:**
```
Navigate to /products
Enter "laptop" in input[data-testid="search-field"]
Click button#search-btn
```

**Write like you're instructing a human, not a robot.**

## Workflow Steps

### Step 1 — Understand the Code Changes

Read the changed files and identify:
- What user-facing flows were affected
- Which UI elements changed (labels, buttons, navigation)
- What new behavior was introduced
- Whether any screens were added or removed
- Changes to form validation rules or error messages
- Whether any features were removed entirely (signals test deletion in Step 6)

### Step 2 — Find Existing Tests

Browse folders and list tests to find tests related to the changed feature:

```
Use MCP tool: browse_folder
Arguments: {}  # browse root level to find the feature folder
```

```
Use MCP tool: browse_folder
Arguments: { "folderId": "<feature-folder-id>" }  # list tests inside
```

Or search directly:

```
Use MCP tool: list_tests
Arguments: { "search": "<feature keyword>" }
```

Also search for related test suites:

```
Use MCP tool: list_test_suites
Arguments: { "search": "<feature keyword>" }
```

### Step 3 — Evaluate Each Test

For each test found, compare the prompt against the new code behavior:
- **Still valid?** → Skip, do nothing
- **Outdated?** → Needs update (Step 5)
- **Obsolete?** → Feature removed, needs deletion (Step 6)

### Step 4 — Review and Confirm the Update Plan

Present the evaluation from Step 3 to the user for review:
- List tests that are **still valid** (no changes needed)
- List tests that are **outdated** with the proposed updated prompt
- List tests that are **obsolete** and will be deleted
- List any **new tests** needed for new flows
- Allow the user to confirm, edit, or adjust the plan
- Incorporate the user's feedback and finalize before execution

Do not execute any updates or deletions until the user confirms the plan.

### Step 5 — Update Outdated Tests

Update the test prompt via MCP:

```
Use MCP tool: update_tests_by_name
Arguments:
  testNameQuery: "<exact test name>"
  prompt: "<updated natural-language prompt>"
  limit: 1
```

This will preview the match. Then confirm:

```
Use MCP tool: update_tests_by_name
Arguments:
  testNameQuery: "<exact test name>"
  confirm: true
  confirmationToken: "<token-from-preview>"
```

**What to update:**
- `prompt` — New flow description with verification steps. Follow the prompt guidelines from `generate-test` — be specific, sequential, and include verification steps.

**What you MAY update (only if necessary):**
- `name` — If the scope fundamentally changed

### Step 6 — Delete Obsolete Tests (If Needed)

If a feature was removed entirely and a test is no longer relevant:

```
Use MCP tool: delete_tests_by_name
Arguments:
  testNameQuery: "<test name>"
  limit: 1
```

This will preview the match. Then confirm:

```
Use MCP tool: delete_tests_by_name
Arguments:
  testNameQuery: "<test name>"
  confirm: true
  confirmationToken: "<token-from-preview>"
```

### Step 7 — Create New Tests (If Needed)

If the code change introduced a **new user flow** not covered by existing tests, create a new test inside the appropriate folder. Follow the `generate-test` workflow (Steps 5–7) for this.

### Step 8 — Update Related Test Suites (If Needed)

If any tests were updated, deleted, or created, check if they belong to a test suite:

```
Use MCP tool: list_test_suites
Arguments: { "search": "<feature keyword>" }
```

Update the suite if:
- A **deleted test** is still referenced → remove it from the suite's `testIds`
- A **new test** was created → add it to the suite's `testIds` in the correct order
- **Prerequisite tests** changed → update the suite order

```
Use MCP tool: update_test_suites_by_name
Arguments:
  testSuiteNameQuery: "<suite name>"
  testIds: ["<updated-ordered-test-ids>"]
```

Then confirm with the returned token.

## Update Examples

### Example 1: Flow Changed

**Code change:** Added a review step before payment

**Before prompt:**
```
Navigate to checkout.
Fill in shipping address.
Tap continue to payment.
Enter payment details.
Tap place order.
Verify order confirmation page displays.
```

**After prompt:**
```
Navigate to checkout.
Fill in shipping address.
Tap continue to review.
Review the order summary and verify items and totals are correct.
Tap continue to payment.
Enter payment details.
Tap place order.
Verify order confirmation page displays.
```

### Example 2: Button Label Changed

**Code change:** "Login" button renamed to "Sign In"

**Before prompt:**
```
...Tap the "Login" button...
```

**After prompt:**
```
...Tap the "Sign In" button...
```

### Example 3: No Update Needed ✅

Code refactored but same UI flow → **Leave test unchanged.**

### Example 4: Feature Removed — Test Deleted

**Code change:** Removed the wishlist feature entirely

**Action:** Delete the "User adds product to wishlist" test. Update any suite that referenced it.

## Checklist

- [ ] Read and understood code changes
- [ ] Found existing tests via `browse_folder` / `list_tests`
- [ ] Evaluated each test — determined valid, outdated, or obsolete
- [ ] Presented update plan to user and got confirmation
- [ ] Updated prompts in natural language (no selectors)
- [ ] Used two-phase update (preview → confirm)
- [ ] **Did NOT modify any code files**
- [ ] Deleted obsolete tests if features were removed
- [ ] Created new tests for new flows (via `generate-test`)
- [ ] Checked and updated related test suites

## Key Reminders

- **Natural language only** — Write for humans, not robots
- **Never touch code** — Only read code, only update tests via MCP
- **Update in place** — Same test, same folder
- **Only if broken** — Don't fix what works
- **Two-phase updates** — Always preview before confirming

**If test still accurately describes the flow, don't touch it.**
