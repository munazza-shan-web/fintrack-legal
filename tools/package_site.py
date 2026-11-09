"""Build upload-ready HTML with embedded CSS/images to prevent missing assets.

Run from any directory: python tools/package_site.py
Edit the root HTML, styles.css and assets, then rerun this packager.
"""
from pathlib import Path
import base64
import mimetypes
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'output' / 'save-goals-website'
PAGES = ['index.html', 'privacy-policy.html', 'terms-and-conditions.html']
ASSETS = ['assets/branding/save_goals_icon.png', 'assets/store-badges/app-store.png', 'assets/store-badges/google-play.png',
          'assets/fonts/manrope.ttf', 'assets/fonts/Manrope-OFL.txt'] + [
    f'assets/screenshots/website/{name}.png'
    for name in ['home', 'goal', 'goals', 'entry', 'activity', 'share']]


def embed_asset(match):
    attribute, path = match.groups()
    source = ROOT / path
    if not source.is_file():
        raise FileNotFoundError(f'Missing website asset: {source}')
    mime = mimetypes.guess_type(path)[0] or 'application/octet-stream'
    encoded = base64.b64encode(source.read_bytes()).decode('ascii')
    return f'{attribute}="data:{mime};base64,{encoded}"'


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    css = (ROOT / 'styles.css').read_text(encoding='utf-8')
    css_inline = re.sub(r"url\(['\"]?(assets/[^)'\"]+)['\"]?\)",
                        lambda m: 'url("data:font/ttf;base64,' + base64.b64encode((ROOT / m[1]).read_bytes()).decode('ascii') + '")', css)
    for name in PAGES:
        html = (ROOT / name).read_text(encoding='utf-8')
        assert '<link rel="stylesheet" href="styles.css">' in html
        html = html.replace('<link rel="stylesheet" href="styles.css">',
                            f'<style>\n{css_inline}\n</style>')
        html = re.sub(r'(src)="(assets/[^"<>]+)"', embed_asset, html)
        assert 'href="styles.css"' not in html
        assert 'src="assets/' not in html
        (DEST / name).write_text(html, encoding='utf-8')
    # Keep ordinary assets as well, for hosts that reuse them elsewhere.
    for name in ['styles.css', *ASSETS]:
        target = DEST / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes((ROOT / name).read_bytes())
    instructions = (
        'Extract this ZIP, then upload ALL contents into the public web root (often public_html).\n'
        'index.html, privacy-policy.html and terms-and-conditions.html belong at the root, '
        'with the assets folder beside them. Do not upload the ZIP as the webpage.\n'
        'The HTML files include their styles, display images and font to prevent a broken '
        'layout if an asset request fails. Keep assets for favicons and full-size screenshot links.\n'
        'No build step, package installation, or JavaScript is needed.\n'
        'App Store and Google Play listing URLs are not configured. To activate downloads, replace '
        'the four disabled store-badge buttons in index.html with anchor links to the correct listings.\n'
        'Screenshots are captured from the actual app with labelled illustrative data.\n'
        '\nPUBLIC LEGAL URLS AFTER UPLOAD\n'
        'Privacy: https://savegoals.site/privacy-policy.html\n'
        'Terms: https://savegoals.site/terms-and-conditions.html\n'
        'Open both URLs while signed out before submitting them in Google Play Console and App Store Connect. '
        'Keep these HTML pages publicly accessible over HTTPS without a login or geographic restriction.\n'
        'The current policy describes local-only records, optional reminders and sharing, and support email. '
        'Complete Google Play Data safety and Apple App Privacy using the final release build and its SDKs; '
        'website files do not submit the app or those forms. Update disclosures before adding billing, analytics or cloud sync.\n'
        'Current provider: AILANGA SCHOOL PROJECT. Support/privacy: jiyoo7480@gmail.com. '
        'Confirm the publisher details match your store listing before launch.\n'
    )
    (DEST / 'UPLOAD.txt').write_text(instructions, encoding='utf-8')
    archive_path = ROOT / 'output' / 'save-goals-light-website.zip'
    with zipfile.ZipFile(archive_path, 'w', zipfile.ZIP_DEFLATED) as archive:
        for name in [*PAGES, 'styles.css', *ASSETS, 'UPLOAD.txt']:
            archive.write(DEST / name, name)
    with zipfile.ZipFile(archive_path) as archive:
        assert archive.testzip() is None
    print(f'Built and verified: {archive_path}')


if __name__ == '__main__':
    main()
