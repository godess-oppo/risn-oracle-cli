/**
 * src/lib/config.js — loads .env-like settings from .env or .env.example
 */
const fs = require('fs'), path = require('path');
exports.load = function(base){
  const env = {};
  const p = path.join(base,'.env');
  if (fs.existsSync(p)) {
    fs.readFileSync(p,'utf8').split('\\n').forEach(line=>{
      const m=line.match(/^([^#=]+)=(.*)$/);
      if(m) env[m[1].trim()] = m[2].trim();
    });
  }
  // defaults
  env.RISN_POLICY_ACCEPT = env.RISN_POLICY_ACCEPT || 'false';
  return env;
};
