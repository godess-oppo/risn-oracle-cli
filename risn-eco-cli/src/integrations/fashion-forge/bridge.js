const { execSync } = require('child_process');
const path = require('path');

class FashionForgeIntegration {
  constructor() {
    this.ffPath = path.join(__dirname, 'fashion-forge');
  }

  execute(command, args = '') {
    try {
      const fullCommand = `cd ${this.ffPath} && source .venv/bin/activate && fashionforge ${command} ${args}`;
      const result = execSync(fullCommand, { encoding: 'utf8' });
      return { success: true, output: result };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  generateDesign(prompt, style = 'streetwear') {
    return this.execute('generate', `--prompt "${prompt}" --style ${style}`);
  }

  publishDesign(designId, platforms = 'printify') {
    return this.execute('publish', `--design ${designId} --platforms ${platforms}`);
  }
}

module.exports = FashionForgeIntegration;
