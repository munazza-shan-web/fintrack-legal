import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
const root = path.resolve(process.argv[2] || '.');
const port = Number(process.argv[3] || 4173);
const mime = {'.html':'text/html; charset=utf-8','.css':'text/css; charset=utf-8','.png':'image/png','.ttf':'font/ttf','.txt':'text/plain'};
http.createServer((req,res) => {
  const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  const relative = pathname === '/' ? 'index.html' : pathname.slice(1);
  const file = path.resolve(root, relative);
  if (!file.startsWith(root + path.sep) || !(/^(index\.html|privacy-policy\.html|terms-and-conditions\.html|styles\.css|assets\/[^.].*)$/.test(relative)) || !fs.existsSync(file) || !fs.statSync(file).isFile()) { res.writeHead(404); res.end('Not found'); return; }
  res.writeHead(200, {'Content-Type':mime[path.extname(file)] || 'application/octet-stream','Cache-Control':'no-store'});
  fs.createReadStream(file).pipe(res);
}).listen(port,'127.0.0.1',()=>console.log(`Local: http://127.0.0.1:${port}`));
