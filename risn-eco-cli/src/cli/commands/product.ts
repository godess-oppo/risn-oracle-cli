import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function createProduct(name: string, type: string = 'web-app') {
  console.log(`Creating product: ${name} (type: ${type})`);
  
  const productPath = `products/${name}`;
  await fs.ensureDir(productPath);
  process.chdir(productPath);
  
  // Create product config
  const productConfig = {
    name,
    type,
    version: "0.1.0",
    created: new Date().toISOString().split('T')[0],
    status: "development",
    features: [],
    dependencies: {},
    deployment: {
      staging: {},
      production: {}
    },
    ai_assisted: true
  };
  
  await fs.writeJSON('product.json', productConfig, { spaces: 2 });
  
  // Create structure based on type
  await createProductStructure(type, name);
  
  console.log(`Product '${name}' created successfully!`);
}

async function createProductStructure(type: string, name: string) {
  const dirs = ['src', 'tests', 'docs', 'config', 'scripts'];
  for (const dir of dirs) {
    await fs.ensureDir(dir);
  }
  
  switch (type) {
    case 'web-app':
      await createWebAppStructure(name);
      break;
    case 'api-service':
      await createApiServiceStructure(name);
      break;
    case 'mobile-app':
      await createMobileAppStructure(name);
      break;
    default:
      await createBasicStructure(name);
  }
}

async function createWebAppStructure(name: string) {
  const packageJson = {
    name,
    version: "0.1.0",
    description: "AI-generated web application",
    main: "src/index.js",
    scripts: {
      start: "node src/server.js",
      dev: "nodemon src/server.js",
      test: "jest",
      build: "webpack --mode production"
    },
    dependencies: {
      express: "^4.18.0",
      react: "^18.0.0",
      "react-dom": "^18.0.0"
    },
    devDependencies: {
      webpack: "^5.70.0",
      jest: "^29.0.0",
      nodemon: "^2.0.0"
    }
  };
  
  await fs.writeJSON('package.json', packageJson, { spaces: 2 });
  
  // Create basic server structure
  const serverDirs = ['src/routes', 'src/controllers', 'src/models', 'src/middleware', 'src/utils'];
  for (const dir of serverDirs) {
    await fs.ensureDir(dir);
  }
  
  const serverCode = `
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'RISN Generated API' });
});

app.get('/', (req, res) => {
  res.send('<h1>Welcome to your RISN Generated App</h1>');
});

app.listen(PORT, () => {
  console.log(\`Server running on port \${PORT}\`);
});

module.exports = app;
  `;
  
  await fs.writeFile('src/server.js', serverCode);
}

async function createApiServiceStructure(name: string) {
  const packageJson = {
    name: `${name}-api`,
    version: "0.1.0",
    description: "AI-generated API service",
    main: "src/index.js",
    scripts: {
      start: "node src/index.js",
      dev: "nodemon src/index.js",
      test: "jest"
    },
    dependencies: {
      express: "^4.18.0",
      mongoose: "^6.0.0",
      redis: "^4.0.0"
    },
    devDependencies: {
      jest: "^29.0.0",
      nodemon: "^2.0.0"
    }
  };
  
  await fs.writeJSON('package.json', packageJson, { spaces: 2 });
  
  const dirs = ['src/routes', 'src/controllers', 'src/models', 'src/services', 'src/middleware'];
  for (const dir of dirs) {
    await fs.ensureDir(dir);
  }
  
  const indexCode = `
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'RISN Generated API',
    timestamp: new Date().toISOString()
  });
});

// API routes would go here
app.use('/api/v1', require('./routes'));

app.listen(PORT, () => {
  console.log(\`API Service running on port \${PORT}\`);
});
  `;
  
  await fs.writeFile('src/index.js', indexCode);
}

async function createMobileAppStructure(name: string) {
  const packageJson = {
    name: `${name}-mobile`,
    version: "0.1.0",
    description: "AI-generated mobile application",
    main: "index.js",
    scripts: {
      start: "expo start",
      android: "expo start --android",
      ios: "expo start --ios",
      web: "expo start --web"
    },
    dependencies: {
      expo: "^48.0.0",
      react: "18.2.0",
      "react-native": "0.71.0"
    },
    devDependencies: {
      "@babel/core": "^7.20.0"
    }
  };
  
  await fs.writeJSON('package.json', packageJson, { spaces: 2 });
  
  const dirs = ['src/components', 'src/screens', 'src/navigation', 'src/utils'];
  for (const dir of dirs) {
    await fs.ensureDir(dir);
  }
  
  const appCode = `
import React from 'react';
import { StyleSheet, View, Text } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>RISN Generated Mobile App</Text>
      <Text>Welcome to your new project!</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
  `;
  
  await fs.writeFile('App.js', appCode);
}

async function createBasicStructure(name: string) {
  const packageJson = {
    name,
    version: "0.1.0",
    description: "AI-generated project",
    main: "index.js",
    scripts: {
      start: "node index.js",
      test: "jest"
    },
    dependencies: {},
    devDependencies: {
      jest: "^29.0.0"
    }
  };
  
  await fs.writeJSON('package.json', packageJson, { spaces: 2 });
  
  const indexCode = `
console.log("RISN Generated Project Started");
console.log("Run 'risn ai:generate' to add features");

// Your code here
  `;
  
  await fs.writeFile('index.js', indexCode);
}
