import { analyzeCodebase } from '../analyzers/code';
import { logger } from '../../../scripts/logger';
import { healingSystem } from '../../ops/healing';

export async function diagnoseAndFix() {
  logger.info('Starting error diagnosis...');

  const issues = await analyzeCodebase();

  if (issues.length === 0) {
    logger.success('No critical issues found!');
    return;
  }

  logger.warn(`Found ${issues.length} issues`);

  for (const issue of issues) {
    logger.info(`Fixing: ${issue.description}`);
    await healingSystem.applyFix(issue);
  }

  logger.success('All issues resolved!');
}
