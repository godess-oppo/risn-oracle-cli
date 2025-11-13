// RISN Audit Hook
// Simulate open-source HF classifier
// In dry-run, must flag unsafe text and block publish unless --policy-accept

function checkContent(text, argv = {}) {
  // Simulate unsafe content detection
  const unsafePatterns = ['violence', 'hate speech', 'unsafe content'];
  const isSafe = !unsafePatterns.some(pattern => text.toLowerCase().includes(pattern));
  
  const result = {
    safe: isSafe,
    text: text.substring(0, 100),
    model: 'simulated-hf-classifier'
  };
  
  if (!isSafe && argv['dry-run'] !== false) {
    console.log('[audit-hook] ⚠️  Unsafe content detected!');
    console.log('[audit-hook] Text:', text.substring(0, 100));
  }
  
  return result;
}

module.exports = { checkContent };
