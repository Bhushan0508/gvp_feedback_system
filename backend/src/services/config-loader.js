const fs = require('fs');
const path = require('path');

class ConfigLoader {
  constructor() {
    this.questionsConfig = null;
    this.emailsConfig = null;
    this.loadConfigs();
  }

  loadConfigs() {
    try {
      const questionsPath = path.join(__dirname, '../../config/departments-questions.json');
      const emailsPath = path.join(__dirname, '../../config/departments-emails.json');

      const questionsData = fs.readFileSync(questionsPath, 'utf8');
      const emailsData = fs.readFileSync(emailsPath, 'utf8');

      this.questionsConfig = JSON.parse(questionsData);
      this.emailsConfig = JSON.parse(emailsData);

      console.log('✓ Config files loaded successfully');
    } catch (error) {
      console.error('Error loading config files:', error.message);
      throw new Error('Failed to load configuration files');
    }
  }

  /**
   * Get all questions for a specific department
   * @param {string} deptCode - Department code
   * @returns {Array} Array of questions sorted by order
   */
  getQuestionsByDepartment(deptCode) {
    const dept = this.questionsConfig.departments.find(d => d.code === deptCode);
    if (!dept) return [];
    return dept.questions.sort((a, b) => a.order - b.order);
  }

  /**
   * Get all questions for all departments
   * @returns {Object} Object with department codes as keys and questions as values
   */
  getAllQuestions() {
    const result = {};
    this.questionsConfig.departments.forEach(dept => {
      result[dept.code] = dept.questions.sort((a, b) => a.order - b.order);
    });
    return result;
  }

  /**
   * Get email recipients for a specific department
   * @param {string} deptCode - Department code
   * @returns {Array} Array of email addresses
   */
  getEmailsByDepartment(deptCode) {
    const dept = this.emailsConfig.departments.find(d => d.code === deptCode);
    if (!dept) return [];
    return dept.email_recipients;
  }

  /**
   * Get all department email configurations
   * @returns {Object} Object with department codes as keys and email arrays as values
   */
  getAllEmails() {
    const result = {};
    this.emailsConfig.departments.forEach(dept => {
      result[dept.code] = dept.email_recipients;
    });
    return result;
  }

  /**
   * Get complete department configuration (questions + emails)
   * @param {string} deptCode - Department code
   * @returns {Object} Combined department configuration
   */
  getDepartmentConfig(deptCode) {
    const questions = this.getQuestionsByDepartment(deptCode);
    const emails = this.getEmailsByDepartment(deptCode);
    const questionDept = this.questionsConfig.departments.find(d => d.code === deptCode);
    const emailDept = this.emailsConfig.departments.find(d => d.code === deptCode);

    if (!questionDept && !emailDept) return null;

    return {
      code: deptCode,
      name: questionDept?.name || emailDept?.name,
      description: emailDept?.description || questionDept?.description,
      questions: questions,
      email_recipients: emails
    };
  }

  /**
   * Get all departments with their complete configuration
   * @returns {Array} Array of department configurations
   */
  getAllDepartments() {
    return this.questionsConfig.departments.map(dept => ({
      code: dept.code,
      name: dept.name,
      questions: dept.questions.sort((a, b) => a.order - b.order),
      email_recipients: this.getEmailsByDepartment(dept.code)
    }));
  }

  /**
   * Check if a department exists
   * @param {string} deptCode - Department code
   * @returns {boolean}
   */
  departmentExists(deptCode) {
    return this.questionsConfig.departments.some(d => d.code === deptCode) ||
           this.emailsConfig.departments.some(d => d.code === deptCode);
  }

  /**
   * Get all department codes
   * @returns {Array} Array of department codes
   */
  getAllDepartmentCodes() {
    const codes = new Set();
    this.questionsConfig.departments.forEach(d => codes.add(d.code));
    this.emailsConfig.departments.forEach(d => codes.add(d.code));
    return Array.from(codes);
  }

  /**
   * Reload configurations from files (useful for watching file changes)
   */
  reload() {
    this.loadConfigs();
  }
}

// Export singleton instance
module.exports = new ConfigLoader();
