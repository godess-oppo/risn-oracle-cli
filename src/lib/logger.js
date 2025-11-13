// RISN Logger - Append-only audit log
const fs = require('fs');
const path = require('path');

const LOG_FILE = path.join(process.cwd(), 'risn/audit.log');

function log(command, meta) {
  const entry = {
    timestamp: new Date().toISOString(),
    command,
    meta
  };
  
  fs.mkdirSync(path.dirname(LOG_FILE), { recursive: true });
  fs.appendFileSync(LOG_FILE, JSON.stringify(entry) + '\n');
}

module.exports = { log };
