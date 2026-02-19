---
name: finalrun-test-runner
description: >
  Run mobile app tests on cloud devices via the FinalRun MCP server.
  Use when: (1) creating/managing AI-goal tests, (2) uploading app binaries,
  (3) running tests or suites on cloud devices, (4) bulk update/delete tasks.
---

# FinalRun Test Runner

Orchestrate FinalRun MCP tools to create, manage, and run mobile app tests.

## Core Concepts

- **Test**: A single automated flow (one scenario).
- **Test Suite**: A group of one or more tests executed together.
- **Test Runs**: Historical execution records of tests or suites that already ran.

## Quick Start

```text
1. ping
2. create_test(name, prompt)
3. list_supported_devices()
4. available_apps()            # required, select appId + appUploadId
5. run_test_by_name_on_devices(testName, devices, appMapping)
```

## Required Inputs

- **Create Test**: `name`, `prompt`
- **Run Test**: test + `appMapping` + one or more compatible devices
- **Create Test Suite**: suite `name` (add tests afterward using `update_test_suites_by_name` with `testIds`)
- **Run Test Suite**: suite + `appMapping` + one or more compatible devices

## Platform Compatibility Rule (Strict)

- Android app upload -> Android devices only
- iOS app upload -> iOS devices only
- Never map Android app to iOS device, or iOS app to Android device
- For `platform` and `autoSelectPlatform` parameters, use lowercase values: `android` or `ios`

## Upload Routing Rule

When user asks to upload a new build, always ask:

- “Should this upload go to an existing app or a new app container?”
- “Confirm platform: Android or iOS?”

Then follow:

1. **Existing app path**
   - Call `available_apps`
   - Filter/select by platform (`android` or `ios`)
   - Pick target app node by `appId`, then read its `appName`
   - Call `create_app_version(appName, filePath)` using that exact `appName`

2. **New app path**
   - Confirm platform (`android` or `ios`)
   - Call `create_app(name, appKnowledge?)` -> get `appId`
   - Call `create_app_version(appName, filePath)` to upload first version

## Core Workflows

- **Create + Run**: `ping` -> `create_test` -> `list_supported_devices` -> `available_apps` -> `run_test_by_name_on_devices`
- **Upload + Run (Existing App)**: `ping` -> `create_app_version` -> `create_test` -> `list_supported_devices` -> `run_test_by_name_on_devices`
- **Upload + Run (New App)**: `ping` -> `create_app` -> `create_app_version` -> `create_test` -> `list_supported_devices` -> `run_test_by_name_on_devices`
- **Suite Run**: `ping` -> `list_test_suites` -> `list_supported_devices` -> `run_test_suite_by_name_on_devices`
- **Bulk Update Tests**: `update_tests_by_name` (preview) -> `update_tests_by_name` (confirm)
- **Bulk Delete Tests**: `delete_tests_by_name` (preview) -> `delete_tests_by_name` (confirm)
- **Bulk Update Suites**: `update_test_suites_by_name` (preview) -> `update_test_suites_by_name` (confirm)
- **Bulk Delete Suites**: `delete_test_suites_by_name` (preview) -> `delete_test_suites_by_name` (confirm)

## Two-Phase Confirmation Pattern

For update/delete bulk actions:

```text
Step 1: Call without confirm=true -> receive preview + confirmationToken
Step 2: Call with confirm=true + confirmationToken -> execute
```

Always show preview to user before confirm.

## Device Targeting

Each device target must include exactly one:
- `cloudRequirementId`
- `autoSelectPlatform` (`android` or `ios`)

## App Mapping

When running a test or suite, `appMapping` is required.

Identity rules:
- `appId` identifies the app container (the same app record that includes `appName`).
- `appUploadId` identifies the uploaded version/build under that app.

Canonical format:

```json
{ "appId": "appUploadId" }
```

Also accepted:

```json
{ "appId": { "id": "appUploadId" } }
```

Use `available_apps` response to get valid pairs.

## Error Recovery

- Auth/connectivity issue -> call `ping`
- “No test found matching” -> call `list_tests` with `search`
- Upload failure -> verify absolute `filePath`
- No devices found -> verify `platform` filter and casing

## References

- For step-by-step examples: [workflows.md](../references/workflows.md)
- For tool schemas and response fields: [tool-reference.md](../references/tool-reference.md)
