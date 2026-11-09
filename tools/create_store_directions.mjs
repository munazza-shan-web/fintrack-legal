import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const modules='C:/Users/GHANI/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/';
const {chromium}=require(modules+'playwright');
const sharp=require(modules+'sharp');
const root=path.resolve('output/app-store-design-directions');fs.mkdirSync(root,{recursive:true});
const data=p=>fs.readFileSync(p).toString('base64');
const previous=fs.readFileSync('tools/package_store_screenshots.mjs','utf8');
const phoneCSS=previous.slice(previous.indexOf('  .phone{'),previous.indexOf('  </style>'));
const directions=[
 ['A','Lime momentum',`body{background:#b4f477}h1{top:55px;left:38px;font-size:85px;line-height:.99;letter-spacing:-5px}h1 em{font-style:normal;color:#5b3b85}.ring{position:absolute;border:2px solid #16330028;width:780px;height:780px;border-radius:50%;top:470px;left:-60px;box-shadow:0 0 0 65px #ffffff25,0 0 0 130px #ffffff20}.phone{top:355px;left:100px;width:475px;transform:rotate(-8deg)}.spark{position:absolute;right:35px;top:260px;width:80px;height:80px;background:#163300;clip-path:polygon(50% 0,60% 37%,100% 50%,62% 61%,50% 100%,39% 62%,0 50%,38% 39%)} `,'<div class="ring"></div><div class="spark"></div>'],
 ['B','Lilac editorial',`body{background:#e9dcfb}h1{top:65px;left:44px;font-size:78px;line-height:1.02;letter-spacing:-4px}h1 em{font-style:normal;background:#b3ef7c;padding:0 12px 4px;border-radius:18px}.block{position:absolute;top:365px;left:0;width:660px;height:1100px;background:#c7addf;border-radius:180px 180px 0 0}.phone{top:365px;left:88px;transform:rotate(5deg)}.orbit{position:absolute;width:560px;height:180px;border:2px solid #fff;transform:rotate(-25deg);border-radius:50%;top:270px;left:40px}`,'<div class="block"></div><div class="orbit"></div>'],
 ['C','Peach pop',`body{background:#ffe0c9}h1{top:65px;left:30px;right:30px;text-align:center;font-size:80px;line-height:1.02;letter-spacing:-4px}h1 em{font-style:normal;color:#5b3b85}.circle{position:absolute;width:1000px;height:1000px;background:#c5a8ed;border-radius:50%;top:600px;left:-170px}.phone{top:370px;left:88px;width:484px;transform:rotate(-4deg)}.stripe{position:absolute;width:900px;height:190px;background:#a7e973;top:730px;left:-110px;transform:rotate(-24deg);border-top:3px solid #163300;border-bottom:3px solid #163300}`,'<div class="circle"></div><div class="stripe"></div>'],
 ['D','Gallery layers',`body{background:#f7f6ef}h1{top:72px;left:40px;right:40px;text-align:center;font-size:76px;line-height:1.03;letter-spacing:-4px}h1 em{font-style:normal;color:#527f2e}.slab{position:absolute;left:36px;right:36px;top:350px;bottom:0;border-radius:250px 250px 0 0;background:#d8ebc8}.phone{top:455px;left:20px;width:426px;transform:rotate(-10deg)}.phone.secondary{top:370px;left:285px;width:365px;transform:rotate(12deg);z-index:0}.phone.primary{z-index:1}.secondary .status{height:48px;font-size:13px}.secondary .island{width:100px;height:26px;top:10px}.secondary .display{border-radius:40px}.secondary{border-radius:52px}.secondary .island:after{top:8px}`,'<div class="slab"></div>'],
 ['E','Lime studio',`body{background:radial-gradient(ellipse at 60% 62%,#ecffd4 0,#c7f594 35%,#f7f9ee 70%)}h1{top:58px;left:38px;font-size:88px;line-height:.98;letter-spacing:-5px}h1 em{font-style:normal;display:inline-block;background:#163300;color:#b9ee8c;padding:5px 18px 10px;border-radius:24px;transform:rotate(-3deg)}.phone{top:365px;left:105px;width:470px;transform:perspective(1800px) rotateY(-13deg) rotateZ(7deg)}.platform{position:absolute;left:-100px;bottom:-80px;width:900px;height:280px;border-radius:50%;background:#abd97d;box-shadow:0 -18px 0 #e5f6d6}.dot{position:absolute;top:290px;right:55px;width:55px;height:55px;border-radius:50%;background:#c9a7eb;box-shadow:-470px 790px 0 15px #c9a7eb}`,'<div class="platform"></div><div class="dot"></div>'],
 ['F','Playful geometry',`body{background:#ede5ff;background-image:linear-gradient(#16330007 1px,transparent 1px),linear-gradient(90deg,#16330007 1px,transparent 1px);background-size:44px 44px}h1{top:64px;left:28px;right:28px;text-align:center;font-size:79px;line-height:1.02;letter-spacing:-4px}h1 em{font-style:normal;text-decoration:underline;text-decoration-color:#9fe870;text-decoration-thickness:15px;text-underline-offset:-7px;text-decoration-skip-ink:none}.phone{top:365px;left:88px;transform:rotate(3deg)}.shape{position:absolute;left:-140px;top:460px;width:900px;height:900px;background:#b3ef76;border-radius:220px;transform:rotate(28deg)}.star{position:absolute;top:270px;left:40px;color:#163300;font-size:100px;line-height:1;transform:rotate(15deg)}.bubble{position:absolute;right:-50px;bottom:50px;width:230px;height:230px;border-radius:50%;background:#ffcbb1}`,'<div class="shape"></div><div class="bubble"></div><div class="star">✳</div>']
];
function phone(name,extra='primary') {return `<div class="phone ${extra}"><div class="display"><div class="status"><span>9:41</span><div class="island"></div><svg viewBox="0 0 65 16" fill="currentColor"><rect x="0" y="11" width="3" height="4"/><rect x="5" y="8" width="3" height="7"/><rect x="10" y="5" width="3" height="10"/><rect x="15" y="2" width="3" height="13"/><path d="M22 5 Q30 -2 38 5 L36 7 Q30 2 24 7Z M25 9 Q30 5 35 9 L30 15Z"/><rect x="43" y="3" width="18" height="11" rx="3" fill="none" stroke="currentColor"/><rect x="45" y="5" width="14" height="7" rx="1"/><rect x="62" y="6" width="2" height="5"/></svg></div><div class="screen"><img src="data:image/png;base64,${data(`assets/screenshots/website/${name}.png`)}"></div><div class="home-indicator"></div></div></div>`;}
const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
try {
const page=await browser.newPage({viewport:{width:660,height:1434},deviceScaleFactor:2});
for(const [letter,label,css,decor] of directions){
 const dir=path.join(root,`${letter}-${label.toLowerCase().replaceAll(' ','-')}`);fs.mkdirSync(dir,{recursive:true});
 for(const screen of ['home','goal']){
 const title=screen==='home'?'Small steps.<br><em>Big dreams.</em>':'Your goals.<br><em>Getting closer.</em>';
 await page.setContent(`<style>@font-face{font-family:Manrope;src:url(data:font/ttf;base64,${data('assets/fonts/manrope.ttf')})}*{box-sizing:border-box}body{margin:0;width:660px;height:1434px;overflow:hidden;color:#163300;font-family:Manrope,sans-serif}h1{position:absolute;margin:0;font-weight:850;z-index:3}h1 em{display:inline-block;margin-top:12px}${phoneCSS}${css}</style>${decor}<h1>${title}</h1>${letter==='D'?phone(screen==='home'?'goal':'goals','secondary'):''}${phone(screen)}`);
 await page.evaluate(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(i=>i.decode()));});
 const output=path.join(dir,`${screen}-1320x2868.png`);
 await sharp(await page.screenshot()).flatten({background:'#ffffff'}).removeAlpha().png().toFile(output);
 const meta=await sharp(output).metadata();if(meta.width!==1320||meta.height!==2868||meta.hasAlpha)throw Error('Invalid PNG');
 }
}
for(const screen of ['home','goal']){
 const layers=[];
 for(let i=0;i<directions.length;i++){
  const [letter,label]=directions[i];const dir=`${letter}-${label.toLowerCase().replaceAll(' ','-')}`;
  const thumb=await sharp(path.join(root,dir,`${screen}-1320x2868.png`)).resize(330,717).toBuffer();
  const left=(i%3)*350+10,top=Math.floor(i/3)*765+40;
  layers.push({input:thumb,left,top});
  const svg=Buffer.from(`<svg width="330" height="30"><rect width="330" height="30" fill="white"/><text x="4" y="21" font-family="Arial" font-weight="bold" font-size="17" fill="#163300">${letter} · ${label}</text></svg>`);
  layers.push({input:svg,left,top:top-30});
 }
 await sharp({create:{width:1050,height:1530,channels:3,background:'#fff'}}).composite(layers).png().toFile(path.join(root,`${screen}-comparison.png`));
}
fs.writeFileSync(path.join(root,'README.txt'),'Six visual directions, A–F. Each includes home and goal-detail examples at 1320×2868, opaque PNG. These are design options for selection, not six consecutive screenshots in one listing. Compare home-comparison.png and goal-comparison.png, then choose a direction for the full set. Actual app widgets with illustrative data inside styled iPhone mockups; verify final release on iPhone before submission. No separate app icon, brand lockup, or short description has been added.\n');
console.log('Created and verified six directions, twelve PNGs, and two comparison sheets.');
}finally{await browser.close();}

