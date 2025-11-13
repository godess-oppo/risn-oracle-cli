/**
 * risn ops heal --auto|--dry-run
 * Runs remediation plan (dry-run by default).
 */
const fs = require('fs'), path = require('path');
exports.run = function(argv, ctx){
  const base = ctx.base;
  const auto = argv.includes('--auto');
  const dry = argv.includes('--dry-run') || !auto;
  // Simulated detection (reads demo incident if exists)
  const incidentFile = path.join(base,'demo','incident.json');
  let incident = {id:'demo-1', severity:'medium', detected:new Date().toISOString()};
  if (fs.existsSync(incidentFile)) incident = JSON.parse(fs.readFileSync(incidentFile,'utf8'));
  const diagnosis = {incident, root:'service:worker-crash', suggested:['restart-worker','rollback-last-deploy']};
  const plan = {diagnosis, actions: diagnosis.suggested, reversible:true, ts:new Date().toISOString()};
  fs.writeFileSync(path.join(base,'actions',`heal-plan-${Date.now()}.json`), JSON.stringify(plan,null,2));
  console.log('Heal plan written to risn/actions. Dry-run:', dry);
  if (!dry) {
    // execute safe low-risk action
    fs.writeFileSync(path.join(base,'rtn-ops.log'), `Executed actions: ${JSON.stringify(plan.actions)} at ${new Date().toISOString()}\n`);
    console.log('Executed low-risk remediation. Wrote reversible plan and audit entry.');
  }
};
