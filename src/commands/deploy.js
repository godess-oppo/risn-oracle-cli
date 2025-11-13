/**
 * risn deploy --target vercel|docker|railway --stage staging|prod [--canary]
 */
const fs = require('fs'), path = require('path');
exports.run = function(argv, ctx){
  const base = ctx.base;
  const tIdx = argv.indexOf('--target'), sIdx = argv.indexOf('--stage');
  const canary = argv.includes('--canary');
  const target = tIdx!==-1?argv[tIdx+1]:'docker';
  const stage = sIdx!==-1?argv[sIdx+1]:'staging';
  const plan = {action:'deploy', target, stage, canary, ts:new Date().toISOString()};
  fs.writeFileSync(path.join(base,'actions',`deploy-${stage}-${Date.now()}.json`), JSON.stringify(plan,null,2));
  console.log('Deploy plan written. /* CONFIG - set deployment endpoints in .env */');
};
