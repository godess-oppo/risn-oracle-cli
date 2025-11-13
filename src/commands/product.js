/**
 * risn product create --from-design <file> --meta <json>
 * Pushes product data to store (Medusa API connector stub).
 */
const fs = require('fs'), path = require('path');
exports.run = function(argv, ctx){
  const base = ctx.base;
  const fromIdx = argv.indexOf('--from-design'), metaIdx = argv.indexOf('--meta');
  const file = fromIdx!==-1?argv[fromIdx+1]:null;
  const meta = metaIdx!==-1?JSON.parse(argv[metaIdx+1]||'{}'):{};
  const act = {action:'product.create', file, meta, timestamp:new Date().toISOString()};
  fs.writeFileSync(path.join(base,'actions',`product-create-${Date.now()}.json`), JSON.stringify(act,null,2));
  console.log('Product create action written. /* CONFIG - set MEDUSA_ENDPOINT/API KEYS in .env */');
};
