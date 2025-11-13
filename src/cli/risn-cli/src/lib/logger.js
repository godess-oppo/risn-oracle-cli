// RISN Logger - Append-only audit log with timestamps
const fs = require('fs');
const path = require('path');

const LOG_FILE = path.join(process.cwd(), 'risn/audit.log');

function log(command, meta = {}) {
  const entry = {
    timestamp: new Date().toISOString(),
    command,
    meta,
    user: process.env.USER || 'unknown',
    cwd: process.cwd()
  };
  
  try {
    fs.mkdirSync(path.dirname(LOG_FILE), { recursive: true });
    fs.appendFileSync(LOG_FILE, JSON.stringify(entry) + '\n', 'utf8');
  } catch (err) {
    console.error('[LOGGER] Failed to write audit log:', err.message);
  }
}

function readLog(lines = 10) {
  if (!fs.existsSync(LOG_FILE)) return [];
  const content = fs.readFileSync(LOG_FILE, 'utf8');
  const allLines = content.trim().split('\n').filter(l => l);
  return allLines.slice(-lines).map(l => JSON.parse(l));
}

module.exports = { log, readLog };
