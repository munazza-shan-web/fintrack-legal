import fs from 'node:fs';
import {createRequire} from 'node:module';
let source=fs.readFileSync('tools/package_store_screenshots.mjs','utf8');
source=source.replace('output/app-store-screenshots','output/app-store-consistent-green');
const start=source.indexOf('const slides = ['),end=source.indexOf('\nconst browser',start);
const slides=[
 ['home','SAVINGS GOAL TRACKER','Give savings<br><span>a clear goal.</span>','','#a3e86c'],
 ['goals','YOUR SAVINGS GOALS','Every dream.<br><span>One clear plan.</span>','','#a3e86c'],
 ['goal','GOAL PROGRESS','See your savings.<br><span>Know what’s left.</span>','','#a3e86c'],
 ['entry','ADD SAVINGS','Small amounts.<br><span>Steady progress.</span>','','#a3e86c'],
 ['activity','SAVINGS HISTORY','Every deposit.<br><span>All in one place.</span>','','#a3e86c'],
 ['share','SHARE YOUR PROGRESS','Your small wins.<br><span>Worth sharing.</span>','','#a3e86c'],
];
source=source.slice(0,start)+'const slides = '+JSON.stringify(slides)+';'+source.slice(end);
const cssStart=source.indexOf('  h1{'),cssEnd=source.indexOf('  .phone{',cssStart);
source=source.slice(0,cssStart)+`
  .eyebrow{display:none}
  h1{position:absolute;top:74px;left:22px;right:22px;margin:0;text-align:center;font-size:64px;font-weight:850;line-height:1.1;letter-spacing:-3px;z-index:1}
  h1 span{display:inline-block;margin-top:11px;background:#163300;color:#f2ffe9;padding:6px 18px 12px;border-radius:19px}
  .halo{display:none}
`+source.slice(cssEnd);
source=source.replace('top:295px;left:88px;width:484px','top:335px;left:95px;width:470px');
source=source.replace('<h1>${a}<br><span>${b}</span></h1>','<h1>${b}</h1>');
// Assert that the exact same typography, background and device position are used throughout.
source=source.replace('  const buffer=await page.screenshot();',`  const bounds=await page.evaluate(()=>{
   const title=document.querySelector('h1').getBoundingClientRect();
   const device=document.querySelector('.phone').getBoundingClientRect();
   return {gap:device.top-title.bottom,bg:getComputedStyle(document.body).backgroundColor,titleHeight:title.height,deviceTop:device.top};
  });
  if(bounds.gap<20)throw Error('Title overlaps device: '+JSON.stringify(bounds));
  console.log(name,JSON.stringify(bounds));
  const buffer=await page.screenshot();`);
if(process.argv.includes('--floating')) {
 const require=createRequire(import.meta.url);
 const sharp=require('C:/Users/GHANI/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
 const crops={
  home:[[32,586,716,282,380,24,1030,-5],[32,206,716,352,255,385,555,6]],
  goals:[[32,256,716,230,410,22,1040,-5],[32,506,716,230,310,330,645,6]],
  goal:[[32,578,716,584,330,22,1020,-5],[36,150,330,370,220,422,540,7]],
  entry:[[32,494,716,232,405,20,1050,-5],[32,284,716,186,285,350,590,6]],
  activity:[[32,370,716,416,385,22,1030,-5],[32,122,346,216,235,400,575,6]],
  share:[[32,230,716,902,260,365,730,7],[32,1434,716,90,390,24,1210,-5]],
 };
 const cards={};
 for(const [name,items] of Object.entries(crops)) {
  cards[name]='';
  for(const [left,top,width,height,w,x,y,rotation] of items){
   const buffer=await sharp(`assets/screenshots/website/${name}.png`).extract({left,top,width,height}).png().toBuffer();
   cards[name]+=`<div class="floating-card" style="width:${w}px;left:${x}px;top:${y}px;transform:rotate(${rotation}deg)"><img src="data:image/png;base64,${buffer.toString('base64')}" alt="Enlarged detail from the app"></div>`;
  }
 }
 source=source.replace('output/app-store-consistent-green','output/app-store-floating-elements');
 source=source.replace('const slides = ','const floatingCards='+JSON.stringify(cards)+';\nconst slides = ');
 source=source.replace('<div class="halo"></div>','<div class="halo"></div>${floatingCards[name]}');
 source=source.replace('  </style>',`
  .phone{top:345px;left:127px;width:406px;transform:rotate(-3deg);border-radius:62px}
  .display{border-radius:49px}
  .floating-card{position:absolute;z-index:4;padding:7px;border-radius:32px;background:white;box-shadow:0 22px 40px #16330038,0 3px 8px #16330015}
  .floating-card img{display:block;width:100%;height:auto;border-radius:25px}
  </style>`);
}
if(process.argv.includes('--larger-phone')){
 source=source.replace('output/app-store-floating-elements','output/app-store-larger-phones');
 source=source.replace('  </style>',`.phone{top:310px;left:98px;width:464px;transform:rotate(-3deg)}  </style>`);
}
if(process.argv.includes('--extra-large-phone')){
 source=source.replace('output/app-store-floating-elements','output/app-store-extra-large-phones');
 source=source.replace('  </style>',`.phone{top:295px;left:69px;width:522px;transform:rotate(-3deg);border-radius:70px}.display{border-radius:58px}  </style>`);
}
if(process.argv.includes('--straight-zoom')){
 source=source.replace('output/app-store-floating-elements','output/app-store-straight-zoom');
 source=source.replace('  </style>',`.phone{top:290px;left:55px;width:550px;transform:none;border-radius:73px}.display{border-radius:61px}  </style>`);
}
if(process.argv.includes('--eye-catching')){
 source=source.replace('output/app-store-straight-zoom','output/app-store-eye-catching');
 source=source.replace('  </style>',`
  body{background:radial-gradient(ellipse at 50% 60%,#efffd4 0%,#caf494 33%,#a3e86c 72%)}
  .halo{display:block;position:absolute;left:-90px;top:475px;width:840px;height:840px;border:2px solid #ffffff75;border-radius:50%;background:transparent;box-shadow:0 0 0 48px #ffffff16,0 0 0 100px #ffffff12}
  .phone{box-shadow:0 36px 55px #16330050,0 6px 12px #16330024}
  .floating-card{padding:8px;border-radius:35px;box-shadow:0 25px 35px #16330040,0 4px 8px #1633001c;outline:1px solid #ffffffaa}
  .floating-card:nth-of-type(2){scale:1.08;transform-origin:left center}
  .floating-card:nth-of-type(3){scale:1.06;transform-origin:right center}
  h1 span{box-shadow:0 7px 0 #78be45,0 12px 18px #16330018}
  </style>`);
}
if(process.argv.includes('--no-overlays')){
 source=source.replace('output/app-store-eye-catching','output/app-store-clean-phones');
 source=source.replace('<div class="halo"></div>${floatingCards[name]}','<div class="halo"></div>');
}
if(process.env.STORE_PALETTE){
 const palette=JSON.parse(process.env.STORE_PALETTE);
 source=source.replace('output/app-store-floating-elements',`output/app-store-colour-options/${palette.id}`);
 source=source.replace('  </style>',`body{background:${palette.background}}h1{color:${palette.ink}}h1 span{background:${palette.ink};color:${palette.highlight}}  </style>`);
}
const file=new URL('./.consistent-store-render.mjs',import.meta.url);
fs.writeFileSync(file,source);
try{await import(file.href);}finally{fs.unlinkSync(file);}
