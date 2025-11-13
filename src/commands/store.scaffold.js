const fs = require('fs');
exports.command = 'store.scaffold';
exports.handler = async (args) => {
  const { name, template, medusaUrl } = args;
  if (!medusaUrl) throw new Error('--medusa-url is required');

  const storePath = `./${name}-store`;
  fs.mkdirSync(storePath, { recursive: true });
  fs.writeFileSync(
    `${storePath}/store.json`,
    JSON.stringify({ name, template, medusaUrl }, null, 2)
  );
  console.log(`✅ Created store config in ${storePath}`);
};
