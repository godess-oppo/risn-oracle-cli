// RISN Memory Module
// SQLite-backed with JSON fallback
// Functions: store(id, meta, text), query(q, k)
const fs = require('fs');
const path = require('path');

const MEMORY_FILE = path.join(process.cwd(), 'risn/memory.json');

let memoryDB = {};

function loadMemory() {
  if (fs.existsSync(MEMORY_FILE)) {
    memoryDB = JSON.parse(fs.readFileSync(MEMORY_FILE, 'utf8'));
  }
}

function saveMemory() {
  fs.mkdirSync(path.dirname(MEMORY_FILE), { recursive: true });
  fs.writeFileSync(MEMORY_FILE, JSON.stringify(memoryDB, null, 2));
}

function store(id, meta, text) {
  loadMemory();
  memoryDB[id] = { meta, text, timestamp: new Date().toISOString() };
  saveMemory();
  console.log(`[memory] Stored: ${id}`);
}

function query(q, k = 5) {
  loadMemory();
  // TODO: implement vector search or keyword match
  const results = Object.entries(memoryDB)
    .filter(([id, data]) => data.text.includes(q))
    .slice(0, k);
  
  console.log(`[memory] Query: "${q}" → ${results.length} results`);
  return results;
}

module.exports = { store, query };
