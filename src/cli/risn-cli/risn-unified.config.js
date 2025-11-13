// RISN UNIFIED CONFIGURATION
// Bridges poetic + structured + future systems

module.exports = {
  // AI Systems
  ai: {
    providers: {
      poetic: {
        enabled: true,
        commands: ['dye', 'weave', 'manifest']
      },
      structured: {
        enabled: true, 
        commands: ['design', 'product']
      },
      localLLM: {
        enabled: false, // Ready for activation
        model: 'tinyllama',
        commands: ['all']
      }
    }
  },

  // Output Systems
  output: {
    formats: ['json', 'png', 'gltf', 'html'],
    locations: {
      designs: './designs/',
      products: './products/',
      collections: './collections/'
    }
  },

  // Future Integrations
  futures: {
    mobile: {
      optimized: true,
      platform: 'android/termux'
    },
    threeD: {
      enabled: true,
      formats: ['gltf', 'obj']
    },
    ar: {
      ready: false,
      target: '2024'
    }
  }
};
