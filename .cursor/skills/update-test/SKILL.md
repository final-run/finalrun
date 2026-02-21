---
name: finalrun-update-test
description: Update existing FinalRun test prompts when code changes break them
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
4. **Update in place** — Same test, same name, same folder

## Your Only Job

1. **Read** the code changes
2. **Find** the existing tests via MCP
3. **Decide** if each test needs updating
4. **If NO** → Do nothing
5. **If YES** → Update only the test prompt via MCP (never touch code)

## When to Update

**✅ Update if:**
- User flow changed (added/removed/reordered steps)
- Button or field labels changed
- Expected behavior different (new success message, different redirect)
- Page structure reorganized (form moved, navigation changed)

**❌ Don't update if:**
- Code refactored, same UI
- Only styling changed
- Backend changes, frontend unchanged
- **Test still accurately describes current flow**

## Natural Language Prompts

FinalRun tests use **plain language AI prompts**, not technical selectors:

✅ **Good — Natural language:**
```
Open the app and navigate to the Products page.
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

### Step 3 — Evaluate Each Test

For each test found, compare the prompt against the new code behavior:
- **Still valid?** → Skip, do nothing
- **Outdated?** → Needs update

### Step 4 — Update Outdated Tests

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
- `prompt` — New flow description with verification steps

**What you MAY update (only if necessary):**
- `name` — If the scope fundamentally changed

### Step 5 — Delete Obsolete Tests (If Needed)

If a feature was removed entirely and a test is no longer relevant:

```
Use MCP tool: delete_tests_by_name
Arguments:
  testNameQuery: "<test name>"
  limit: 1
```

Then confirm with the returned token.

### Step 6 — Create New Tests (If Needed)

If the code change introduced a **new user flow** not covered by existing tests, create a new test and move it into the appropriate folder. Follow the `/generate-tests` workflow for this.

## Update Examples

### Example 1: Flow Changed

**Code change:** Added a review step before payment

**Before prompt:**
```
Open the app and navigate to checkout.
Fill in shipping address.
Tap continue to payment.
Enter payment details.
Tap place order.
Verify order confirmation page displays.
```

**After prompt:**
```
Open the app and navigate to checkout.
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

## Checklist

- [ ] Read and understood code changes
- [ ] Found existing tests via `browse_folder` / `list_tests`
- [ ] Evaluated each test — determined which need updating
- [ ] Updated prompts in natural language (no selectors)
- [ ] Used two-phase update (preview → confirm)
- [ ] **Did NOT modify any code files**
- [ ] Deleted obsolete tests if features were removed
- [ ] Created new tests for new flows (via `/generate-tests`)

## Key Reminders

- **Natural language only** — Write for humans, not robots
- **Never touch code** — Only read code, only update tests via MCP
- **Update in place** — Same test name, same folder
- **Only if broken** — Don't fix what works
- **Two-phase updates** — Always preview before confirming

**If test still accurately describes the flow, don't touch it.**
