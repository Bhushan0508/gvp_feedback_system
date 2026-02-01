const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const { Department } = require('../models');

const MONGODB_URI = process.env.MONGO_URI || process.env.MONGODB_URI || 'mongodb://mongodb:27017/feedback_system';

// Load configuration files
const loadConfig = () => {
  const questionsPath = path.join(__dirname, '../../config/departments-questions.json');
  const emailsPath = path.join(__dirname, '../../config/departments-emails.json');

  if (!fs.existsSync(questionsPath)) {
    throw new Error(`Questions config not found at: ${questionsPath}`);
  }

  if (!fs.existsSync(emailsPath)) {
    throw new Error(`Emails config not found at: ${emailsPath}`);
  }

  const questionsConfig = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));
  const emailsConfig = JSON.parse(fs.readFileSync(emailsPath, 'utf8'));

  return { questionsConfig, emailsConfig };
};

// Merge department configs
const mergeDepartmentConfigs = (questionsConfig, emailsConfig) => {
  const departmentMap = new Map();

  // Add departments from questions config
  questionsConfig.departments.forEach(dept => {
    departmentMap.set(dept.code, {
      code: dept.code,
      name: dept.name,
      description: dept.description || '',
      questions: dept.questions || [],
      tablet_config: dept.tablet_config || {
        primary_color: '#3498db',
        welcome_message: 'Thank you for your feedback!'
      },
      email_recipients: [],
      active: true
    });
  });

  // Add email recipients from emails config
  emailsConfig.departments.forEach(dept => {
    if (departmentMap.has(dept.code)) {
      const existing = departmentMap.get(dept.code);
      existing.email_recipients = dept.email_recipients || [];

      // Update name and description if provided
      if (dept.name) existing.name = dept.name;
      if (dept.description) existing.description = dept.description;

      departmentMap.set(dept.code, existing);
    } else {
      // Department exists in emails but not in questions
      departmentMap.set(dept.code, {
        code: dept.code,
        name: dept.name,
        description: dept.description || '',
        questions: [],
        tablet_config: {
          primary_color: '#3498db',
          welcome_message: 'Thank you for your feedback!'
        },
        email_recipients: dept.email_recipients || [],
        active: true
      });
    }
  });

  return Array.from(departmentMap.values());
};

// Sync departments to database
const syncToDatabase = async (departments) => {
  let created = 0;
  let updated = 0;
  let errors = 0;

  for (const deptData of departments) {
    try {
      const existing = await Department.findOne({ code: deptData.code });

      if (existing) {
        // Update existing department
        await Department.updateOne(
          { code: deptData.code },
          { $set: deptData }
        );
        console.log(`✅ Updated: ${deptData.name} (${deptData.code})`);
        console.log(`   Questions: ${deptData.questions.length}`);
        console.log(`   Email Recipients: ${deptData.email_recipients.length}`);
        console.log(`   Color: ${deptData.tablet_config.primary_color}`);
        updated++;
      } else {
        // Create new department
        await Department.create(deptData);
        console.log(`✨ Created: ${deptData.name} (${deptData.code})`);
        console.log(`   Questions: ${deptData.questions.length}`);
        console.log(`   Email Recipients: ${deptData.email_recipients.length}`);
        console.log(`   Color: ${deptData.tablet_config.primary_color}`);
        created++;
      }
      console.log('');
    } catch (error) {
      console.error(`❌ Error syncing ${deptData.code}:`, error.message);
      errors++;
    }
  }

  return { created, updated, errors };
};

// Main sync function
async function syncConfigToDb() {
  try {
    console.log('🔄 Starting Configuration Sync...\n');
    console.log('=' .repeat(60));

    // Connect to MongoDB
    console.log('🔌 Connecting to MongoDB...');
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Load configuration files
    console.log('📂 Loading configuration files...');
    const { questionsConfig, emailsConfig } = loadConfig();
    console.log(`✅ Loaded ${questionsConfig.departments.length} departments from questions config`);
    console.log(`✅ Loaded ${emailsConfig.departments.length} departments from emails config\n`);

    // Merge configurations
    console.log('🔀 Merging configurations...');
    const departments = mergeDepartmentConfigs(questionsConfig, emailsConfig);
    console.log(`✅ Merged into ${departments.length} unique departments\n`);

    // Sync to database
    console.log('💾 Syncing to Database...\n');
    const stats = await syncToDatabase(departments);

    // Summary
    console.log('=' .repeat(60));
    console.log('\n📊 Sync Summary:');
    console.log(`   ✨ Created: ${stats.created} departments`);
    console.log(`   ✅ Updated: ${stats.updated} departments`);
    console.log(`   ❌ Errors: ${stats.errors} departments`);
    console.log(`   📦 Total: ${departments.length} departments in config`);

    const totalInDb = await Department.countDocuments();
    console.log(`   🗄️  Total in DB: ${totalInDb} departments`);

    console.log('\n✅ Configuration sync complete!\n');
    console.log('=' .repeat(60));

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Sync failed:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  syncConfigToDb();
}

module.exports = { syncConfigToDb, loadConfig, mergeDepartmentConfigs };
