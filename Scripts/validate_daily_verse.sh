#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
cp "$root/Scripts/validate_daily_verse.swift" "$test_dir/main.swift"
swiftc -module-cache-path "$test_dir/cache" "$root/BibleScrollWidgets/DailyVerse.swift" "$test_dir/main.swift" -o "$test_dir/validate"
"$test_dir/validate" "$root/BibleScrollWidgets/Resources/daily-verses.json"
