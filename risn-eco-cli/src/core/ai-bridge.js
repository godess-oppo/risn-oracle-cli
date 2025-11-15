require('dotenv').config();

class AIBridge {
  constructor() {
    this.keys = {
      openrouter: process.env.OPENROUTER_API_KEY,
      gemini: process.env.GEMINI_API_KEY,
      huggingface: process.env.HUGGINGFACE_API_KEY,
      groq: process.env.GROQ_API_KEY,
      sobanova: process.env.SOBANOVA_API_KEY,
      chore: process.env.CHORE_AI_API_KEY
    };
  }

  async generateDesign(prompt, style) {
    console.log(`🤖 AI: Generating "${prompt}" with ${this.keys.openrouter ? 'OpenRouter' : 'No API Key'}`);
    
    if (this.keys.openrouter) {
      // Add OpenRouter API call here
      return `ai-design-${Date.now()}.png`;
    } else {
      return `offline-design-${Date.now()}.txt`;
    }
  }

  checkKeys() {
    const working = [];
    const missing = [];
    
    Object.entries(this.keys).forEach(([name, key]) => {
      if (key && key.length > 10) {
        working.push(name);
      } else {
        missing.push(name);
      }
    });
    
    return { working, missing };
  }
}

module.exports = AIBridge;

  async generateRealDesign(prompt, style) {
    try {
      const response = await fetch('https://openrouter.ai/api/v1/generate', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.keys.openrouter}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'black-forest-labs/flux-1.1-pro', // Image model
          prompt: `Fashion design: ${prompt}, ${style} style`,
          width: 1024,
          height: 1024
        })
      });
      
      const data = await response.json();
      return data.images[0].url; // Returns image URL
    } catch (error) {
      return `ai-fallback-${Date.now()}.png`;
    }
  }
