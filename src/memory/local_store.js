const sqlite3 = require('sqlite3').verbose();
class VectorStore {
  constructor() {
    this.db = new sqlite3.Database(':memory:');
    console.log("[vector-mem] Initialized in-memory store");
  }
  upsert(vector) { /* TODO: add embedding ops */ }
}
module.exports = new VectorStore();
