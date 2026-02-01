# Configuration Files

This directory contains editable configuration files for managing department questions and email recipients.

## Files Overview

### 1. `departments-questions.json`

Contains all feedback questions for each department.

**Structure:**
```json
{
  "departments": [
    {
      "code": "dept_code",
      "name": "Department Name",
      "questions": [
        {
          "key": "unique_question_key",
          "label": "What is the question text?",
          "type": "rating_10|smiley_5|binary_yes_no",
          "icon": "emoji_or_icon",
          "required": true,
          "order": 1
        }
      ]
    }
  ]
}
```

**Question Types:**
- `rating_10` - 10-point scale (0-10)
- `smiley_5` - 5-point smiley face scale (😢 😟 😐 🙂 😄)
- `binary_yes_no` - Yes/No binary choice

**How to Edit:**
1. Open `departments-questions.json`
2. Navigate to the department you want to edit
3. Add/modify questions in the `questions` array
4. Update the `order` field to control display sequence (1, 2, 3, etc.)
5. Save the file
6. The app will automatically load the updated questions

**Example - Adding a new question:**
```json
{
  "key": "staff_courtesy",
  "label": "How courteous was the staff?",
  "type": "rating_10",
  "icon": "👥",
  "required": true,
  "order": 5
}
```

---

### 2. `departments-emails.json`

Contains email recipient lists for report distribution per department.

**Structure:**
```json
{
  "departments": [
    {
      "code": "dept_code",
      "name": "Department Name",
      "description": "Department Description",
      "email_recipients": [
        "email1@example.com",
        "email2@example.com"
      ]
    }
  ]
}
```

**How to Edit:**
1. Open `departments-emails.json`
2. Find the department
3. Add/remove email addresses in the `email_recipients` array
4. Save the file
5. Emails will be automatically used for report distribution

**Example - Adding/Removing Emails:**
```json
"email_recipients": [
  "manager@dept.org",      // existing email
  "supervisor@dept.org",   // new email to add
  // "old@dept.org"        // removed/commented out email
]
```

---

## Department Codes

The following departments are configured:
- `global_pagoda` - Global Pagoda
- `souvenir_store` - Souvenir Store
- `dpvc` - DPVC - Dhamma Pattana Vipassana Centre
- `dhammalaya` - Dhammalaya
- `food_court` - Food Court

## Using Config Loader in Code

The `ConfigLoader` service automatically loads these files on startup.

**Examples:**

```javascript
const configLoader = require('./services/config-loader');

// Get questions for a department
const questions = configLoader.getQuestionsByDepartment('global_pagoda');

// Get email recipients for a department
const emails = configLoader.getEmailsByDepartment('global_pagoda');

// Get complete department configuration
const deptConfig = configLoader.getDepartmentConfig('global_pagoda');

// Get all departments
const allDepts = configLoader.getAllDepartments();

// Check if department exists
const exists = configLoader.departmentExists('global_pagoda');
```

---

## Important Notes

1. **File Format:** Both files must be valid JSON. Invalid JSON will cause errors on startup.

2. **Department Codes:** Must match between both files for consistency.

3. **Question Keys:** Should be unique within a department and use snake_case (e.g., `staff_behavior`).

4. **Order Field:** Controls the sequence questions appear in the UI. Use consecutive numbers (1, 2, 3...).

5. **Required Field:** Set to `true` for mandatory questions, `false` for optional.

6. **Icons:** Can use Unicode emojis or any icon identifier your UI supports.

7. **Email Validation:** Ensure email addresses are valid format. The system will validate on save.

---

## Syncing with Database

To update the MongoDB database with changes from these config files, use the migration script:

```bash
node scripts/sync-config-to-db.js
```

This will:
- Update existing department questions and emails
- Create new departments if needed
- Preserve existing feedback data
