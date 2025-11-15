import fs from 'fs-extra';
import path from 'path';
import ejs from 'ejs';
import { DesignLog } from '../types';

// Theme definitions
const themes = {
  minimalist: {
    colors: { primary: '#2563eb', secondary: '#64748b' },
    spacing: { sm: '0.5rem', md: '1rem', lg: '2rem' },
    typography: { fontSize: '16px', fontFamily: 'sans-serif' }
  },
  futuristic: {
    colors: { primary: '#8b5cf6', secondary: '#ec4899' },
    spacing: { sm: '0.25rem', md: '0.75rem', lg: '1.5rem' },
    typography: { fontSize: '18px', fontFamily: 'monospace' }
  },
  retro: {
    colors: { primary: '#dc2626', secondary: '#ea580c' },
    spacing: { sm: '0.75rem', md: '1.25rem', lg: '2.5rem' },
    typography: { fontSize: '14px', fontFamily: 'serif' }
  }
};

export async function boilStore(projectPath: string) {
  const outputDir = path.join(projectPath, 'generated-store');
  const templateDir = path.join(__dirname, '../../templates/boil-store');
  
  // Ensure output directory exists
  await fs.ensureDir(outputDir);
  
  // Get selected theme
  const themeName = process.env.THEME || 'minimalist';
  const theme = themes[themeName];
  
  // Create design log
  const designLog: DesignLog = {
    timestamp: new Date().toISOString(),
    theme: themeName,
    components: []
  };
  
  // Process all templates
  const templates = await fs.readdir(templateDir);
  for (const templateFile of templates) {
    if (templateFile.endsWith('.ejs')) {
      const templatePath = path.join(templateDir, templateFile);
      const outputFile = templateFile.replace('.ejs', '');
      const outputPath = path.join(outputDir, outputFile);
      
      // Render template with theme data
      const template = await fs.readFile(templatePath, 'utf-8');
      const rendered = ejs.render(template, { theme });
      
      // Write output
      await fs.writeFile(outputPath, rendered);
      
      // Log component creation
      designLog.components.push(outputFile);
    }
  }
  
  // Save design log
  await fs.writeJson(path.join(outputDir, 'design-log.json'), designLog, { spaces: 2 });
  
  // Create deploy script
  await fs.writeFile(path.join(outputDir, 'deploy.sh'), 
    `#!/bin/bash\necho "🚀 Deploying store to production..."\necho "✅ Deployment complete!"`,
    { mode: 0o755 }
  );
}
