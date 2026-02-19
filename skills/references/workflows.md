# Workflows

Step-by-step recipes for common FinalRun MCP workflows.

---

## 1. Create and Run a Single Test

> _"Create a test called 'Login Flow' that verifies login, then run it on a Pixel 7."_

### Steps

**1. Verify connectivity**
```json
Tool: ping
Args: {}
```

**2. Create the test**
```json
Tool: create_test
Args: {
  "name": "Login Flow",
  "prompt": "Open the app, enter valid credentials, tap Sign In, and verify the home screen appears."
}
```

**3. Get available devices**
```json
Tool: list_supported_devices
Args: { "platform": "android" }
```
→ Find the Pixel 7 entry, note its `requirementId`.

**4. Get app mapping (if testing a specific upload)**
```json
Tool: available_apps
Args: { "search": "MyApp" }
```
→ Note the `appId` and `appUploadId`.

**5. Run the test**
```json
Tool: run_test_by_name_on_devices
Args: {
  "testName": "Login Flow",
  "devices": [{ "cloudRequirementId": "<pixel7-requirement-id>" }],
  "appMapping": { "<appId>": "<appUploadId>" }
}
```

---

## 2. Upload an App, Then Test It

> _"Upload ./build/app.apk to MyApp, then run the Login Test on it."_

### Steps

**1. Verify connectivity**
```json
Tool: ping
Args: {}
```

**2. Upload to the existing app**
```json
Tool: create_app_version
Args: {
  "appName": "MyApp",
  "filePath": "/absolute/path/to/build/app.apk",
}
```
→ Returns the uploaded app version payload.

**3. Resolve app mapping**
```json
Tool: available_apps
Args: { "search": "MyApp", "limit": 5 }
```
→ Pick the latest upload’s `appUploadId` for `MyApp`.

**4. Run the test**
```json
Tool: run_test_by_name_on_devices
Args: {
  "testName": "Login Test",
  "devices": [{ "autoSelectPlatform": "android" }],
  "appMapping": { "<appId>": "<new-appUploadId>" }
}
```

---

## 3. Run a Test Suite on Multiple Devices

> _"Run the Smoke Tests suite on a Pixel 7 and iPhone 15."_

### Steps

**1. Verify connectivity**
```json
Tool: ping
Args: {}
```

**2. Resolve the suite**
```json
Tool: list_test_suites
Args: { "search": "Smoke Tests" }
```

**3. Get devices**
```json
Tool: list_supported_devices
Args: {}
```
→ Note requirementIds for Pixel 7 and iPhone 15.

**4. Run the suite**
```json
Tool: run_test_suite_by_name_on_devices
Args: {
  "testSuiteName": "Smoke Tests",
  "devices": [
    { "cloudRequirementId": "<pixel7-id>" },
    { "cloudRequirementId": "<iphone15-id>" }
  ]
}
```

---

## 4. Bulk Update Tests

> _"Update all tests with 'login' in the name to use a new prompt."_

### Steps

**1. Preview matches**
```json
Tool: update_tests_by_name
Args: {
  "testNameQuery": "login",
  "prompt": "Open the app, enter valid credentials, tap Sign In, and verify the home screen appears."
}
```
→ Returns list of matched tests + `confirmationToken`. Show to user.

**2. Confirm execution**
```json
Tool: update_tests_by_name
Args: {
  "testNameQuery": "login",
  "confirm": true,
  "confirmationToken": "<token-from-step-1>"
}
```

---

## 5. Bulk Delete Tests

> _"Delete all tests with 'deprecated' in the name."_

### Steps

**1. Preview matches**
```json
Tool: delete_tests_by_name
Args: { "testNameQuery": "deprecated" }
```
→ Returns list of matched tests + `confirmationToken`. Show to user.

**2. Confirm deletion**
```json
Tool: delete_tests_by_name
Args: {
  "testNameQuery": "deprecated",
  "confirm": true,
  "confirmationToken": "<token-from-step-1>"
}
```

---

## 6. Create a New App and Upload

> _"Upload ./build/app.apk as a brand new app called 'MyNewApp'."_

### Steps

**1. Create the app**
```json
Tool: create_app
Args: {
  "name": "MyNewApp"
}
```

**2. Upload the binary to the new app**
```json
Tool: create_app_version
Args: {
  "appName": "MyNewApp",
  "filePath": "/absolute/path/to/build/app.apk"
}
```
