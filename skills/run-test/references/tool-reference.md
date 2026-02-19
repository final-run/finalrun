# Tool Reference

FinalRun MCP tools grouped by category.

---

## Conventions

- For all `platform` and `autoSelectPlatform` fields, use lowercase `android` or `ios`.
- `appMapping` is required in run tools.
- `appId` identifies the app container (`appName` lives on that app record), and `appUploadId` identifies the uploaded version/build.
- Name-based run tools support exact/close matching; for deterministic behavior, pass an exact known name.

---

## System

### `ping`
Connectivity health check. Call first to verify API key + MCP endpoint reachability.
Response includes health status and the organization name.

| Param | Type | Required |
|---|---|---|
| _(none)_ | | |

---

## Devices

### `list_supported_devices`
Get cloud device requirements available for test execution.
Response `platform` values are `android` or `ios`.

| Param | Type | Required | Notes |
|---|---|---|---|
| `platform` | string | No | Optional platform filter |

Use returned `requirementId` values as `devices[].cloudRequirementId` in run tools.

---

## Apps

### `available_apps`
List apps and app uploads available to the organization.

| Param | Type | Required | Notes |
|---|---|---|---|
| `limit` | int | No | Max uploads to return (1-500) |
| `platform` | string | No | Optional platform filter |
| `search` | string | No | Search across app name/id, upload id, package name, version, platform |

Response contains:
- `totalApps`
- `totalUploads`
- `apps` keyed by `appId`
- each app node contains `appId`, `appName`, and `uploads`
- `uploads` keyed by `appUploadId`
- each upload node may contain `appUploadId`, `platform`, `name`, `packageName`, `versionName`, `versionCode`, `url`, `uploadSource`, `uploadedAt`

### `create_app`
Create an app and return its `appId` (no binary upload).

| Param | Type | Required | Notes |
|---|---|---|---|
| `name` | string | Yes | App name |
| `appKnowledge` | string | No | Optional app metadata/notes |

### `create_app_version`
Resolve `appId` by app name, upload a binary, and add it as a new app version.

| Param | Type | Required | Notes |
|---|---|---|---|
| `appName` | string | Yes | Existing app name used to resolve `appId` |
| `filePath` | string | Yes | Absolute path to APK/APP file |

---

## Tests

### `create_test`
Create one AI-goal test from name + prompt.

| Param | Type | Required | Notes |
|---|---|---|---|
| `name` | string | Yes | Test name |
| `prompt` | string | Yes | Natural-language AI goal/instruction |

### `list_tests`
List tests in the organization (paginated, searchable).

| Param | Type | Required | Notes |
|---|---|---|---|
| `page` | int | No | 1-based page number |
| `size` | int | No | Items per page |
| `search` | string | No | Optional name/text search filter |

Returns test ids, names, and extracted prompt text for AI-goal tests.

### `update_tests_by_name`
Two-phase bulk update by test name query.

| Param | Type | Required | Notes |
|---|---|---|---|
| `testNameQuery` | string | Yes | Name query used to resolve target tests |
| `confirm` | bool | No | `false`/omitted = preview, `true` = apply changes |
| `confirmationToken` | string | No | Required when `confirm=true` |
| `name` | string | No | New name applied to all matched tests |
| `prompt` | string | No | New AI goal/prompt applied to all matched tests |
| `limit` | int | No | Max matched tests in preview/execute (1-100) |

### `delete_tests_by_name`
Two-phase bulk delete by test name query.

| Param | Type | Required | Notes |
|---|---|---|---|
| `testNameQuery` | string | Yes | Name query used to resolve target tests |
| `confirm` | bool | No | `false`/omitted = preview, `true` = delete |
| `confirmationToken` | string | No | Required when `confirm=true` |
| `limit` | int | No | Max matched tests in preview/execute (1-100) |

---

## Test Suites

### `create_test_suite`
Create one test suite in the organization.

| Param | Type | Required | Notes |
|---|---|---|---|
| `name` | string | Yes | Test suite name |
| `description` | string | No | Optional suite description (defaults to name) |
| `autoSelectPlatform` | string | No | Optional default platform hint |

`create_test_suite` does not take `testIds`. Add/replace suite membership later using `update_test_suites_by_name` with `testIds`.

### `list_test_suites`
List test suites in the organization (paginated, searchable).

| Param | Type | Required | Notes |
|---|---|---|---|
| `page` | int | No | 1-based page number |
| `size` | int | No | Items per page |
| `search` | string | No | Optional name/description search filter |

### `update_test_suites_by_name`
Two-phase bulk update by suite name query.

| Param | Type | Required | Notes |
|---|---|---|---|
| `testSuiteNameQuery` | string | Yes | Name query used to resolve target suites |
| `confirm` | bool | No | `false`/omitted = preview, `true` = apply changes |
| `confirmationToken` | string | No | Required when `confirm=true` |
| `name` | string | No | New name applied to all matched suites |
| `description` | string | No | New description applied to all matched suites |
| `autoSelectPlatform` | string | No | Optional auto-select platform value to apply |
| `testIds` | list | No | Full replacement list of test IDs for each matched suite |
| `platform` | string | No | Optional platform filter while matching suites |
| `limit` | int | No | Max matched suites in preview/execute (1-100) |

### `delete_test_suites_by_name`
Two-phase bulk delete by suite name query.

| Param | Type | Required | Notes |
|---|---|---|---|
| `testSuiteNameQuery` | string | Yes | Name query used to resolve target suites |
| `confirm` | bool | No | `false`/omitted = preview, `true` = delete |
| `confirmationToken` | string | No | Required when `confirm=true` |
| `platform` | string | No | Optional auto-select platform filter while matching suites |
| `limit` | int | No | Max matched suites in preview/execute (1-100) |

---

## Folders

### `browse_folder`
List folders and tests within a folder. Omit `folderId` to browse root level.

| Param | Type | Required | Notes |
|---|---|---|---|
| `folderId` | string | No | Folder ID to browse; omit for root |
| `page` | int | No | 1-based page number |
| `size` | int | No | Items per page |
| `search` | string | No | Optional name/text search filter |

### `create_folder`
Create a folder to organize tests (supports nesting).

| Param | Type | Required | Notes |
|---|---|---|---|
| `name` | string | Yes | Folder name |
| `description` | string | No | Optional folder description |
| `parentFolderId` | string | No | Parent folder id for nesting; omit for root |

### `update_folder`
Update a folder's name and/or description.

| Param | Type | Required | Notes |
|---|---|---|---|
| `folderId` | string | Yes | Folder ID to update |
| `name` | string | No | New folder name |
| `description` | string | No | New folder description |

### `move_folder`
Move a folder to a new parent folder, or to root.

| Param | Type | Required | Notes |
|---|---|---|---|
| `folderId` | string | Yes | Folder ID to move |
| `newParentFolderId` | string | No | Target parent folder ID; omit for root |

### `bulk_move`
Move multiple tests and/or folders in one operation.

| Param | Type | Required | Notes |
|---|---|---|---|
| `folderIds` | list | No | Folder IDs to move |
| `testIds` | list | No | Test IDs to move |
| `targetFolderId` | string | No | Destination folder; omit for root |

### `delete_folder`
Delete a folder and all contents (subfolders/tests).

| Param | Type | Required | Notes |
|---|---|---|---|
| `folderId` | string | Yes | Folder ID to delete |

Fails if any test inside belongs to a test suite.

---

## Test Runs

### `run_test_by_name_on_devices`
Resolve one test by name, create cloud test runs per device target, and start them.

| Param | Type | Required | Notes |
|---|---|---|---|
| `testName` | string | Yes | Test name to resolve (exact/close match) |
| `devices` | list | Yes | Device targets; each item must contain exactly one of `cloudRequirementId` or `autoSelectPlatform` |
| `appMapping` | object | Yes | Required map: `{ appId: appUploadId }` or `{ appId: { id: appUploadId } }` |
| `description` | string | No | Optional test run description |
| `runOn` | string | No | Only `cloud` supported |
| `platform` | string | No | Optional filter while resolving test by name |

Matching guidance:
- Prefer exact names to avoid unintended close matches.
- If multiple candidates look similar, call `list_tests(search=...)` and ask the user to confirm the target before running.

### `run_test_suite_by_name_on_devices`
Resolve one test suite by name, create cloud test runs per device target, and start them.

| Param | Type | Required | Notes |
|---|---|---|---|
| `testSuiteName` | string | Yes | Test suite name to resolve (exact/close match) |
| `devices` | list | Yes | Device targets; each item must contain exactly one of `cloudRequirementId` or `autoSelectPlatform` |
| `appMapping` | object | Yes | Required map: `{ appId: appUploadId }` or `{ appId: { id: appUploadId } }` |
| `description` | string | No | Optional test run description |
| `runOn` | string | No | Only `cloud` supported |

Matching guidance:
- Prefer exact names to avoid unintended close matches.
- If multiple candidates look similar, call `list_test_suites(search=...)` and ask the user to confirm the target before running.
