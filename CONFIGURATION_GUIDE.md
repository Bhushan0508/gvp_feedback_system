# 📋 Configuration Management - Quick Reference Guide

## ✅ What's Been Set Up

Your feedback system now has a **centralized configuration system** where ALL department questions, options, and email recipients are managed from JSON files.

### Configuration Files Location
```
backend/config/
├── departments-questions.json  ← Edit questions, options, colors here
├── departments-emails.json     ← Edit email recipients here
└── README.md                   ← Detailed documentation
```

---

## 🚀 Quick Start - Making Changes

### To Add/Edit Questions:

1. **Edit the file:**
   ```bash
   nano backend/config/departments-questions.json
   # OR use any text editor
   ```

2. **Make your changes** (see examples below)

3. **Save the file**

4. **Sync to database:**
   ```bash
   # From backend folder in container
   docker-compose exec backend npm run sync:config

   # OR copy files and run sync
   docker cp backend/config/departments-questions.json feedback-backend:/app/config/
   docker-compose exec backend npm run sync:config
   ```

5. **Restart backend** (if needed):
   ```bash
   docker-compose restart backend
   ```

### To Update Email Recipients:

1. Edit `backend/config/departments-emails.json`
2. Run sync: `docker-compose exec backend npm run sync:config`
3. Done! No restart needed.

---

## 📊 Current Departments & Questions

| Department | Code | Questions | Color | Email Recipients |
|------------|------|-----------|-------|------------------|
| **Global Pagoda** | `global_pagoda` | 7 | Blue (#3498db) | 2 |
| **Souvenir Store** | `souvenir_store` | 8 | Red (#e74c3c) | 2 |
| **DPVC** | `dpvc` | 8 | Purple (#9b59b6) | 2 |
| **Dhammalaya** | `dhammalaya` | 7 | Green (#27ae60) | 2 |
| **Food Court** | `food_court` | 8 | Orange (#f39c12) | 2 |

### Question Types Available

| Type | What Users See | Values | Example Use |
|------|----------------|--------|-------------|
| `smiley_5` | 😞 😕 😐 🙂 😊 | 1-5 | Satisfaction level |
| `rating_10` | Numbered buttons 1-10 | 1-5* | Specific ratings |
| `binary_yes_no` | Yes 👍 / No 👎 | 0 or 1 | Yes/No questions |

*Note: Currently validated as 1-5 even though labeled as rating_10

---

## 📝 Example: Adding a New Question

```json
{
  "key": "parking_experience",
  "label": "How was your parking experience?",
  "type": "smiley_5",
  "icon": "🅿️",
  "required": true,
  "order": 9
}
```

**Fields explained:**
- `key`: Unique identifier (use snake_case)
- `label`: Question text shown to users
- `type`: One of: smiley_5, rating_10, binary_yes_no
- `icon`: Emoji or icon
- `required`: true/false
- `order`: Display sequence (1, 2, 3...)

---

## 📝 Example: Adding a Complete New Department

**1. Add to `departments-questions.json`:**
```json
{
  "code": "parking_area",
  "name": "Parking Area",
  "description": "Vehicle parking facility",
  "tablet_config": {
    "primary_color": "#34495e",
    "welcome_message": "Thank you for using our parking!"
  },
  "questions": [
    {
      "key": "ease_of_parking",
      "label": "How easy was it to find parking?",
      "type": "smiley_5",
      "icon": "🅿️",
      "required": true,
      "order": 1
    },
    {
      "key": "security_rating",
      "label": "How secure did you feel?",
      "type": "rating_10",
      "icon": "🔒",
      "required": true,
      "order": 2
    },
    {
      "key": "would_park_again",
      "label": "Would you park here again?",
      "type": "binary_yes_no",
      "icon": "🔄",
      "required": true,
      "order": 3
    }
  ]
}
```

**2. Add to `departments-emails.json`:**
```json
{
  "code": "parking_area",
  "name": "Parking Area",
  "description": "Vehicle parking facility",
  "email_recipients": [
    "parking@globalpagoda.org",
    "security@globalpagoda.org"
  ]
}
```

**3. Run sync:**
```bash
docker cp backend/config/departments-questions.json feedback-backend:/app/config/
docker cp backend/config/departments-emails.json feedback-backend:/app/config/
docker-compose exec backend npm run sync:config
```

---

## 🔄 Workflow Diagram

```
Edit JSON Files
     ↓
Copy to Container (if needed)
     ↓
Run Sync Command
     ↓
Database Updated
     ↓
API Returns New Questions
     ↓
Frontend Shows New Questions
```

---

## ⚙️ Available Colors for Departments

```json
{
  "primary_color": "#3498db"  // Blue
  "primary_color": "#e74c3c"  // Red
  "primary_color": "#27ae60"  // Green
  "primary_color": "#f39c12"  // Orange
  "primary_color": "#9b59b6"  // Purple
  "primary_color": "#34495e"  // Dark Blue
  "primary_color": "#e67e22"  // Carrot Orange
  "primary_color": "#1abc9c"  // Turquoise
}
```

---

## 🧪 Testing Your Changes

After syncing, test the API:

```bash
# Check all departments
curl http://localhost:3001/api/departments | jq '.data.departments'

# Check specific department
curl http://localhost:3001/api/departments/food_court | jq '.data.department'

# See just the questions
curl http://localhost:3001/api/departments/food_court | jq '.data.department.questions'
```

---

## ❗ Important Notes

### ✅ DO:
- Always edit the JSON files in `backend/config/`
- Run sync command after changes
- Use unique question keys within a department
- Test in staging before production
- Backup config files before major changes

### ❌ DON'T:
- Don't edit database directly
- Don't modify hardcoded department configs in code
- Don't skip the sync command
- Don't use special characters in department codes
- Don't forget to copy files to container if needed

---

## 🔧 Troubleshooting

### Changes not showing?
1. Did you copy the file to container?
   ```bash
   docker cp backend/config/departments-questions.json feedback-backend:/app/config/
   ```

2. Did you run the sync?
   ```bash
   docker-compose exec backend npm run sync:config
   ```

3. Did you restart backend?
   ```bash
   docker-compose restart backend
   ```

### JSON Syntax Errors?
Validate your JSON at: https://jsonlint.com

### Authentication Errors?
The sync script uses environment variables from docker-compose. Make sure:
- MongoDB is running
- Credentials in `.env` are correct

---

## 📂 File Structure

```
gvp_feedback_system/
├── backend/
│   ├── config/
│   │   ├── departments-questions.json    ← EDIT HERE for questions
│   │   ├── departments-emails.json       ← EDIT HERE for emails
│   │   └── README.md                     ← Detailed docs
│   ├── scripts/
│   │   └── sync-config-to-db.js         ← Sync command wrapper
│   └── src/
│       └── scripts/
│           └── syncConfigToDb.js        ← Sync implementation
└── CONFIGURATION_GUIDE.md               ← This file
```

---

## 📞 Need Help?

1. Check `backend/config/README.md` for detailed documentation
2. Review existing department configurations for examples
3. Test changes in development first
4. Contact development team if issues persist

---

## 🎯 Summary

**Single Source of Truth:** `backend/config/` folder
**Sync Command:** `npm run sync:config`
**Edit → Sync → Restart** = Changes Live! ✨
