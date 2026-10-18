#!/usr/bin/env python3
"""Configure the freshly generated Android project for CLC Barmer.

  - set the app label
  - add the POST_NOTIFICATIONS permission (needed on Android 13+)
  - enable core library desugaring (required by flutter_local_notifications)

Runs after `flutter create` has produced the android/ folder in CI.
"""
import pathlib
import re
import sys

root = pathlib.Path('android')

# ───────── AndroidManifest.xml ─────────
manifest = root / 'app/src/main/AndroidManifest.xml'
if not manifest.exists():
    sys.exit('AndroidManifest.xml not found — did flutter create run?')

text = manifest.read_text()

# App label shown under the launcher icon.
text = re.sub(r'android:label="[^"]*"', 'android:label="CLC Barmer"', text)

# Notification permission, inserted once just inside <manifest ...>.
if 'android.permission.POST_NOTIFICATIONS' not in text:
    text = re.sub(
        r'(<manifest[^>]*>\n)',
        r'\1    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>\n',
        text,
        count=1,
    )

manifest.write_text(text)
print('patched AndroidManifest.xml')

# ───────── app/build.gradle(.kts) ─────────
DESUGAR = 'com.android.tools:desugar_jdk_libs:2.1.4'
kts = root / 'app/build.gradle.kts'
groovy = root / 'app/build.gradle'

if kts.exists():
    g = kts.read_text()
    if 'isCoreLibraryDesugaringEnabled' not in g:
        g = re.sub(
            r'(compileOptions\s*\{)',
            r'\1\n        isCoreLibraryDesugaringEnabled = true',
            g,
            count=1,
        )
    if 'coreLibraryDesugaring' not in g:
        g += f'\n\ndependencies {{\n    coreLibraryDesugaring("{DESUGAR}")\n}}\n'
    kts.write_text(g)
    print('patched build.gradle.kts')
elif groovy.exists():
    g = groovy.read_text()
    if 'coreLibraryDesugaringEnabled' not in g:
        g = re.sub(
            r'(compileOptions\s*\{)',
            r'\1\n        coreLibraryDesugaringEnabled true',
            g,
            count=1,
        )
    if 'coreLibraryDesugaring' not in g:
        g += f"\n\ndependencies {{\n    coreLibraryDesugaring '{DESUGAR}'\n}}\n"
    groovy.write_text(g)
    print('patched build.gradle')
else:
    sys.exit('No app-level Gradle file found')

print('android configuration complete')
