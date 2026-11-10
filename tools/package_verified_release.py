"""Verify and package the signed Play upload without private signing material."""
from pathlib import Path
import hashlib
import json
import struct
import zipfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'output' / 'play-store-release-1.3.4'
AAB = DEST / 'saving-goals-1.3.4-build8-play-store.aab'
APK = DEST / 'saving-goals-1.3.4-build8-release.apk'
assert AAB.is_file() and APK.is_file(), 'Run the signed build helper first.'
ANDROID = '{http://schemas.android.com/apk/res/android}'
manifest = ET.parse(ROOT / 'build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml').getroot()
assert manifest.attrib['package'] == 'com.savings.goals.app'
assert manifest.attrib[ANDROID + 'versionCode'] == '8'
assert manifest.attrib[ANDROID + 'versionName'] == '1.3.4'
assert manifest.find('application').attrib[ANDROID + 'label'] == 'Saving Goals'
assert manifest.find('uses-sdk').attrib[ANDROID + 'targetSdkVersion'] == '36'
native = []
with zipfile.ZipFile(AAB) as bundle:
    assert bundle.testzip() is None
    entries = bundle.namelist()
    assert any(n.startswith('META-INF/') and n.endswith(('.RSA', '.EC', '.DSA')) for n in entries), 'Bundle is unsigned.'
    assert 'base/manifest/AndroidManifest.xml' in entries
    assert any(n.startswith('base/dex/') for n in entries)
    for name in entries:
        if '/lib/' not in name or not name.endswith('.so') or not any(abi in name for abi in ['arm64-v8a', 'x86_64']):
            continue
        data = bundle.read(name)
        assert data[:4] == b'\x7fELF' and data[4] == 2 and data[5] == 1
        phoff = struct.unpack_from('<Q', data, 32)[0]
        phsize, phnum = struct.unpack_from('<HH', data, 54)
        alignments = []
        for i in range(phnum):
            offset = phoff + i * phsize
            if struct.unpack_from('<I', data, offset)[0] == 1:
                align = struct.unpack_from('<Q', data, offset + 48)[0]
                alignments.append(align)
                assert align >= 16384, f'64-bit native library has insufficient page alignment: {name}'
        native.append({'library': name, 'loadSegmentAlignments': alignments, 'supports16KBAlignment': True})
assert native, 'No 64-bit native libraries found.'
with zipfile.ZipFile(APK) as apk:
    assert apk.testzip() is None
    assert 'AndroidManifest.xml' in apk.namelist()
report = {
    'applicationId': 'com.savings.goals.app', 'displayName': 'Saving Goals',
    'versionName': '1.3.4', 'versionCode': 8, 'minSdk': 24, 'targetSdk': 36,
    'buildType': 'release', 'signedWithUploadKey': True,
    'testsPassed': 41, 'flutterAnalysis': 'No issues found',
    'signatureVerification': 'jarsigner verified AAB and apksigner verified APK in build_play_release.ps1',
    'nativeLibraries': native,
    'artifacts': {p.name: {'bytes': p.stat().st_size, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()} for p in [AAB, APK]},
    'deviceTesting': 'No Android device/emulator test performed for this release in this task.',
    'publication': 'Not uploaded or submitted to Google Play.'
}
(DEST / 'BUILD-VERIFICATION.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
(DEST / 'RELEASE-INFO.txt').write_text('Saving Goals: Budgeting Tool\nVersion: 1.3.4 (8)\nPackage: com.savings.goals.app\nInstalled display name: Saving Goals\nTarget Android SDK: 36; minimum: 24\n\nBoth artifacts are RELEASE builds signed with your new upload keystore, using the passwords you entered locally.\nUpload saving-goals-1.3.4-build8-play-store.aab to Google Play. The APK is for direct phone testing.\nUse release-notes/play-console-notes.txt for localized release notes.\n\nWebsite: https://savingsgoals.site/\nPrivacy: https://savingsgoals.site/privacy-policy.html\nTerms: https://savingsgoals.site/terms-and-conditions.html\nSupport: info@savingsgoals.site\n\nPrivate key and settings backup: C:/Users/GHANI/.android-keystores/\nWorking private configuration: android/key.properties (Git ignored). The .example file is only a template. No keys or passwords are included in this delivery ZIP. Back up the private signing files separately.\n\nVersion code 8 must be unused for this package in Play Console. Package change from com.example.fintrack creates a separate installation and does not migrate local records. Check the APK on a real Android phone and review Play Console declarations before submission. The build has not been uploaded or published.\n', encoding='utf-8')
files = [AAB, APK, DEST / 'SHA256SUMS.txt', DEST / 'BUILD-VERIFICATION.json', DEST / 'RELEASE-INFO.txt', *sorted((DEST / 'release-notes').rglob('*'))]
archive = ROOT / 'output' / 'saving-goals-1.3.4-play-store-release.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
    for file in files:
        if file.is_file():
            assert file.suffix.lower() not in ['.jks', '.keystore', '.properties', '.p12']
            assert 'UNSIGNED' not in file.name
            z.write(file, file.relative_to(DEST).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
print('Verified release identity, archive integrity, native 16KB alignment, and private-file exclusions.')
print('Signed release package: ' + str(archive))
