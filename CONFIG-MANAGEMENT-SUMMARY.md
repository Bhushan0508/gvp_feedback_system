# Configuration Management System - Summary

## 📋 What Was Created

I've set up a complete configuration management system for your feedback system. Instead of hardcoding department questions and email lists, you can now edit them in simple JSON files.

## 📁 Files Created

### 1. Configuration Files (Easy to Edit)

#### `backend/config/departments-questions.json`
Contains all feedback questions for each department with:
- Question text and type (rating_10, smiley_5, binary_yes_no)
- Display order
- Required/optional flags
- Emoji icons

**Example:**
```json
{
  "code": "global_pagoda",
  "name": "Global Pagoda",
  "questions": [
    {
      "key": "cleanliness",
      "label": "How clean is the facility?",
      "type": "rating_10",
      "icon": "🧹",
      "required": true,
      "order": 1
    }
  ]
}
```

#### `backend/config/departments-emails.json`
Contains email recipient lists for report distribution:

**Example:**
```json
{
  "code": "global_pagoda",
  "name": "Global Pagoda",
  "email_recipients": [
    "head@globalpagoda.org",
    "feedback@globalpagoda.org"
  ]
}
```

### 2. Backend Service

#### `backend/src/services/config-loader.js`
A service that loads and manages the configuration files. Provides methods to:
- Get questions by department
- Get emails by department
- Get complete department configuration
- Check if department exists
- Get all departments

**Usage in code:**
```javascript
const configLoader = require('../services/config-loader');

// Get questions for a department
const questions = configLoader.getQuestionsByDepartment('global_pagoda');

// Get email recipients
const emails = configLoader.getEmailsByDepartment('global_pagoda');

// Get all departments
const allDepts = configLoader.getAllDepartments();
```

### 3. Migration Script

#### `scripts/sync-config-to-db.js`
Syncs the config files to MongoDB. Run this after editing the JSON files:

```bash
# Option 1: Using Node directly
node scripts/sync-config-to-db.js

# Option 2: Using npm (added to package.json)
npm run sync:config
```

This script:
- Reads the config files
- Updates existing departments in MongoDB
- Creates new departments if needed
- Preserves all existing feedback data
- Shows detailed progress/results

### 4. Documentation

#### `backend/config/README.md`
Detailed reference for editing the configuration files. Includes:
- File structure explanation
- How to edit questions and emails
- Question type definitions
- Important notes and best practices

#### `SETUP-GUIDE.md`
Complete setup and usage guide including:
- Quick start instructions
- Configuration file examples
- Frontend integration code samples
- Troubleshooting guide
- Best practices

## 🔄 Workflow

### To Change Questions or Email Recipients:

1. **Edit the JSON files:**
   ```
   backend/config/departments-questions.json
   backend/config/departments-emails.json
   ```

2. **Sync to database:**
   ```bash
   npm run sync:config
   ```

3. **Changes take effect immediately** in your application

## 💡 Key Features

✅ **Easy to Edit** - Simple JSON files, no database queries needed
✅ **Version Controllable** - Store config in git for history and rollback
✅ **Reloadable** - Sync script updates database without losing feedback data
✅ **Flexible** - Support 3 question types: rating scale, smiley scale, yes/no
✅ **Centralized** - All departments in one place
✅ **Well Documented** - Comprehensive guides and examples
✅ **Automated** - npm script for easy execution

## 📊 Current Configuration

Your system is now pre-configured with 5 departments:

| Department | Code | Questions | Emails |
|-----------|------|-----------|--------|
| Global Pagoda | `global_pagoda` | 4 | 2 |
| Souvenir Store | `souvenir_store` | 5 | 2 |
| DPVC | `dpvc` | 6 | 2 |
| Dhammalaya | `dhammalaya` | 5 | 2 |
| Food Court | `food_court` | 6 | 2 |

**Total:** 26 questions across 5 departments with customized email lists per department

## 🎯 Next Steps

1. **Review the configuration files:**
   ```
   backend/config/departments-questions.json
   backend/config/departments-emails.json
   ```

2. **Customize as needed:**
   - Edit question text to match your actual feedback needs
   - Adjust question order
   - Update email recipients to real addresses
   - Add/remove questions

3. **Run the sync script:**
   ```bash
   npm run sync:config
   ```

4. **Test in your application:**
   - Verify questions appear correctly in the UI
   - Confirm emails are used for report distribution

5. **Reference the guides:**
   - `backend/config/README.md` - Detailed config reference
   - `SETUP-GUIDE.md` - Complete usage guide

## 🛠️ Using ConfigLoader in Your Code

The ConfigLoader service is available throughout your backend and automatically loads on startup.

### In API Routes:
```javascript
const configLoader = require('../services/config-loader');

router.get('/api/departments/:code/questions', (req, res) => {
  const questions = configLoader.getQuestionsByDepartment(req.params.code);
  res.json(questions);
});
```

### In Services:
```javascript
// Email service - get recipients for a department
const emails = configLoader.getEmailsByDepartment(deptCode);

// Scheduler service - initialize all departments
const allDepts = configLoader.getAllDepartments();
```

## 📝 Available Methods

```javascript
// Get questions for a department
getQuestionsByDepartment(deptCode) → Array

// Get emails for a department
getEmailsByDepartment(deptCode) → Array

// Get complete config for a department
getDepartmentConfig(deptCode) → Object

// Get all departments
getAllDepartments() → Array

// Get all questions by department
getAllQuestions() → Object

// Get all emails by department
getAllEmails() → Object

// Check if department exists
departmentExists(deptCode) → Boolean

// Get all department codes
getAllDepartmentCodes() → Array

// Reload configs from files
reload() → void
```

## 🔐 Best Practices

1. **Always validate JSON** before saving config files
2. **Use meaningful question keys** (snake_case, e.g., `staff_behavior`)
3. **Keep order fields consistent** (1, 2, 3, not random numbers)
4. **Use relevant icons** (Unicode emojis that match the question)
5. **Clear question text** - easy for users to understand
6. **Back up configs** before making major changes
7. **Test new questions** in dev before production
8. **Keep department codes consistent** across both config files

## 📚 Additional Resources

- **Config Reference:** `backend/config/README.md`
- **Setup Guide:** `SETUP-GUIDE.md`
- **Config Loader Code:** `backend/src/services/config-loader.js`
- **Sync Script:** `scripts/sync-config-to-db.js`

## ✨ Summary

You now have a professional configuration management system that allows you to:
- Edit questions and emails in simple JSON files
- Sync changes to MongoDB with one command
- Track config changes in git
- Easily add new departments
- Manage everything without touching the database directly

All the infrastructure is in place and ready to use!
