---
name: finalrun-test-runner
description: >
  Run mobile app tests on cloud or local devices via the FinalRun MCP server.
  Use when: (1) uploading app binaries, (2) running tests or suites on cloud devices,
  (3) running tests on local devices.
---

# FinalRun Test Runner

Orchestrate FinalRun MCP tools to run mobile app tests on cloud or local devices.

## MCP Preflight

Before any test operation:

1. Run `ping`.
2. If ping fails, the FinalRun MCP server may not be installed or configured. Ask the user to verify their MCP setup.
3. Resume this workflow only after MCP is healthy.

## Core Concepts

- **Test**: A single automated flow (one scenario).
- **Test Suite**: An ordered group of tests executed together on a device.
- **Test Runs**: Historical execution records of tests or suites that already ran.

## Your Only Job

1. **Find** the test or suite to run
2. **Select** the target device(s) — cloud or local
3. **Map** the app binary — use an existing app, or upload a new one if not available
4. **Confirm** the run plan with the user
5. **Execute** the test run

> For creating tests, see `generate-test`. For updating or deleting tests, see `update-test`.

## Required Inputs

- **Run Test**: test name + `appMapping` + one compatible devices - cloud or local
- **Run Test Suite**: suite name + `appMapping` + one compatible devices - cloud or local

## User Input & Credentials

Tests often require user-specific data such as login credentials, form values, environment URLs, or account details. Follow these rules:

1. **Never guess or fabricate** credentials, emails, passwords, API keys, or environment-specific values.
2. **Ask the user** before proceeding if any required test input is unknown — this includes but is not limited to:
   - Login credentials (username, email, password)
   - Form field values (addresses, phone numbers, payment details)
   - Environment-specific URLs or endpoints
   - Account-specific data (user IDs, org names, project names)
3. **Ask early** — identify required inputs during Step 1 (finding the test) and resolve them before Step 4 (confirming the run plan).
4. **Include provided values** in the run plan confirmation so the user can verify them.

> Not asking the user for unknown inputs is a **blocker** — do not skip this step.

## Platform Compatibility Rule (Strict)

- Android app upload -> Android devices only
- iOS app upload -> iOS devices only
- Never map Android app to iOS device, or iOS app to Android device
- For `platform` and `autoSelectPlatform` parameters, use these exact values: `Android` or `IOS`

## Workflow Steps

### Step 1 — Find the Test or Suite

Search for the test or suite to run:

```
Use MCP tool: list_tests
Arguments: { "search": "<test name keyword>" }
```

Or for suites:

```
Use MCP tool: list_test_suites
Arguments: { "search": "<suite name keyword>" }
```

If the test or suite doesn't exist, follow the `generate-test` workflow to create it first.

### Step 2 — Select Target Devices

**Cloud devices:**

```
Use MCP tool: list_supported_devices
Arguments: { "platform": "Android" }  # or "IOS"
```

Note the `requirementId` for the target device(s).

**Local devices:**

```
Use MCP tool: list_local_devices
Arguments: {}
```

Note the `uuid` for the target device. Ensure local prerequisites are met (see Local Run Prerequisites section).

### Step 3 — Resolve App Mapping

Search for the app binary to use:

```
Use MCP tool: available_apps
Arguments: { "search": "<app name>", "platform": "Android" }  # or "IOS"
```

- **If app exists** — select the appropriate `appId` + `appUploadId` pair
- **If no app is available** — upload a new binary following the Upload Routing Rule below

**Platform inference:**
- **If app has uploads for only one platform** — platform is already determined, select matching devices automatically without asking the user
- **If app has uploads for both platforms** — ask the user which platform to run on

Enforce platform compatibility: Android app → Android device, iOS app → iOS device.

### Step 4 — Confirm the Run Plan

Present the run plan to the user for confirmation:
- Test or suite name to run
- Target device(s) and platform
- App binary version (appId + appUploadId)
- Cloud or local execution

Do not start the run until the user confirms the plan.

### Step 5 — Execute the Run

**Cloud — Single Test:**

```
Use MCP tool: run_test_by_name_on_devices
Arguments:
  testName: "<test name>"
  devices: [{ "cloudRequirementId": "<requirement-id>" }]
  appMapping: { "<appId>": "<appUploadId>" }
```

**Cloud — Test Suite:**

```
Use MCP tool: run_test_suite_by_name_on_devices
Arguments:
  testSuiteName: "<suite name>"
  devices: [{ "cloudRequirementId": "<requirement-id>" }]
  appMapping: { "<appId>": "<appUploadId>" }
```

**Local — Single Test:**

```
Use MCP tool: run_test_locally
Arguments:
  testName: "<test name>"
  deviceUUID: "<device-uuid>"
  appMapping: { "<appId>": "<appUploadId>" }
```

**Local — Test Suite:**

```
Use MCP tool: run_test_suite_locally
Arguments:
  testSuiteName: "<suite name>"
  deviceUUID: "<device-uuid>"
  appMapping: { "<appId>": "<appUploadId>" }
```

To stop a running local test:

```
Use MCP tool: stop_local_test_run
Arguments: { "testRunId": "<test-run-id>" }
```

## Local Run Prerequisites

Before executing a **Local Test Run** or **Local Test Suite Run**:
- **Android**: Ensure `adb` is installed. Verify by running `which adb`. If not present, install via Homebrew (`brew install android-platform-tools`) or [Android Studio](https://developer.android.com/studio).
- **iOS**: Ensure `xcrun` is available (mac only). Verify by running `which xcrun`. If not present, run `xcode-select --install`.

## Upload Routing Rule

When user asks to upload a new build, always ask:

- "Should this upload go to an existing app or a new app container?"
- "Confirm platform: Android or iOS?"

Then follow:

1. **Existing app path**
   - Call `available_apps`
   - Filter/select by platform (`Android` or `IOS`)
   - Pick target app node by `appId`, then read its `appName`
   - Call `create_app_version(appName, filePath)` using that exact `appName`

2. **New app path**
   - Confirm platform (`Android` or `IOS`)
   - Call `create_app(name, appKnowledge?)` -> get `appId`
   - Call `create_app_version(appName, filePath)` to upload first version

## App Mapping

When running a test or suite, `appMapping` is required.

Identity rules:
- `appId` identifies the app container (the same app record that includes `appName`).
- `appUploadId` identifies the uploaded version/build under that app.

Canonical format:

```json
{ "appId": "appUploadId" }
```

Use `available_apps` response to get valid pairs.

## Device Targeting

For **cloud** runs, each device target must include exactly one:
- `cloudRequirementId` — from `list_supported_devices`, targets a specific cloud device
- `autoSelectPlatform` (`Android` or `IOS`) — auto-assigns any available device of that platform

For **local** runs:
- Use `list_local_devices` to discover connected devices
- Provide `deviceUUID` from the discovered device

Decision flow:
1. Ask: **Local** or **Cloud** run?
2. **Cloud** → Ask: auto-select or specific device?
   - Auto-select → use `autoSelectPlatform` (derived from app platform)
   - Specific → use `list_supported_devices` → pick `cloudRequirementId`
3. **Local** → use `list_local_devices` → pick `deviceUUID`

## Two-Phase Confirmation Pattern

For update/delete bulk actions:

```text
Step 1: Call without confirm=true -> receive preview + confirmationToken
Step 2: Call with confirm=true + confirmationToken -> execute
```

Always show preview to user before confirm.

## Error Recovery

- Auth/connectivity issue -> call `ping`
- "No test found matching" -> call `list_tests` with `search`
- Upload failure -> verify absolute `filePath`
- No devices found -> verify `platform` filter and casing

## Quick Checklist

- [ ] MCP connectivity verified via `ping`
- [ ] Test or suite identified via `list_tests` / `list_test_suites`
- [ ] Target device(s) selected (cloud or local)
- [ ] Platform compatibility verified (Android↔Android, iOS↔iOS)
- [ ] App mapping resolved via `available_apps`
- [ ] Run plan confirmed with user
- [ ] Test run executed

## Related Skills

- **Creating tests**: See `generate-test` workflow
- **Updating or deleting tests**: See `update-test` workflow

## References

- For step-by-step examples: [workflows.md](references/workflows.md)
- For tool schemas and response fields: [tool-reference.md](references/tool-reference.md)
