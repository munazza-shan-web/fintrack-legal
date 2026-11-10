import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const modules='C:/Users/GHANI/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/';
const sharp=require(modules+'sharp');
const {chromium}=require(modules+'playwright');
const root=path.resolve('output/google-play-launch-assets');fs.mkdirSync(root,{recursive:true});
const shots=path.join(root,'phone-screenshots');fs.mkdirSync(shots,{recursive:true});
const names=['home','goals','goal','entry','activity','share'];
for(let i=0;i<names.length;i++){
 // Full app screens without iPhone hardware or platform-specific status bars.
 await sharp(`assets/screenshots/website/${names[i]}.png`).resize(1080,1920,{fit:'contain',background:'#f3f4ec'}).flatten({background:'#f3f4ec'}).removeAlpha().png().toFile(path.join(shots,`${i+1}-${names[i]}.png`));
}
await sharp('assets/branding/save_goals_icon.png').resize(512,512).flatten({background:'#9fe870'}).ensureAlpha().png().toFile(path.join(root,'app-icon-512.png'));
const data=p=>fs.readFileSync(p).toString('base64');
const card=await sharp('assets/screenshots/website/goals.png').extract({left:32,top:256,width:716,height:230}).png().toBuffer();
const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
try{
 const page=await browser.newPage({viewport:{width:1024,height:500},deviceScaleFactor:1});
 await page.setContent(`<style>@font-face{font-family:Manrope;src:url(data:font/ttf;base64,${data('assets/fonts/manrope.ttf')})}*{box-sizing:border-box}body{margin:0;width:1024px;height:500px;overflow:hidden;background:#a3e86c;color:#163300;font-family:Manrope,sans-serif}.orb{position:absolute;width:620px;height:620px;border:2px solid #ffffff65;border-radius:50%;left:510px;top:-60px;background:#e3f6c870;box-shadow:0 0 0 35px #ffffff20}h1{position:absolute;left:58px;top:83px;margin:0;font-size:76px;line-height:1.03;letter-spacing:-4px;font-weight:850}p{position:absolute;left:62px;top:290px;margin:0;font-size:25px;line-height:1.4;font-weight:650;max-width:410px}.screen{position:absolute;left:676px;top:42px;width:258px;overflow:hidden;border:7px solid #fff;border-radius:31px;box-shadow:0 20px 40px #16330030}.screen img{width:100%;display:block}.card{position:absolute;left:553px;top:318px;width:343px;padding:7px;background:#fff;overflow:hidden;border-radius:25px;box-shadow:0 16px 28px #16330035;transform:rotate(-4deg)}.card img{display:block;width:100%;border-radius:18px}</style><div class="orb"></div><h1>Savings<br>Goals.</h1><p>Set a goal.<br>See your progress.</p><div class="screen"><img src="data:image/png;base64,${data('assets/screenshots/website/home.png')}"></div><div class="card"><img src="data:image/png;base64,${card.toString('base64')}"></div>`);
 await page.evaluate(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(i=>i.decode()));});
 await sharp(await page.screenshot()).removeAlpha().png().toFile(path.join(root,'feature-graphic-1024x500.png'));
}finally{await browser.close();}
for(const file of ['privacy-policy.html','terms-and-conditions.html'])fs.copyFileSync(file,path.join(root,file));
fs.writeFileSync(path.join(root,'LAUNCH-NOTES.txt'),`Savings Goals — Google Play assets\nPackage/application ID: com.savings.goals.app\n\nFILES\napp-icon-512.png: 512x512 PNG, selected brand icon.\nfeature-graphic-1024x500.png: opaque PNG feature graphic.\nphone-screenshots/: six actual current Flutter widget screens, 1080x1920 PNG (proportionally fitted, no stretching), illustrative records; no iPhone frames. Verify against the final Android release before uploading.\nThe separate screenshots ZIP contains only these six PNGs.\n\nPOLICY LINKS\nPrivacy: https://savingsgoals.site/privacy-policy.html\nTerms: https://savingsgoals.site/terms-and-conditions.html\nSupport: jiyoo7480@gmail.com\nProvider: AILANGA SCHOOL PROJECT\nThese are the links already configured in the app. On November 10, 2026 the main website, privacy page and terms page were fetched successfully. Both legal URLs returned HTTP 200. Included HTML files are copies for reference; the website ZIP has their styling/assets.\n\nRELEASE STATUS\nAndroid namespace, applicationId and Kotlin MainActivity package have been changed in source. No new APK/AAB is included in this asset pack. The Gradle release configuration still signs with a debug key; configure a private release/upload keystore and build a signed Android App Bundle before submission. Changing the application ID creates a separate app from com.example.fintrack; it will not update that old installation or automatically migrate its local records.\nComplete Data safety, content rating, target audience and other Play Console declarations for the final build. Current app has local-only records, no accounts, no billing, no ads/analytics SDKs. Do not describe future paid functionality as currently implemented.\n\nAsset specifications: https://support.google.com/googleplay/android-developer/answer/9866151\n`);
const icon=await sharp(path.join(root,'app-icon-512.png')).metadata();
const graphic=await sharp(path.join(root,'feature-graphic-1024x500.png')).metadata();
if(icon.width!==512||icon.height!==512||fs.statSync(path.join(root,'app-icon-512.png')).size>1024*1024)throw Error('Invalid icon');
if(graphic.width!==1024||graphic.height!==500||graphic.hasAlpha)throw Error('Invalid feature graphic');
for(const file of fs.readdirSync(shots)){
 const m=await sharp(path.join(shots,file)).metadata();
 if(m.hasAlpha||m.width<320||m.height>3840||Math.max(m.width,m.height)>2*Math.min(m.width,m.height))throw Error('Check screenshot dimensions');
}
console.log('Verified icon, feature graphic and six phone screenshots: '+root);
