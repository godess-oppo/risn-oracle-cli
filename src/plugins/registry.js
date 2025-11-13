module.exports = {
  register: (type) => {
    try { return require(`./${type}_plugins/default.js`); }
    catch { console.log("[registry] Missing plugin for", type); return {}; }
  }
};
