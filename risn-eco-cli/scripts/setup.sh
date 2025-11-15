#!/bin/bash

# RISN Eco CLI Setup Script
echo "🚀 Setting up RISN development environment"

# Install dependencies
npm install -g typescript
npm install -g risn-cli

# Configure AI models
risn ai download-models --core

# Setup template cache
risn store preload-templates

# Verify installation
risn doctor

echo "✅ Setup completed! Run 'risn init' to start a new project"
