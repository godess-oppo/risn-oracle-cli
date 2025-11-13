// RISN LLM Module
// Lightweight LLM connector with dry-run simulation
// CONFIG - set ENDPOINTS/API KEYS for live LLM calls
// Supports: OpenRouter, Ollama, local models

const axios = require('axios');

async function query(prompt, options = {}) {
  const dryRun = options.dryRun !== false;
  
  if (dryRun) {
    // Simulated response for dry-run mode
    return {
      response: `[SIMULATED LLM RESPONSE]\nPrompt: ${prompt.substring(0, 60)}...\nResult: Mock AI-generated content for testing purposes.`,
      model: 'dry-run-simulator',
      tokens: 50
    };
  }
  
  // Live LLM integration
  const provider = process.env.LLM_PROVIDER || 'ollama';
  const apiKey = process.env.LLM_API_KEY;
  const model = process.env.LLM_MODEL || 'llama2';
  
  if (provider === 'openrouter') {
    if (!apiKey) throw new Error('LLM_API_KEY not set for OpenRouter');
    
    /* CONFIG - OpenRouter endpoint */
    const response = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
      model: model,
      messages: [{ role: 'user', content: prompt }]
    }, {
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      }
    });
    
    return {
      response: response.data.choices[0].message.content,
      model: model,
      tokens: response.data.usage.total_tokens
    };
  } else if (provider === 'ollama') {
    /* CONFIG - Ollama local endpoint */
    const ollamaUrl = process.env.OLLAMA_URL || 'http://localhost:11434';
    
    try {
      const response = await axios.post(`${ollamaUrl}/api/generate`, {
        model: model,
        prompt: prompt,
        stream: false
      });
      
      return {
        response: response.data.response,
        model: model,
        tokens: response.data.eval_count || 0
      };
    } catch (err) {
      throw new Error(`Ollama connection failed: ${err.message}. Install: curl -fsSL https://ollama.com/install.sh | sh`);
    }
  }
  
  throw new Error(`Unsupported LLM provider: ${provider}. Set LLM_PROVIDER=openrouter or ollama`);
}

module.exports = { query };
