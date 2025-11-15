import fs from 'fs-extra';
import { aiGenerateText } from '../../ai/services/generator';

export async function designProject(requirements?: string) {
  console.log('Starting design session...');
  
  if (!requirements) {
    console.log('Enter your design requirements (Ctrl+D to finish):');
    requirements = '';
    process.stdin.setEncoding('utf8');
    for await (const chunk of process.stdin) {
      requirements += chunk;
    }
  }
  
  // Create design directory
  await fs.ensureDir('design_specs');
  
  // Generate design specification
  const designSpec = await aiGenerateText(`Create a design specification for: ${requirements}`);
  
  const specContent = `# Design Requirements

## Input
${requirements}

## Generated Design Specification
${designSpec}

Generated: ${new Date().toISOString()}`;
  
  await fs.writeFile('design_specs/requirements.md', specContent);
  
  // Generate components based on design
  await generateComponents(requirements);
  
  console.log('Design specification generated!');
}

async function generateComponents(requirements: string) {
  const components = await aiGenerateText(`List 5 component names for design: ${requirements}`);
  const componentList = components.split('\n').slice(0, 5);
  
  await fs.ensureDir('src/components/ui');
  
  for (const component of componentList) {
    if (component.trim()) {
      const componentName = component.replace(/[^a-zA-Z0-9]/g, '');
      const componentCode = await aiGenerateText(`Generate React component code for: ${component}`);
      
      await fs.writeFile(
        `src/components/ui/${componentName}.js`,
        `// Auto-generated component: ${component}\n${componentCode}`
      );
    }
  }
}
