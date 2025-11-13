/**
 * src/lib/logger.js — simple logger
 */
const fs = require('fs'), path = require('path');
exports.log = function(base, msg){
  const f = path.join(base,'audit.log');
  fs.appendFileSync(f, JSON.stringify({ts:new Date().toISOString(), msg}) + '\n');
};
