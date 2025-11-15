import fs from 'fs-extra';
import { aiGenerateText } from '../../ai/services/generator';

export async function aiGenerate(feature: string, target: string = 'src') {
  console.log('Generating code with AI assistance...');
  
  // Create generation log
  const genLog = `.risn/generation_${Date.now()}.log`;
  await fs.ensureDir('.risn');
  await fs.writeFile(genLog, `Generation started: ${new Date().toISOString()}\nFeature: ${feature}\nTarget: ${target}\n`);
  
  // Generate based on feature type
  if (feature.includes('api') || feature.includes('endpoint')) {
    await generateApiFeature(feature, target, genLog);
  } else if (feature.includes('component') || feature.includes('ui')) {
    await generateUiFeature(feature, target, genLog);
  } else if (feature.includes('database') || feature.includes('model')) {
    await generateDatabaseFeature(feature, target, genLog);
  } else if (feature.includes('test')) {
    await generateTestFeature(feature, target, genLog);
  } else {
    await generateGeneralFeature(feature, target, genLog);
  }
  
  console.log('AI code generation completed!');
}

async function generateApiFeature(feature: string, target: string, log: string) {
  await fs.ensureDir(`${target}/api`);
  
  const endpointName = feature.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();
  
  const apiCode = await aiGenerateText(`Generate Express.js API endpoint code for: ${feature}`);
  
  await fs.writeFile(`${target}/api/${endpointName}.js`, 
    `// AI-Generated API Endpoint: ${feature}\n${apiCode}`);
  
  await fs.appendFile(log, `Generated: ${target}/api/${endpointName}.js\n`);
}

async function generateUiFeature(feature: string, target: string, log: string) {
  await fs.ensureDir(`${target}/components`);
  
  const componentName = feature.replace(/[^a-zA-Z0-9]/g, '');
  
  const componentCode = await aiGenerateText(`Generate React component code for: ${feature}`);
  const cssCode = await aiGenerateText(`Generate CSS for React component: ${feature}`);
  
  await fs.writeFile(`${target}/components/${componentName}.jsx`, 
    `// AI-Generated Component: ${feature}\n${componentCode}`);
  await fs.writeFile(`${target}/components/${componentName}.css`, cssCode);
  
  await fs.appendFile(log, `Generated: ${target}/components/${componentName}.{jsx,css}\n`);
}

async function generateDatabaseFeature(feature: string, target: string, log: string) {
  await fs.ensureDir(`${target}/models`);
  
  const modelName = feature.replace(/[^a-zA-Z0-9]/g, '');
  
  const modelCode = await aiGenerateText(`Generate Mongoose model code for: ${feature}`);
  
  await fs.writeFile(`${target}/models/${modelName}.js`, 
    `// AI-Generated Database Model: ${feature}\n${modelCode}`);
  
  await fs.appendFile(log, `Generated: ${target}/models/${modelName}.js\n`);
}

async function generateTestFeature(feature: string, target: string, log: string) {
  await fs.ensureDir(`${target}/tests`);
  
  const testName = feature.replace(/[^a-zA-Z0-9]/g, '');
  
  const testCode = await aiGenerateText(`Generate Jest test code for: ${feature}`);
  
  await fs.writeFile(`${target}/tests/${testName}.test.js`, 
    `// AI-Generated Test: ${feature}\n${testCode}`);
  
  await fs.appendFile(log, `Generated: ${target}/tests/${testName}.test.js\n`);
}

async function generateGeneralFeature(feature: string, target: string, log: string) {
  await fs.ensureDir(`${target}/features`);
  
  const featureName = feature.replace(/[^a-zA-Z0-9]/g, '');
  
  const featureCode = await aiGenerateText(`Generate JavaScript class code for feature: ${feature}`);
  
  await fs.writeFile(`${target}/features/${featureName}.js`, 
    `// AI-Generated Feature: ${feature}\n${featureCode}`);
  
  await fs.appendFile(log, `Generated: ${target}/features/${featureName}.js\n`);
}
