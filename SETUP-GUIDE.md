# Configuration Management Setup Guide

This guide explains how to use the new configuration files for managing department questions and email recipients.

## What's New?

You now have two editable configuration files instead of hardcoding data in the database:

1. **`backend/config/departments-questions.json`** - Define all feedback questions for each department
2. **`backend/config/departments-emails.json`** - Define email recipients for report distribution

## File Locations

```
gvp_feedback_system/
├── backend/
│   ├── config/
│   │   ├── departments-questions.json    ← Edit questions here
│   │   ├── departments-emails.json       ← Edit emails here
│   │   └── README.md                     ← Detailed reference
│   └── src/
│       └── services/
│           └── config-loader.js          ← Service that loads configs
├── scripts/
│   └── sync-config-to-db.js              ← Script to sync to database
└── SETUP-GUIDE.md (this file)
```

## Quick Start

### Step 1: Edit Configuration Files

#### Edit Questions (`backend/config/departments-questions.json`)

```json
{
  "departments": [
    {
      "code": "global_pagoda",
      "name": "Global Pagoda",
      "questions": [
        {
          "key": "cleanliness",
          "label": "How clean and well-maintained is the facility?",
          "type": "rating_10",
          "icon": "🧹",
          "required": true,
          "order": 1
        },
        // Add more questions here
      ]
    }
    // Add more departments here
  ]
}
```

#### Edit Emails (`backend/config/departments-emails.json`)

```json
{
  "departments": [
    {
      "code": "global_pagoda",
      "name": "Global Pagoda",
      "description": "Main meditation and spiritual center",
      "email_recipients": [
        "head@globalpagoda.org",
        "feedback@globalpagoda.org"
      ]
    }
    // Add more departments here
  ]
}
```

### Step 2: Sync Configuration to Database

After editing the config files, run the sync script to update MongoDB:

```bash
cd /home/feedback/gvp_feedback_system

# Using Node
node scripts/sync-config-to-db.js

# Or if you have npm scripts set up
npm run sync:config
```

Expected output:
```
═══════════════════════════════════════════════════
  CONFIG SYNC TOOL
═══════════════════════════════════════════════════
✓ Connected to MongoDB
✓ Loaded 5 departments from questions config
✓ Loaded 5 departments from emails config

📋 Starting configuration sync...

✓ UPDATED: global_pagoda (4 questions, 2 emails)
✓ UPDATED: souvenir_store (5 questions, 2 emails)
✓ UPDATED: dpvc (6 questions, 2 emails)
✓ UPDATED: dhammalaya (5 questions, 2 emails)
✓ UPDATED: food_court (6 questions, 2 emails)

═══════════════════════════════════════════════════
  SYNC SUMMARY
═══════════════════════════════════════════════════
✚ Created:  0
✓ Updated:  5
✗ Errors:   0
```

## Using ConfigLoader in Code

The `ConfigLoader` is available as a service throughout your backend:

### In Routes/Controllers

```javascript
const configLoader = require('../services/config-loader');

// Get questions for a department
router.get('/api/departments/:code/questions', (req, res) => {
  const questions = configLoader.getQuestionsByDepartment(req.params.code);
  res.json(questions);
});

// Get email recipients for a department
router.get('/api/departments/:code/emails', (req, res) => {
  const emails = configLoader.getEmailsByDepartment(req.params.code);
  res.json(emails);
});

// Get complete department configuration
router.get('/api/departments/:code/config', (req, res) => {
  const config = configLoader.getDepartmentConfig(req.params.code);
  res.json(config);
});
```

### In Services

```javascript
const configLoader = require('../services/config-loader');

// In email service - send report to department emails
function sendReport(deptCode, reportPath) {
  const emails = configLoader.getEmailsByDepartment(deptCode);
  // ... send report to emails
}

// In scheduler service - get all departments and their questions
function initializeSchedules() {
  const allDepts = configLoader.getAllDepartments();
  allDepts.forEach(dept => {
    // ... initialize schedule for each department
  });
}
```

### Available Methods

```javascript
configLoader.getQuestionsByDepartment(deptCode)
// Returns: [{ key, label, type, icon, required, order }]

configLoader.getEmailsByDepartment(deptCode)
// Returns: ["email1@example.com", "email2@example.com"]

configLoader.getDepartmentConfig(deptCode)
// Returns: { code, name, description, questions, email_recipients }

configLoader.getAllDepartments()
// Returns: [{ code, name, questions, email_recipients }, ...]

configLoader.getAllQuestions()
// Returns: { dept_code1: [...questions], dept_code2: [...questions] }

configLoader.getAllEmails()
// Returns: { dept_code1: [...emails], dept_code2: [...emails] }

configLoader.departmentExists(deptCode)
// Returns: boolean

configLoader.getAllDepartmentCodes()
// Returns: ["global_pagoda", "souvenir_store", ...]

configLoader.reload()
// Reloads configs from files (useful if watching for changes)
```

## Question Types

**Three question types are supported:**

### 1. Rating Scale (0-10)
```json
{
  "type": "rating_10",
  "label": "How satisfied are you?",
  "icon": "⭐"
}
```
- Displays 0-10 scale
- UI: Slider, buttons, or numeric input

### 2. Smiley Scale (5-point)
```json
{
  "type": "smiley_5",
  "label": "How was your experience?",
  "icon": "😊"
}
```
- Displays: 😢 😟 😐 🙂 😄
- Values: 1, 2, 3, 4, 5

### 3. Binary Yes/No
```json
{
  "type": "binary_yes_no",
  "label": "Would you recommend?",
  "icon": "👍"
}
```
- Displays: Yes / No buttons
- Values: true / false

## Department Codes

Standard codes that should be consistent across both files:

| Code | Department |
|------|-----------|
| `global_pagoda` | Global Pagoda |
| `souvenir_store` | Souvenir Store |
| `dpvc` | DPVC - Dhamma Pattana Vipassana Centre |
| `dhammalaya` | Dhammalaya |
| `food_court` | Food Court |

## Frontend Integration

### Getting Questions from Backend

```javascript
// In your Flutter/Web app API service
Future<List<Question>> getDepartmentQuestions(String deptCode) async {
  final response = await http.get(
    Uri.parse('$apiUrl/api/departments/$deptCode/questions'),
  );
  // Parse and return questions
}

// In your feedback form widget
onLoadDepartment(String deptCode) {
  questions = await apiService.getDepartmentQuestions(deptCode);
  // Render questions in form
}
```

### Direct Config File Access (Development)

For development/testing, you can also read the config files directly:

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadQuestionsConfig() async {
  final jsonString = await rootBundle.loadString('assets/config/departments-questions.json');
  return jsonDecode(jsonString);
}
```

## Editing Workflow

### Typical Steps

1. **Open** `backend/config/departments-questions.json`
2. **Find** the department you want to edit
3. **Modify** questions:
   - Change question text
   - Add new questions
   - Remove questions
   - Reorder by changing `order` field
4. **Save** the file
5. **Open** `backend/config/departments-emails.json`
6. **Update** email recipients if needed
7. **Save** the file
8. **Run** `node scripts/sync-config-to-db.js`
9. **Verify** the changes in your application

### Example: Adding a New Question

Before:
```json
"questions": [
  { "key": "cleanliness", "label": "...", "order": 1 },
  { "key": "staff_behavior", "label": "...", "order": 2 }
]
```

After adding a question at position 2:
```json
"questions": [
  { "key": "cleanliness", "label": "...", "order": 1 },
  { "key": "new_question", "label": "New question text?", "type": "rating_10", "icon": "✨", "required": true, "order": 2 },
  { "key": "staff_behavior", "label": "...", "order": 3 }  // Note: order changed from 2 to 3
]
```

### Example: Changing Email Recipients

Before:
```json
"email_recipients": [
  "old@example.com"
]
```

After:
```json
"email_recipients": [
  "new@example.com",
  "manager@example.com"
]
```

Run sync script, and new emails will be used for report distribution.

## Troubleshooting

### Sync script fails with "Cannot find module"

Make sure you're running from the project root:
```bash
cd /home/feedback/gvp_feedback_system
node scripts/sync-config-to-db.js
```

### Changes not reflected in UI

1. Ensure you ran the sync script
2. Check that department codes match in both config files
3. Verify MongoDB connection is working
4. Check backend logs for errors

### JSON validation errors

Use a JSON validator to check your JSON syntax:
- VS Code with JSON extension
- [jsonlint.com](https://jsonlint.com)
- Online JSON validators

Common issues:
- Missing commas between array elements
- Trailing commas after last element
- Unquoted property names
- Unescaped special characters in strings

### Email not sending to new recipients

1. Run the sync script to update database
2. Verify email addresses are correct
3. Check email service configuration
4. Check backend logs for email errors

## Best Practices

1. **Backup before major changes** - Keep a copy of working config files
2. **Test new questions** - Add and test before going to production
3. **Consistent codes** - Use snake_case for question keys (e.g., `staff_behavior`)
4. **Meaningful icons** - Use Unicode emojis relevant to the question
5. **Clear labels** - Write questions that are easy to understand
6. **Order matters** - Arrange questions in logical flow
7. **Required fields** - Mark mandatory questions as `required: true`
8. **Validate JSON** - Always validate JSON before running sync script

## Support & Documentation

- See `backend/config/README.md` for detailed configuration reference
- Check `backend/src/services/config-loader.js` for available methods
- Review `scripts/sync-config-to-db.js` for sync details
