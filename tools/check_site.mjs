import fs from 'node:fs';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const {chromium} = require(process.argv[2] || 'playwright');
const browser = await chromium.launch({headless:true, executablePath:process.argv[3] || undefined});
const out = 'output/site-qa';
fs.mkdirSync(out,{recursive:true});
const report = [];
try {
  for (const width of [320,390,768,1024,1440]) {
    const page = await browser.newPage({viewport:{width,height:1000},deviceScaleFactor:1});
    const errors = [];
    page.on('pageerror',e=>errors.push(e.message));
    page.on('requestfailed',r=>errors.push(`${r.url()}: ${r.failure()?.errorText}`));
    page.on('response',r=>{if(r.status()>=400) errors.push(`${r.status()} ${r.url()}`);});
    await page.goto('http://127.0.0.1:4173',{waitUntil:'networkidle'});
    await page.evaluate(async()=>{
      await document.fonts.ready;
      await Promise.all([...document.images].map(async img=>{img.loading='eager';await img.decode();}));
    });
    const data = await page.evaluate(()=>({width:innerWidth,scrollWidth:document.documentElement.scrollWidth,images:[...document.images].every(i=>i.complete&&i.naturalWidth>0),font:getComputedStyle(document.body).fontFamily,h1:document.querySelector('h1').innerText}));
    if(data.scrollWidth>width) errors.push('Horizontal overflow');
    if(!data.images) errors.push('Broken image');
    await page.locator('#faq details').nth(1).locator('summary').click();
    if(!await page.locator('#faq details').nth(1).evaluate(d=>d.open)) errors.push('FAQ does not open');
    await page.locator('#faq details').nth(1).locator('summary').click();
    if(width===390 || width===1440){
      await page.evaluate(()=>scrollTo({top:0,behavior:'instant'}));
      await page.screenshot({path:`${out}/${width}-full.png`,fullPage:true});
      await page.screenshot({path:`${out}/${width}-top.png`});
    }
    report.push({...data,errors});
    await page.close();
  }
  for(const name of ['privacy-policy.html','terms-and-conditions.html']) {
    const page = await browser.newPage({viewport:{width:320,height:900}});
    await page.goto(`http://127.0.0.1:4173/${name}`,{waitUntil:'networkidle'});
    const overflow = await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth);
    report.push({page:name,errors:overflow?['Horizontal overflow']:[]});
    await page.close();
  }
  fs.writeFileSync(`${out}/report.json`,JSON.stringify(report,null,2));
  console.log(JSON.stringify(report));
  if(report.some(r=>r.errors.length)) process.exitCode=1;
} finally {await browser.close();}
