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
ASSETS = [
    'assets/branding/save_goals_icon.png',
    'assets/branding/favicon.png',
    'assets/branding/apple-touch-icon.png',
    'assets/store-badges/app-store.png',
    'assets/screenshots/home-screen.png',
]


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
    for name in PAGES:
        html = (ROOT / name).read_text(encoding='utf-8')
        assert '<link rel="stylesheet" href="styles.css">' in html
        html = html.replace('<link rel="stylesheet" href="styles.css">',
                            f'<style>\n{css}\n</style>')
        html = re.sub(r'(src|href)="(assets/[^"<>]+)"', embed_asset, html)
        assert 'href="styles.css"' not in html
        assert 'src="assets/' not in html
        (DEST / name).write_text(html, encoding='utf-8')
    # Keep ordinary assets as well, for hosts that reuse them elsewhere.
    for name in ['styles.css', *ASSETS]:
        target = DEST / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes((ROOT / name).read_bytes())
    instructions = (
        'Upload index.html, privacy-policy.html and terms-and-conditions.html '
        'together into the public web root (often public_html).\n'
        'These three HTML files include their CSS and images, so they work '
        'without a build step or separate asset requests.\n'
        'Replace the old index.html; do not upload the ZIP as a webpage.\n'
        'No App Store destination is configured yet, as requested.\n'
    )
    (DEST / 'UPLOAD.txt').write_text(instructions, encoding='utf-8')
    archive_path = ROOT / 'output' / 'save-goals-website.zip'
    with zipfile.ZipFile(archive_path, 'w', zipfile.ZIP_DEFLATED) as archive:
        for name in [*PAGES, 'styles.css', *ASSETS, 'UPLOAD.txt']:
            archive.write(DEST / name, name)
    with zipfile.ZipFile(archive_path) as archive:
        assert archive.testzip() is None
    print(f'Built and verified: {archive_path}')


if __name__ == '__main__':
    main()
