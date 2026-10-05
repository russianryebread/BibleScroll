"""Check installation metadata in a built BibleScroll.app bundle."""
import plistlib
import sys
from pathlib import Path

app = Path(sys.argv[1])
widget = app / "PlugIns" / "BibleScrollWidgets.appex"
metadata = []
for bundle in (app, widget):
    with (bundle / "Info.plist").open("rb") as source:
        info = plistlib.load(source)
    for key in ("CFBundleVersion", "CFBundleShortVersionString", "CFBundleDisplayName"):
        value = info.get(key)
        assert isinstance(value, str) and value.strip(), f"{bundle.name}: missing or empty {key}"
        assert "$" not in value, f"{bundle.name}: unresolved {key}: {value}"
    metadata.append(info)

for key in ("CFBundleVersion", "CFBundleShortVersionString"):
    assert metadata[0][key] == metadata[1][key], f"App and widget have different {key} values"
assert metadata[1]["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.widgetkit-extension"
assert metadata[1]["CFBundleIdentifier"].startswith(metadata[0]["CFBundleIdentifier"] + ".")
print(f"App and embedded widget have valid, matching versions: {metadata[0]['CFBundleShortVersionString']} ({metadata[0]['CFBundleVersion']}).")
