import { Command } from 'commander';
import { interactiveShell } from './shell';
import { showHelp } from './help';
import { loadConfig } from '../state/config';

export function parseCLI() {
  const program = new Command();
  
  program
    .name('risn')
    .version('1.0.0')
    .description('RISN ECO CLI - Autonomous Development Ecosystem');

  program
    .command('init <project>')
    .description('Initialize new project')
    .action((project) => {
      loadConfig();
      require('../../ai/generators/project').generate(project);
    });

  program
    .command('generate <component>')
    .description('Generate code component')
    .action((component) => {
      require('../../ai/generators/code').generateComponent(component);
    });

  program
    .command('fix')
    .description('Fix errors in current project')
    .action(() => {
      require('../../ai/fixer/repair').diagnoseAndFix();
    });

  program
    .command('deploy [environment]')
    .description('Deploy to target environment')
    .action((env = 'production') => {
      require('../../ai/devops/deploy').execute(env);
    });

  program
    .command('store [action]')
    .description('Manage theme/store components')
    .action((action = 'list') => {
      require('../../store/templates/store')[action]();
    });

  program.on('--help', showHelp);
  
  if (process.argv.length === 2) {
    interactiveShell();
  } else {
    program.parse(process.argv);
  }
}
