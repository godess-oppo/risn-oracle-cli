// RISN Hydrogen Storefront Connector
const axios = require('axios');

class RISNHydrogenConnector {
    constructor(config) {
        this.storefrontDomain = config.storefront_domain || 'localhost:3000';
        this.adminToken = config.admin_token;
        this.client = axios.create({
            baseURL: `https://${this.storefrontDomain}`,
            headers: {
                'Content-Type': 'application/json'
            }
        });
    }

    async createProduct(productData) {
        try {
            // For Hydrogen, you'd typically use the Storefront API
            const response = await this.client.post('/api/products', productData);
            return response.data;
        } catch (error) {
            throw new Error(`Hydrogen product creation failed: ${error.message}`);
        }
    }

    async getProducts() {
        try {
            const query = `
                query {
                    products(first: 10) {
                        edges {
                            node {
                                id
                                title
                                description
                            }
                        }
                    }
                }
            `;
            const response = await this.client.post('/graphql', { query });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to fetch products: ${error.message}`);
        }
    }
}

module.exports = RISNHydrogenConnector;
