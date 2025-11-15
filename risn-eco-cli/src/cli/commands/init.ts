import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function initProject(name?: string) {
  const projectName = name || path.basename(process.cwd());
  console.log(`Initializing RISN project: ${projectName}`);
  
  // Create project structure
  const dirs = [
    '.risn',
    '.risn/templates',
    '.risn/workflows',
    'src',
    'tests',
    'docs'
  ];
  
  for (const dir of dirs) {
    await fs.ensureDir(dir);
  }
  
  // Create project config
  const projectConfig = {
    project_name: projectName,
    version: "1.0.0",
    description: "AI-generated project",
    author: "",
    license: "MIT",
    dependencies: {},
    devDependencies: {},
    scripts: {},
    risn: {
      features: [],
      ai_assist: true,
      automation: true
    }
  };
  
  await fs.writeJSON('.risn/project.json', projectConfig, { spaces: 2 });
  
  // Create template files
  const templateDir = path.join(__dirname, '../../templates');
  await fs.copy(templateDir, '.risn/templates');
  
  console.log('RISN project initialized successfully!');
}
