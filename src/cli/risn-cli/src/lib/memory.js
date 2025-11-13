// RISN Memory Module
// Lightweight vector/metadata memory with SQLite (fallback to JSON)
// Functions: store(id, meta, text), query(q, k)
// TODO: Upgrade to Supabase pgvector or Chroma for production vector search

const fs = require('fs');
const path = require('path');

const MEMORY_FILE = path.join(process.cwd(), 'risn/memory.json');
let db = null;
let useSQLite = false;

// Try to load better-sqlite3 (optional dependency)
try {
  const Database = require('better-sqlite3');
  const dbPath = path.join(process.cwd(), 'risn/memory.db');
  db = new Database(dbPath);
  db.exec(`
    CREATE TABLE IF NOT EXISTS memory (
      id TEXT PRIMARY KEY,
      meta TEXT,
      text TEXT,
      timestamp TEXT,
      embedding TEXT
    )
  `);
  useSQLite = true;
  console.log('[memory] Using SQLite backend');
} catch (err) {
  console.log('[memory] SQLite not available, using JSON fallback');
}

let memoryJSON = {};

function loadJSON() {
  if (fs.existsSync(MEMORY_FILE)) {
    memoryJSON = JSON.parse(fs.readFileSync(MEMORY_FILE, 'utf8'));
  }
}

function saveJSON() {
  fs.mkdirSync(path.dirname(MEMORY_FILE), { recursive: true });
  fs.writeFileSync(MEMORY_FILE, JSON.stringify(memoryJSON, null, 2));
}

function store(id, meta, text) {
  const timestamp = new Date().toISOString();
  
  if (useSQLite && db) {
    const stmt = db.prepare('INSERT OR REPLACE INTO memory (id, meta, text, timestamp) VALUES (?, ?, ?, ?)');
    stmt.run(id, JSON.stringify(meta), text, timestamp);
  } else {
    loadJSON();
    memoryJSON[id] = { meta, text, timestamp };
    saveJSON();
  }
  
  console.log(`[memory] Stored: ${id}`);
}

function query(q, k = 5) {
  // Simple keyword search (TODO: upgrade to vector similarity)
  let results = [];
  
  if (useSQLite && db) {
    const stmt = db.prepare('SELECT * FROM memory WHERE text LIKE ? LIMIT ?');
    const rows = stmt.all(`%${q}%`, k);
    results = rows.map(r => [r.id, { meta: JSON.parse(r.meta), text: r.text, timestamp: r.timestamp }]);
  } else {
    loadJSON();
    results = Object.entries(memoryJSON)
      .filter(([id, data]) => data.text.toLowerCase().includes(q.toLowerCase()))
      .slice(0, k);
  }
  
  console.log(`[memory] Query "${q}" → ${results.length} result(s)`);
  return results;
}

function getAll() {
  if (useSQLite && db) {
    return db.prepare('SELECT * FROM memory').all();
  } else {
    loadJSON();
    return Object.entries(memoryJSON);
  }
}

module.exports = { store, query, getAll };
