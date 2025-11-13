/**
 * risn plugin add <git-url>
 * Installs plugin as a git-submodule-like folder.
 */
const fs = require('fs'), path = require('path'), child = require('child_process');
exports.run = function(argv, ctx){
  const url = argv[0];
  if (!url) { console.error('Usage: risn plugin add <git-url>'); return; }
  const name = url.split('/').pop().replace('.git','');
  const dest = path.join(ctx.base,'plugins',name);
  fs.mkdirSync(dest,{recursive:true});
  fs.writeFileSync(path.join(dest,'README.md'), `Plugin stub for ${url}\n/* TODO: implement plugin */`);
  fs.writeFileSync(path.join(ctx.base,'actions',`plugin-add-${name}.json`), JSON.stringify({url,dest,ts:new Date().toISOString()},null,2));
  console.log('Installed plugin stub at', dest);
};
