// RISN Medusa Connector
// HTTP stub for Medusa.js backend
// CONFIG - set ENDPOINTS/API KEYS

const MEDUSA_URL = process.env.MEDUSA_URL || 'http://localhost:9000';
const API_KEY = process.env.MEDUSA_API_KEY || 'TODO_SET_API_KEY';

async function createProduct(product) {
  console.log('[medusa] Creating product:', product);
  // TODO: HTTP POST to MEDUSA_URL/admin/products
  return { success: true, id: 'prod_123' };
}

async function listProducts() {
  console.log('[medusa] Listing products...');
  // TODO: HTTP GET to MEDUSA_URL/store/products
  return { products: [] };
}

module.exports = { createProduct, listProducts };
