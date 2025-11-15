import fs from 'fs-extra';
import path from 'path';
import chalk from 'chalk';

export async function initCommand(name: string) {
  console.log(chalk.green(`Creating project: ${name}`));
  
  try {
    // Create project directory
    await fs.ensureDir(name);
    
    // Copy base template
    await fs.copy(path.join(__dirname, '../../templates/base'), name);
    
    console.log(chalk.green(`✅ Project ${name} created!`));
    console.log(chalk.blue(`Next steps:\ncd ${name}\nrisn boil`));
  } catch (error) {
    console.error(chalk.red(`❌ Project creation failed: ${error.message}`));
    process.exit(1);
  }
}
