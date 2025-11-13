class MedusaClient {
  constructor() { this.base = process.env.MEDUSA_URL || "http://localhost:9000"; }
  async syncProducts(data) { console.log("[medusa] syncing", data.length, "items"); }
}
module.exports = new MedusaClient();
