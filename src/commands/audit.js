// RISN Command: audit
// Run content audit (simulate HF classifier)
const logger = require('../lib/logger');
const auditHook = require('../lib/audit-hook');

module.exports = function(argv) {
  const text = argv._[1] || 'This is unsafe content: violence and hate speech.';
  logger.log('audit', { action: 'check', dryRun: argv['dry-run'] });
  console.log('[audit] Running content audit...');
  
  const result = auditHook.checkContent(text, argv);
  console.log('[audit] Result:', result);
  
  if (!result.safe && !argv['policy-accept']) {
    console.log('[audit] BLOCKED: Unsafe content detected. Use --policy-accept to override.');
    process.exit(1);
  } else if (!result.safe && argv['policy-accept']) {
    console.log('[audit] WARNING: Unsafe content allowed by policy override.');
    logger.log('audit', { action: 'override', text });
  }
};
