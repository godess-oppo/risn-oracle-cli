#!/usr/bin/env node
require('dotenv').config();

const AIBridge = require('./ai-bridge');
const ai = new AIBridge();

console.log(`
╔══════════════════════════════════════════════════╗
║               🚀 RISN ECOSYSTEM CLI              ║
║      AI-Powered: Fashion + Emotion + Store       ║
╚══════════════════════════════════════════════════╝
`);

const args = process.argv.slice(2);

function showHelp() {
  const keyStatus = ai.checkKeys();
  console.log(`
AI STATUS: ${keyStatus.working.length} APIs configured

USAGE:
  risn-eco forge-generate <prompt>    AI fashion designs
  risn-eco risn-dye <emotion>         Emotional fabric dye
  risn-eco aurix-create <store>       Store automation
  risn-eco ai-status                  Check API keys
  risn-eco help                       Show this help

WORKING APIS: ${keyStatus.working.join(', ')}
  `);
}

async function forgeGenerate(prompt, style = 'streetwear') {
  console.log(`🎨 FASHION FORGE: Generating "${prompt}"`);
  const result = await ai.generateDesign(prompt, style);
  console.log(`   Output: ${result}`);
  console.log(`   AI Engine: Active`);
}

function risnDye(emotion, intensity = '75') {
  console.log(`🎭 RISN ORACLE: Dyeing with ${emotion}`);
  console.log(`   Intensity: ${intensity}%`);
}

function aurixCreate(store) {
  console.log(`🏪 AURIX ENGINE: Creating store "${store}"`);
}

function aiStatus() {
  const status = ai.checkKeys();
  console.log('🔑 AI API STATUS:');
  status.working.forEach(api => console.log(`   ✅ ${api}: CONFIGURED`));
  status.missing.forEach(api => console.log(`   ❌ ${api}: MISSING`));
}

// Command routing
if (args.length === 0) {
  showHelp();
} else {
  const command = args[0];
  
  switch (command) {
    case 'forge-generate':
      forgeGenerate(args[1], args[3] || 'streetwear');
      break;
    case 'risn-dye':
      risnDye(args[1], args[3] || '75');
      break;
    case 'aurix-create':
      aurixCreate(args[1]);
      break;
    case 'ai-status':
      aiStatus();
      break;
    case 'help':
    case '--help':
    case '-h':
      showHelp();
      break;
    default:
      console.log(`❌ Unknown command: ${command}`);
      showHelp();
  }
}
