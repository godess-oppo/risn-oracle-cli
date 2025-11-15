import fs from 'fs-extra';
import path from 'path';
import { aiFixCode } from '../../ai/services/fixer';

export async function aiFix(target: string, errorLog?: string) {
  console.log('Analyzing and fixing code with AI assistance...');
  
  if (!(await fs.pathExists(target))) {
    throw new Error(`Target '${target}' does not exist`);
  }
  
  // Create backup
  const backupDir = `.risn/backups/${new Date().toISOString().replace(/[:.]/g, '-')}`;
  await fs.ensureDir(backupDir);
  
  if (await fs.pathExists(target)) {
    await fs.copy(target, `${backupDir}/${path.basename(target)}`);
    console.log(`Backup created: ${backupDir}/${path.basename(target)}`);
  }
  
  // Get error information
  let errorContent = "General code improvement needed";
  if (errorLog && await fs.pathExists(errorLog)) {
    errorContent = await fs.readFile(errorLog, 'utf8');
  }
  
  // Process target
  if (await fs.pathExists(target)) {
    if ((await fs.stat(target)).isFile()) {
      await fixSingleFile(target, errorContent);
    } else if ((await fs.stat(target)).isDirectory()) {
      const files = await fs.readdir(target);
      for (const file of files) {
        const filePath = path.join(target, file);
        if ((await fs.stat(filePath)).isFile() && 
            (file.endsWith('.js') || file.endsWith('.ts') || file.endsWith('.py'))) {
          await fixSingleFile(filePath, errorContent);
        }
      }
    }
  }
  
  console.log('AI fix completed! Check changes and review fixes.');
}

async function fixSingleFile(file: string, error: string) {
  console.log(`Fixing: ${file}`);
  
  const fileContent = await fs.readFile(file, 'utf8');
  const fixedContent = await aiFixCode(fileContent, error);
  await fs.writeFile(file, fixedContent);
  
  console.log(`Fixed: ${file}`);
}
