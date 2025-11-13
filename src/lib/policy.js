// RISN Policy Module
// Enforce safety policies and reversible actions

function shouldExecute(argv) {
  if (process.env.RISN_POLICY_ACCEPT === 'true') return true;
  if (argv['policy-accept']) return true;
  return false;
}

function isDryRun(argv) {
  if (argv['dry-run'] === false) return false;
  return true; // default
}

module.exports = { shouldExecute, isDryRun };
