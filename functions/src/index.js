const { onRequest } = require('firebase-functions/v2/https');
const functions = require('firebase-functions');

// CORS proxy for fetching KML/KMZ/GeoJSON files
exports.proxy = onRequest({ cors: true }, async (req, res) => {
  const url = req.query.url;
  
  if (!url) {
    return res.status(400).json({ error: 'Parameter ?url= wajib diisi' });
  }
  
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return res.status(400).json({ error: 'URL harus dimulai dengan http:// atau https://' });
  }
  
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 30000);
    
    const fetchResp = await fetch(url, { 
      signal: controller.signal,
      headers: { 'User-Agent': 'ComSUR-Proxy/1.0' }
    });
    clearTimeout(timeout);
    
    if (!fetchResp.ok) {
      return res.status(502).json({ error: 'Gagal mengunduh: HTTP ' + fetchResp.status });
    }
    
    const contentType = fetchResp.headers.get('content-type') || '';
    const buffer = await fetchResp.arrayBuffer();
    
    res.setHeader('Content-Type', contentType || 'application/octet-stream');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Cache-Control', 'public, max-age=300');
    res.status(200).send(Buffer.from(buffer));
  } catch (err) {
    console.error('Proxy error:', err.message);
    res.status(500).json({ error: 'Gagal mengunduh file: ' + err.message });
  }
});
