// RISN Policy Module
// Enforce safety policies, reversible actions, and dry-run mode

function shouldExecute(argv) {
  // Check environment variable first
  if (process.env.RISN_POLICY_ACCEPT === 'true') return true;
  // Check CLI flag
  if (argv['policy-accept']) return true;
  return false;
}

function isDryRun(argv) {
  // Explicitly set to false means live mode (if policy accepts)
  if (argv['dry-run'] === false && shouldExecute(argv)) return false;
  // Default is always dry-run for safety
  return true;
}

function requirePolicyAccept(message) {
  if (!shouldExecute(process.argv)) {
    console.error('\n[POLICY] ' + message);
    console.error('[POLICY] This action requires --policy-accept flag\n');
    process.exit(1);
  }
}

module.exports = { shouldExecute, isDryRun, requirePolicyAccept };
