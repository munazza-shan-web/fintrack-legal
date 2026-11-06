// Render platform sizes from the exact logo selected by the user.
// The source is retained without modification; no logo generation is involved.
import { mkdir } from 'node:fs/promises';
import { resolve } from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const sharp = require(process.argv[2] || 'sharp');
const out = resolve('assets/branding');
await mkdir(out, { recursive: true });
const source = resolve(out, 'save_goals_logo_source.png');
await sharp(source).resize(1024, 1024).flatten({background:'#9FE870'}).png().toFile(resolve(out, 'save_goals_icon.png'));
await sharp(source).resize(180, 180).png().toFile(resolve(out, 'apple-touch-icon.png'));
await sharp(source).resize(48, 48).png().toFile(resolve(out, 'favicon.png'));
// Inset the complete artwork so Android adaptive masks retain the full words.
await sharp(source).resize(716, 716).extend({top:154,bottom:154,left:154,right:154,background:'#9FE870'}).png().toFile(resolve(out, 'save_goals_adaptive.png'));
console.log('Built app and web icons from the user-selected logo.');
