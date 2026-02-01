#!/usr/bin/env node

/**
 * Migration Script: Sync Configuration Files to MongoDB
 *
 * This script reads from the config files (departments-questions.json and
 * departments-emails.json) and updates the MongoDB database accordingly.
 *
 * Usage:
 *   node scripts/sync-config-to-db.js
 *
 * What it does:
 * - Updates questions for existing departments
 * - Updates email recipients for existing departments
 * - Creates new departments if they exist in config but not in DB
 * - Preserves all existing feedback data
 * - Logs all changes made
 */

require('dotenv').config({ path: '.env' });

const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');

// Import models
const Department = require('../backend/src/models/Department');

// Config paths
const questionsConfigPath = path.join(__dirname, '../backend/config/departments-questions.json');
const emailsConfigPath = path.join(__dirname, '../backend/config/departments-emails.json');

let syncStats = {
  created: 0,
  updated: 0,
  errors: 0,
  details: []
};

async function loadConfigs() {
  try {
    const questionsData = JSON.parse(fs.readFileSync(questionsConfigPath, 'utf8'));
    const emailsData = JSON.parse(fs.readFileSync(emailsConfigPath, 'utf8'));
    return { questionsData, emailsData };
  } catch (error) {
    console.error('❌ Error reading config files:', error.message);
    process.exit(1);
  }
}

async function syncDepartments(questionsData, emailsData) {
  console.log('\n📋 Starting configuration sync...\n');

  // Create lookup map for emails config
  const emailsMap = {};
  emailsData.departments.forEach(dept => {
    emailsMap[dept.code] = {
      email_recipients: dept.email_recipients
    };
  });

  // Process each department from questions config
  for (const questionsDept of questionsData.departments) {
    const deptCode = questionsDept.code;
    const emailConfig = emailsMap[deptCode] || {};

    try {
      const existingDept = await Department.findOne({ code: deptCode });

      if (existingDept) {
        // Update existing department
        const updateData = {
          questions: questionsDept.questions,
          email_recipients: emailConfig.email_recipients || []
        };

        await Department.updateOne({ code: deptCode }, updateData);
        syncStats.updated++;
        syncStats.details.push({
          type: 'UPDATED',
          department: deptCode,
          message: `Updated questions (${questionsDept.questions.length}) and emails (${(emailConfig.email_recipients || []).length})`
        });
        console.log(`✓ UPDATED: ${deptCode} (${questionsDept.questions.length} questions, ${(emailConfig.email_recipients || []).length} emails)`);
      } else {
        // Create new department
        const newDept = new Department({
          code: deptCode,
          name: questionsDept.name,
          description: questionsDept.description || '',
          questions: questionsDept.questions,
          email_recipients: emailConfig.email_recipients || [],
          active: true
        });

        await newDept.save();
        syncStats.created++;
        syncStats.details.push({
          type: 'CREATED',
          department: deptCode,
          message: `Created with ${questionsDept.questions.length} questions and ${(emailConfig.email_recipients || []).length} emails`
        });
        console.log(`✚ CREATED: ${deptCode} (${questionsDept.questions.length} questions, ${(emailConfig.email_recipients || []).length} emails)`);
      }
    } catch (error) {
      syncStats.errors++;
      syncStats.details.push({
        type: 'ERROR',
        department: deptCode,
        message: error.message
      });
      console.error(`✗ ERROR for ${deptCode}:`, error.message);
    }
  }
}

async function connectDB() {
  try {
    const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/feedback_system';

    await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 5000
    });

    console.log('✓ Connected to MongoDB');
    return true;
  } catch (error) {
    console.error('✗ Failed to connect to MongoDB:', error.message);
    console.error('Make sure MongoDB is running and MONGO_URI is set correctly in .env');
    return false;
  }
}

async function main() {
  console.log('═══════════════════════════════════════════════════');
  console.log('  CONFIG SYNC TOOL - Sync Config Files to Database');
  console.log('═══════════════════════════════════════════════════');

  // Connect to database
  const connected = await connectDB();
  if (!connected) {
    process.exit(1);
  }

  // Load config files
  console.log('\n📂 Loading configuration files...');
  const { questionsData, emailsData } = await loadConfigs();
  console.log(`✓ Loaded ${questionsData.departments.length} departments from questions config`);
  console.log(`✓ Loaded ${emailsData.departments.length} departments from emails config`);

  // Sync to database
  await syncDepartments(questionsData, emailsData);

  // Print summary
  console.log('\n═══════════════════════════════════════════════════');
  console.log('  SYNC SUMMARY');
  console.log('═══════════════════════════════════════════════════');
  console.log(`✚ Created:  ${syncStats.created}`);
  console.log(`✓ Updated:  ${syncStats.updated}`);
  console.log(`✗ Errors:   ${syncStats.errors}`);
  console.log('═══════════════════════════════════════════════════\n');

  if (syncStats.errors > 0) {
    console.log('⚠️  Errors encountered during sync:');
    syncStats.details.filter(d => d.type === 'ERROR').forEach(detail => {
      console.log(`  • ${detail.department}: ${detail.message}`);
    });
    console.log();
  }

  // Disconnect and exit
  await mongoose.disconnect();
  console.log('✓ Database connection closed');

  if (syncStats.errors > 0) {
    process.exit(1);
  } else {
    console.log('✓ Configuration sync completed successfully!');
    process.exit(0);
  }
}

// Run the migration
main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
