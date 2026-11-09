import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
const require = createRequire(import.meta.url);
const modules = 'C:/Users/GHANI/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/';
const {chromium} = require(modules + 'playwright');
const sharp = require(modules + 'sharp');
const root = path.resolve('output/app-store-screenshots');
fs.mkdirSync(root,{recursive:true});
const data = name => fs.readFileSync(name).toString('base64');
const slides = [
  ['home','Small steps.','Real progress.','See your savings grow, one goal at a time.','#e7f5db'],
  ['goals','A goal for','every dream.','Give every plan a target of its own.','#f1e8fc'],
  ['goal','Your progress,','at a glance.','See what you’ve saved and what’s left.','#f5f6f0'],
  ['entry','Make every','little bit count.','Record savings and withdrawals with ease.','#fbe8de'],
  ['activity','Look back.','Keep going.','Follow your savings and withdrawal history.','#e7f5db'],
  ['share','Small wins.','Worth sharing.','Celebrate progress with a shareable card.','#f1e8fc'],
];
const browser = await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
try {
 const page = await browser.newPage({viewport:{width:660,height:1434},deviceScaleFactor:2});
 for(let i=0;i<slides.length;i++) {
  const [name,a,b,description,bg]=slides[i];
  await page.setContent(`<!doctype html><style>
  @font-face{font-family:Manrope;src:url(data:font/ttf;base64,${data('assets/fonts/manrope.ttf')})}
  *{box-sizing:border-box}body{margin:0;background:${bg};color:#163300;font-family:Manrope,sans-serif;width:660px;height:1434px;overflow:hidden}
  h1{position:relative;z-index:1;font-size:72px;line-height:1.06;letter-spacing:-3.7px;margin:67px 30px 0;text-align:center;font-weight:850}
  h1 span{position:relative;display:inline-block}h1 span:after{content:'';position:absolute;height:11px;background:#a3e86c;bottom:1px;left:2px;right:0;z-index:-1;border-radius:10px}
  .halo{position:absolute;top:510px;left:-170px;width:1000px;height:1000px;border-radius:50%;background:#ffffff70}
  .phone{position:absolute;top:295px;left:88px;width:484px;padding:10px;border:2px solid #868a85;border-radius:70px;background:linear-gradient(110deg,#a8aca7,#292b29 5%,#0a0b0a 50%,#656b64 96%,#c4c8c2);box-shadow:0 32px 48px #16330035,0 3px 5px #16330030}
  .phone:before,.phone:after{content:'';position:absolute;background:#6f756e;width:4px;left:-5px;border-radius:3px}.phone:before{top:155px;height:56px}.phone:after{top:225px;height:83px}
  .display{overflow:hidden;border-radius:58px;background:#f3f4ec;border:2px solid #080a07}
  .status{position:relative;height:57px;display:flex;align-items:center;justify-content:space-between;padding:0 28px;font-family:Arial,sans-serif;font-size:16px;font-weight:700;color:#111}
  .island{position:absolute;left:50%;top:12px;transform:translateX(-50%);width:133px;height:33px;background:#090a09;border-radius:25px}.island:after{content:'';position:absolute;right:12px;top:11px;width:11px;height:11px;border-radius:50%;background:#131e2d;box-shadow:inset 0 0 2px #4a5063}
  .status svg{width:65px;height:16px}.screen{width:100%}.screen img{display:block;width:100%;height:auto}
  .home-indicator{height:22px;display:flex;justify-content:center;align-items:center}.home-indicator:after{content:'';width:153px;height:5px;border-radius:5px;background:#111}
  </style><div class="halo"></div><h1>${a}<br><span>${b}</span></h1><div class="phone"><div class="display"><div class="status"><span>9:41</span><div class="island"></div><svg viewBox="0 0 65 16" fill="currentColor" aria-hidden="true"><rect x="0" y="11" width="3" height="4" rx="1"/><rect x="5" y="8" width="3" height="7" rx="1"/><rect x="10" y="5" width="3" height="10" rx="1"/><rect x="15" y="2" width="3" height="13" rx="1"/><path d="M22 5 Q30 -2 38 5 L36 7 Q30 2 24 7 Z M25 9 Q30 5 35 9 L32 12 Q30 10 28 12 Z M28 13 L30 15 L32 13 Z"/><rect x="43" y="3" width="18" height="11" rx="3" fill="none" stroke="currentColor"/><rect x="45" y="5" width="14" height="7" rx="1"/><rect x="62" y="6" width="2" height="5" rx="1"/></svg></div><div class="screen"><img src="data:image/png;base64,${data(`assets/screenshots/website/${name}.png`)}" alt="Actual app screen"></div><div class="home-indicator"></div></div></div>`);
  await page.evaluate(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(x=>x.decode()));});
  const buffer=await page.screenshot();
  for(const [w,h] of [[1320,2868],[1206,2622]]) {
   const dir=path.join(root,`${w}x${h}`);fs.mkdirSync(dir,{recursive:true});
   const output=path.join(dir,`${String(i+1).padStart(2,'0')}-${name}.png`);
   await sharp(buffer).resize(w,h,{fit:'contain',background:bg}).flatten({background:bg}).removeAlpha().png().toFile(output);
   const meta=await sharp(output).metadata();if(meta.width!==w||meta.height!==h||meta.hasAlpha)throw Error('Invalid export');
  }
 }
 const thumbs=await Promise.all(slides.map(async([name],i)=>({input:await sharp(path.join(root,'1320x2868',`${String(i+1).padStart(2,'0')}-${name}.png`)).resize(330,717).toBuffer(),left:i*330,top:0})));
 await sharp({create:{width:1980,height:717,channels:3,background:'#ffffff'}}).composite(thumbs).png().toFile(path.join(root,'preview.png'));
 fs.writeFileSync(path.join(root,'README.txt'),'Savings Goals — English iPhone App Store screenshots\n\n6 promotional PNGs in each size, opaque RGB:\n1320x2868: iPhone Dynamic Island large display\n1206x2622: iPhone Dynamic Island medium display\nUpload the matching set to the corresponding App Store Connect slot, in numerical order. preview.png is a contact sheet, not an upload screenshot.\n\nScreens use actual current Flutter app widgets rendered with illustrative savings records. These are not captures from a running iOS simulator. Verify the release on iPhone before submission, particularly layout, safe areas, and platform dialogs. No iPad set is included; if your release supports iPad, capture its actual tablet layout separately.\n\nApple specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications\n');
 console.log('Verified 12 opaque PNG exports and preview: '+root);
} finally {await browser.close();}
