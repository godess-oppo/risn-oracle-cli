/**
 * risn design generate --preset <name> --product <slug> --variants N [--audit]
 * Generates assets using local placeholder generators or configured model backend.
 */
const fs = require('fs'), path = require('path');
exports.run = function(argv, ctx){
  const base = ctx.base;
  const presetIdx = argv.indexOf('--preset'), prodIdx = argv.indexOf('--product'), varIdx = argv.indexOf('--variants');
  const doAudit = argv.includes('--audit');
  const preset = presetIdx!==-1?argv[presetIdx+1]:'default';
  const product = prodIdx!==-1?argv[prodIdx+1]:'sample-product';
  const variants = varIdx!==-1?parseInt(argv[varIdx+1]||1,10):1;
  const outdir = path.join(base,'store','assets',product);
  fs.mkdirSync(outdir,{recursive:true});
  // Write action plan
  const act = {action:'design.generate', preset, product, variants, timestamp:new Date().toISOString()};
  fs.writeFileSync(path.join(base,'actions',`design-${product}.json`), JSON.stringify(act,null,2));
  console.log('Design generation planned:', act);
  // Placeholder generation (calls python helper if present)
  const ph = path.join(base,'src','lib','sd-integration.js');
  if (fs.existsSync(ph)){
    console.log('Invoking sd-integration for real generation (plugin)');
    require(ph).generate({preset,product,variants,outdir,base});
  } else {
    for(let i=1;i<=variants;i++){
      const fname = path.join(outdir, `${product}-${i}.png`);
      fs.writeFileSync(fname, Buffer.from('','utf8')); // placeholder file
      fs.writeFileSync(path.join(base,'actions',`${product}-${i}.json`), JSON.stringify({file:fname,generated:true},null,2));
    }
    console.log('Placeholder images written to', outdir);
  }
  if (doAudit) {
    console.log('Running audit before publish...');
    const audit = require(path.join(base,'src','lib','audit.js'));
    audit.runAudit({product, outdir});
  }
};
