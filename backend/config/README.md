# 📋 Configuration Management - Single Source of Truth

This directory contains **THE ONLY PLACE** to edit department questions and email recipients. All changes made here will automatically sync to the database, frontend, and backend.

---

## ⚡ Quick Start - Making Changes

### To Update Questions or Add New Departments:
1. Edit `departments-questions.json`
2. Save the file
3. Run sync command: `npm run sync:config` (from backend folder)
4. Restart backend if running: `docker-compose restart backend`

### To Update Email Recipients:
1. Edit `departments-emails.json`
2. Save the file
3. Run sync command: `npm run sync:config` (from backend folder)

**That's it!** Changes will be reflected in both database and application.

---

## 📁 Configuration Files

### 1. `departments-questions.json` - Questions & UI Configuration

**Complete structure for each department:**
```json
{
  "code": "dept_code",
  "name": "Department Display Name",
  "description": "Brief description of department",
  "tablet_config": {
    "primary_color": "#3498db",
    "welcome_message": "Thank you message shown to users"
  },
  "questions": [
    {
      "key": "unique_question_id",
      "label": "Question text shown to users?",
      "type": "rating_10|smiley_5|binary_yes_no",
      "icon": "🎯",
      "required": true,
      "order": 1
    }
  ]
}
```

**Question Types & What They Do:**
| Type | Description | User Sees | Value Range |
|------|-------------|-----------|-------------|
| `rating_10` | Numeric rating scale | Buttons 1-10 | 1-5 (currently validated as 1-5) |
| `smiley_5` | Emoji satisfaction scale | 😞 😕 😐 🙂 😊 | 1-5 (Very Poor → Excellent) |
| `binary_yes_no` | Simple Yes/No choice | Yes 👍 / No 👎 | 0 (No) or 1 (Yes) |

**How to Add a New Question:**
```json
{
  "key": "staff_politeness",
  "label": "How polite was our staff?",
  "type": "smiley_5",
  "icon": "👥",
  "required": true,
  "order": 7
}
```

**How to Change Question Order:**
Just update the `"order"` field. Lower numbers appear first.

**Colors for Departments:**
Common color codes you can use:
- Blue: `#3498db`
- Red: `#e74c3c`
- Green: `#27ae60`
- Orange: `#f39c12`
- Purple: `#9b59b6`
- Dark Blue: `#2c3e50`

---

### 2. `departments-emails.json` - Email Report Recipients

**Structure:**
```json
{
  "code": "dept_code",
  "name": "Department Name",
  "description": "Description",
  "email_recipients": [
    "manager@example.com",
    "supervisor@example.com",
    "director@example.com"
  ]
}
```

**How to Add/Remove Emails:**
```json
"email_recipients": [
  "existing@dept.org",
  "newperson@dept.org"     ← Add new emails here
  // "removed@dept.org"    ← Comment out to remove
]
```

---

## 🔄 Syncing Changes to Database

After editing the JSON files, run:

```bash
# From backend folder
npm run sync:config

# OR from project root
cd backend && npm run sync:config

# OR using docker
docker-compose exec backend npm run sync:config
```

**What the sync does:**
- ✅ Reads both JSON files
- ✅ Merges department configs
- ✅ Updates existing departments in database
- ✅ Creates new departments if needed
- ✅ Preserves all existing feedback data
- ✅ Shows summary of changes made

**Example output:**
```
✅ Updated: Food Court (food_court)
   Questions: 8
   Email Recipients: 2
   Color: #f39c12

✨ Created: New Department (new_dept)
   Questions: 5
   Email Recipients: 3
   Color: #2ecc71

📊 Sync Summary:
   ✨ Created: 1 departments
   ✅ Updated: 4 departments
   📦 Total: 5 departments in config
```

---

## 📂 Current Departments

| Code | Name | Questions | Purpose |
|------|------|-----------|---------|
| `global_pagoda` | Global Pagoda | 7 | Main meditation center feedback |
| `souvenir_store` | Souvenir Store | 8 | Shop/merchandise feedback |
| `dpvc` | DPVC Vipassana Centre | 8 | Meditation course feedback |
| `dhammalaya` | Dhammalaya | 7 | Study facility feedback |
| `food_court` | Food Court | 8 | Dining experience feedback |

---

## ⚠️ Important Rules

### ✅ DO:
- Edit questions and emails in these JSON files ONLY
- Use valid JSON format (check with a JSON validator)
- Use unique `key` values for questions within a department
- Use consecutive numbers for `order` (1, 2, 3, 4...)
- Run sync command after making changes
- Test changes in a staging environment first

### ❌ DON'T:
- Don't edit department data directly in MongoDB
- Don't modify department configs in code files
- Don't use duplicate question keys in same department
- Don't skip the sync command after changes
- Don't use special characters in department codes (use lowercase and underscores only)

---

## 🛠️ Troubleshooting

### "Invalid JSON" error when syncing:
- Check your JSON syntax with https://jsonlint.com
- Make sure all quotes are double quotes `"` not single `'`
- Check for missing commas or extra commas
- Ensure no trailing commas after last item in arrays

### Changes not showing in frontend:
1. Make sure you ran `npm run sync:config`
2. Restart the backend: `docker-compose restart backend`
3. Clear browser cache and refresh
4. Check backend logs for errors

### Questions not appearing:
- Check that `required: true` is set
- Verify `order` field is a number
- Make sure question type is one of: `rating_10`, `smiley_5`, `binary_yes_no`
- Check that department code matches exactly

---

## 📝 Example: Adding a Complete New Department

1. **Add to `departments-questions.json`:**
```json
{
  "code": "parking_area",
  "name": "Parking Area",
  "description": "Vehicle parking facility",
  "tablet_config": {
    "primary_color": "#34495e",
    "welcome_message": "Thank you for using our parking facility!"
  },
  "questions": [
    {
      "key": "parking_availability",
      "label": "How easy was it to find parking?",
      "type": "smiley_5",
      "icon": "🅿️",
      "required": true,
      "order": 1
    },
    {
      "key": "security",
      "label": "How secure did you feel?",
      "type": "rating_10",
      "icon": "🔒",
      "required": true,
      "order": 2
    },
    {
      "key": "would_use_again",
      "label": "Would you park here again?",
      "type": "binary_yes_no",
      "icon": "🔄",
      "required": true,
      "order": 3
    }
  ]
}
```

2. **Add to `departments-emails.json`:**
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

3. **Run sync:**
```bash
npm run sync:config
```

4. **Restart backend:**
```bash
docker-compose restart backend
```

Done! New department is live.

---

## 🔗 Related Files

- **Sync Script:** `backend/scripts/sync-config-to-db.js`
- **Database Model:** `backend/src/models/Department.js`
- **API Routes:** `backend/src/routes/departments.js`
- **Frontend Forms:** `frontend/lib/pages/tablet_feedback_form.dart`

---

For questions or support, contact the development team.
