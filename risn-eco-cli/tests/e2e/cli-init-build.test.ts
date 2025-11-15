// tests/e2e/cli-init-build.test.ts
test('Full init → build workflow', async () => {
  const projectName = `test-project-${Date.now()}`;
  
  // Initialize project
  await exec(`risn init ${projectName}`);
  expect(fs.existsSync(projectName)).toBeTruthy();
  
  // Build project
  const buildResult = await exec(`risn build --cwd=${projectName}`);
  expect(buildResult.code).toBe(0);
  expect(buildResult.stdout).toContain('Build successful');
});
