// RISN Command: product
// Create/update products (reversible plan by default)
const logger = require('../lib/logger');
const { writeReversiblePlan } = require('../lib/orchestrator');

module.exports = function(argv) {
  logger.log('product', { action: 'create', dryRun: argv['dry-run'] });
  console.log('[product] Creating product (dry-run)...');
  
  const plan = {
    action: 'create_product',
    timestamp: new Date().toISOString(),
    data: { name: 'Sample Product', sku: 'PROD-001' },
    reversible: true
  };
  
  if (argv['dry-run']) {
    writeReversiblePlan('product', plan);
    console.log('[product] Plan written. Use --policy-accept to execute.');
  } else if (argv['policy-accept']) {
    console.log('[product] Executing live action...');
    // TODO: call Medusa API
    logger.log('product', { action: 'executed', plan });
  }
};
