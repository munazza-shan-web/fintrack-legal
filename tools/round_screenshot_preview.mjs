import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const sharp=require('C:/Users/GHANI/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root=path.resolve(process.argv[2] || 'output/app-store-floating-elements');
const out=path.join(root,'rounded-previews');fs.mkdirSync(out,{recursive:true});
const names=fs.readdirSync(path.join(root,'1320x2868')).filter(n=>n.endsWith('.png')).sort();
const layers=[];
for(let i=0;i<names.length;i++){
 const input=path.join(root,'1320x2868',names[i]);
 const mask=Buffer.from('<svg width="600" height="1304"><rect width="600" height="1304" rx="40" fill="white"/></svg>');
 const rounded=await sharp(input).resize(600,1304).ensureAlpha().composite([{input:mask,blend:'dest-in'}]).png().toBuffer();
 const standalone=await sharp({create:{width:660,height:1434,channels:3,background:'#f4f5ef'}}).composite([{input:rounded,left:30,top:65}]).png().toBuffer();
 await sharp(standalone).toFile(path.join(out,names[i]));
 layers.push({input:await sharp(standalone).resize(330,717).toBuffer(),left:i*330,top:0});
}
await sharp({create:{width:1980,height:717,channels:3,background:'#f4f5ef'}}).composite(layers).png().toFile(path.join(root,'rounded-preview.png'));
fs.appendFileSync(path.join(root,'README.txt'),'\nrounded-previews contains presentation copies with outer spacing and rounded corners. rounded-preview.png shows them together. The original full-size App Store exports remain in the dimension-named folders.\n');
console.log('Created six spaced, rounded presentation copies and comparison preview.');
