import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const sharp=require('C:/Users/GHANI/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root=path.resolve('output/app-store-colour-options');fs.mkdirSync(root,{recursive:true});
const palettes=[
 {id:'A-sage-cream',label:'A · Sage + cream',background:'linear-gradient(155deg,#faf9ec 0%,#e6f1d7 48%,#a9d58c 100%)',ink:'#183b20',highlight:'#f7ffe9'},
 {id:'B-mint-lime',label:'B · Mint + lime',background:'linear-gradient(155deg,#e4f9ef 0%,#bfecd4 50%,#a3e86c 100%)',ink:'#123b2b',highlight:'#eeffda'},
 {id:'C-lilac-sage',label:'C · Lilac + sage',background:'linear-gradient(160deg,#eee7fa 0%,#e4e9e4 48%,#c5e5b1 100%)',ink:'#253b25',highlight:'#f4ffe9'},
 {id:'D-peach-olive',label:'D · Peach + olive',background:'linear-gradient(155deg,#fce9dc 0%,#f3eddb 48%,#d4e5b7 100%)',ink:'#303d20',highlight:'#f8ffe8'},
];
const comparison=[];
for(let index=0;index<palettes.length;index++){
 const palette=palettes[index];
 execFileSync(process.execPath,['tools/create_consistent_store_set.mjs','--floating'],{env:{...process.env,STORE_PALETTE:JSON.stringify(palette)},stdio:'pipe'});
 const dir=path.join(root,palette.id),roundedDir=path.join(dir,'rounded-previews');fs.mkdirSync(roundedDir,{recursive:true});
 const names=fs.readdirSync(path.join(dir,'1320x2868')).filter(n=>n.endsWith('.png')).sort();const row=[];
 for(let i=0;i<names.length;i++){
  const mask=Buffer.from('<svg width="600" height="1304"><rect width="600" height="1304" rx="40" fill="white"/></svg>');
  const rounded=await sharp(path.join(dir,'1320x2868',names[i])).resize(600,1304).ensureAlpha().composite([{input:mask,blend:'dest-in'}]).png().toBuffer();
  const presentation=await sharp({create:{width:660,height:1434,channels:3,background:'#f5f5f1'}}).composite([{input:rounded,left:30,top:65}]).png().toBuffer();
  await sharp(presentation).toFile(path.join(roundedDir,names[i]));
  row.push({input:await sharp(presentation).resize(330,717).toBuffer(),left:i*330,top:0});
  if(i===0){
   comparison.push({input:await sharp(presentation).resize(330,717).toBuffer(),left:index*330,top:40});
   comparison.push({input:Buffer.from(`<svg width="330" height="40"><rect width="330" height="40" fill="#f5f5f1"/><text x="20" y="27" font-family="Arial" font-size="20" font-weight="bold" fill="#163300">${palette.label}</text></svg>`),left:index*330,top:0});
  }
 }
 await sharp({create:{width:1980,height:717,channels:3,background:'#f5f5f1'}}).composite(row).png().toFile(path.join(dir,'rounded-preview.png'));
 console.log('Verified '+palette.label+' — six screenshots in two sizes, plus rounded previews.');
}
await sharp({create:{width:1320,height:757,channels:3,background:'#f5f5f1'}}).composite(comparison).png().toFile(path.join(root,'colour-comparison.png'));
fs.writeFileSync(path.join(root,'README.txt'),'Four colour options, A–D. Each folder contains the complete six-screen set in 1320x2868 and 1206x2622, plus rounded presentation previews. Compare colour-comparison.png first, then open the selected folder/rounded-preview.png to see consistency across all six screens. Background palette and headline colours vary between options; layout, app content, typography, and spacing remain identical. Actual app widgets shown with illustrative data in styled iPhone mockups; verify the iPhone release before submission.\n');
