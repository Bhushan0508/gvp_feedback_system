#!/usr/bin/env node

/**
 * Sync Configuration to Database
 *
 * This script reads department configurations from JSON files and syncs them to MongoDB.
 *
 * Configuration Files:
 * - backend/config/departments-questions.json - Questions and tablet config
 * - backend/config/departments-emails.json - Email recipients
 *
 * Usage:
 *   npm run sync:config
 *   OR
 *   node scripts/sync-config-to-db.js
 */

require('dotenv').config();
const { syncConfigToDb } = require('../src/scripts/syncConfigToDb');

console.log('\n╔══════════════════════════════════════════════════════════╗');
console.log('║   Configuration Sync - JSON Files to Database          ║');
console.log('╚══════════════════════════════════════════════════════════╝\n');

syncConfigToDb();
