import path from 'path';
import fs from 'fs-extra';
import chalk from 'chalk';
import { boilStore } from '../modules/boil-store';

export async function boilCommand() {
  console.log(chalk.blue('🔥 Boiling store scaffold...'));
  
  try {
    // Get current working directory
    const cwd = process.cwd();
    
    // Execute store boiler
    await boilStore(cwd);
    
    console.log(chalk.green('✅ Store scaffold generated in generated-store/'));
  } catch (error) {
    console.error(chalk.red(`❌ Boil failed: ${error.message}`));
    process.exit(1);
  }
}
