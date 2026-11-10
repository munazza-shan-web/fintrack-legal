import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const modules='C:/Users/GHANI/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/';
const sharp=require(modules+'sharp');
const {chromium}=require(modules+'playwright');
const root=path.resolve('output/google-play-android-mockups');fs.mkdirSync(root,{recursive:true});
const dir=path.join(root,'1080x1920');fs.mkdirSync(dir,{recursive:true});
const data=p=>fs.readFileSync(p).toString('base64');
const slides=[['home','Give savings','a clear goal.'],['goals','Every dream.','One clear plan.'],['goal','See your savings.','Know what’s left.'],['entry','Small amounts.','Steady progress.'],['activity','Every deposit.','All in one place.'],['share','Your small wins.','Worth sharing.']];
const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
try{
 const page=await browser.newPage({viewport:{width:540,height:960},deviceScaleFactor:2});
 for(let i=0;i<slides.length;i++){
  const [name,title,highlight]=slides[i];
  await page.setContent(`<style>
  @font-face{font-family:Manrope;src:url(data:font/ttf;base64,${data('assets/fonts/manrope.ttf')})}
  *{box-sizing:border-box}body{margin:0;background:#a3e86c;color:#163300;font-family:Manrope,sans-serif;width:540px;height:960px;overflow:hidden}
  h1{position:absolute;left:18px;right:18px;top:42px;margin:0;text-align:center;font-size:49px;line-height:1.1;font-weight:850;letter-spacing:-2.4px;z-index:2}
  h1 span{display:inline-block;background:#163300;color:#f2ffe9;padding:5px 14px 10px;margin-top:9px;border-radius:15px}
  .phone{position:absolute;top:193px;left:42px;width:456px;background:linear-gradient(110deg,#747b70,#121611 4%,#111510 97%,#91978c);padding:8px;border:1px solid #555e50;border-radius:40px;box-shadow:0 19px 32px #16330038}
  .phone:after{position:absolute;content:'';right:-4px;top:130px;width:4px;height:69px;border-radius:3px;background:#51594c}
  .display{overflow:hidden;background:#f3f4ec;border:1px solid #111;border-radius:31px}
  .status{position:relative;height:31px;display:flex;align-items:center;justify-content:space-between;padding:0 19px;font-size:11px;font-weight:750}
  .camera{position:absolute;width:12px;height:12px;left:50%;top:10px;transform:translateX(-50%);border-radius:50%;background:#111;box-shadow:inset 0 0 0 3px #202c24}
  .status svg{width:46px;height:13px}.app{display:block;width:100%;height:auto}
  </style><h1>${title}<br><span>${highlight}</span></h1><div class="phone"><div class="display"><div class="status"><span>9:41</span><div class="camera"></div><svg viewBox="0 0 46 13" fill="#163300"><path d="M1 3 Q7 -2 13 3L7 11Z"/><path d="M17 11L26 1V11Z"/><rect x="32" y="2" width="10" height="10" rx="2"/><rect x="35" y="0" width="4" height="2" rx="1"/></svg></div><img class="app" src="data:image/png;base64,${data(`assets/screenshots/website/${name}.png`)}"></div></div>`);
  await page.evaluate(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(img=>img.decode()));});
  const check=await page.evaluate(()=>({headline:document.querySelector('h1').getBoundingClientRect().bottom,phone:document.querySelector('.phone').getBoundingClientRect().top,overflow:document.documentElement.scrollWidth>innerWidth}));
  if(check.headline>=check.phone||check.overflow)throw Error('Layout collision');
  const buffer=await page.screenshot();
  const file=path.join(dir,`${String(i+1).padStart(2,'0')}-${name}.png`);
  await sharp(buffer).flatten({background:'#a3e86c'}).removeAlpha().png().toFile(file);
  const m=await sharp(file).metadata();if(m.width!==1080||m.height!==1920||m.hasAlpha)throw Error('Invalid Google Play export');
 }
}finally{await browser.close();}
const layers=[];
for(let i=0;i<slides.length;i++){
 const file=path.join(dir,`${String(i+1).padStart(2,'0')}-${slides[i][0]}.png`);
 const mask=Buffer.from('<svg width="300" height="533"><rect width="300" height="533" rx="20" fill="white"/></svg>');
 const thumb=await sharp(file).resize(300,533).ensureAlpha().composite([{input:mask,blend:'dest-in'}]).png().toBuffer();
 layers.push({input:thumb,left:18+i*318,top:24});
}
await sharp({create:{width:1926,height:581,channels:3,background:'#f4f5ef'}}).composite(layers).png().toFile(path.join(root,'preview.png'));
fs.writeFileSync(path.join(root,'README.txt'),'Savings Goals — Google Play phone screenshots\nSix opaque PNGs, 1080x1920 (9:16). Upload individual images from 1080x1920, in numerical order. preview.png is a rounded contact sheet, not an upload screenshot.\nAndroid-style straight phone frames with a circular punch-hole camera; no iPhone Dynamic Island or iOS status bar. Green backgrounds and titles follow the selected reference. Actual current Flutter widget screens use illustrative savings records. Enlarged devices intentionally continue below the canvas, as in the supplied reference. Verify against the final Android release before submission; these are composed listing assets, not fresh Android emulator captures.\n');
console.log('Verified six Android-style 1080x1920 PNGs and contact sheet: '+root);
