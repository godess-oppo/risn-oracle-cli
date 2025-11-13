
// Health check function
module.exports.healthCheck = () => {
  const checks = [
    { name: 'Node.js', test: () => !!process.version },
    { name: 'risn/bin', test: () => {
      try { return require('fs').statSync('bin/risn').mode & 0o111; } 
      catch { return false; }
    }},
    { name: 'risn/actions writable', test: () => {
      try { require('fs').writeFileSync('risn/actions/test', ''); return true; }
      catch { return false; }
    }},
    { name: 'risn/audit.log writable', test: () => {
      try { require('fs').appendFileSync('risn/audit.log', ''); return true; }
      catch { return false; }
    }}
  ];

  const results = checks.map(c => ({ name: c.name, ok: c.test() }));
  results.forEach(r => console.log(`${r.ok ? '✅' : '❌'} ${r.name}`));

  if (results.some(r => !r.ok)) {
    throw new Error('Health check failed');
  }
};
