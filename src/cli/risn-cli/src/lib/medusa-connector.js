// RISN Medusa Connector
// HTTP API client for Medusa.js e-commerce backend
// CONFIG - set MEDUSA_URL and MEDUSA_API_KEY in .env

const axios = require('axios');

const MEDUSA_URL = process.env.MEDUSA_URL || 'http://localhost:9000';
const API_KEY = process.env.MEDUSA_API_KEY || '';

const client = axios.create({
  baseURL: MEDUSA_URL,
  headers: {
    'Content-Type': 'application/json',
    ...(API_KEY && { 'x-medusa-access-token': API_KEY })
  }
});

async function getStatus() {
  try {
    const response = await client.get('/health');
    return {
      connected: response.status === 200,
      url: MEDUSA_URL,
      version: response.data.version || 'unknown'
    };
  } catch (err) {
    return {
      connected: false,
      url: MEDUSA_URL,
      error: err.message
    };
  }
}

async function createProduct(productData) {
  /* CONFIG - POST to /admin/products */
  try {
    const response = await client.post('/admin/products', productData);
    return {
      success: true,
      product: response.data.product
    };
  } catch (err) {
    throw new Error(`Failed to create product: ${err.message}`);
  }
}

async function listProducts(limit = 20, offset = 0) {
  /* CONFIG - GET from /store/products */
  try {
    const response = await client.get('/store/products', {
      params: { limit, offset }
    });
    return {
      products: response.data.products,
      count: response.data.count
    };
  } catch (err) {
    throw new Error(`Failed to list products: ${err.message}`);
  }
}

async function updateProduct(productId, updates) {
  /* CONFIG - POST to /admin/products/:id */
  try {
    const response = await client.post(`/admin/products/${productId}`, updates);
    return {
      success: true,
      product: response.data.product
    };
  } catch (err) {
    throw new Error(`Failed to update product: ${err.message}`);
  }
}

module.exports = {
  getStatus,
  createProduct,
  listProducts,
  updateProduct
};
