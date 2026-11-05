#!/usr/bin/env bash
# Takes the README and App Store screenshots with fictional data (`-demo`) in the iOS simulator.
#   scripts/screenshots.sh                      → screenshots/appstore/ (iPhone 17 Pro, 1206×2622: App Store Connect's "iPhone with Dynamic Island" size)
#   SIMULATOR="iPhone 17 Pro" OUT=screenshots WIDTH=603 PREFIX=ios- scripts/screenshots.sh  → README images
set -euo pipefail
cd "$(dirname "$0")/.."

simulator="${SIMULATOR:-iPhone 17 Pro}"
out="${OUT:-screenshots/appstore}"
width="${WIDTH:-}"
prefix="${PREFIX:-}"
bundle_id=ch.benn0r.off-hours

udid=$(xcrun simctl list devices available -j | python3 -c "
import json, sys
name = sys.argv[1]
for runtime, devices in json.load(sys.stdin)['devices'].items():
    for d in devices:
        if d['name'] == name and 'iOS' in runtime:
            print(d['udid']); sys.exit()
sys.exit('No available simulator named ' + name)" "$simulator")

xcrun simctl boot "$udid" 2>/dev/null || true
xcrun simctl bootstatus "$udid" -b >/dev/null

npm run -s project:generate >/dev/null
xcodebuild build -project OffHours.xcodeproj -scheme OffHours -configuration Debug \
  -destination "id=$udid" -derivedDataPath .build/DerivedData -quiet
xcrun simctl install "$udid" .build/DerivedData/Build/Products/Debug-iphonesimulator/OffHours.app

xcrun simctl ui "$udid" appearance light
xcrun simctl status_bar "$udid" override --time "$(date +%H:%M)" --batteryState charged \
  --batteryLevel 100 --wifiBars 3 --cellularMode active --cellularBars 4
trap 'xcrun simctl status_bar "$udid" clear' EXIT

mkdir -p "$out"
shoot() { # file, extra launch arguments…
  local file=$1
  shift
  xcrun simctl launch --terminate-running-process "$udid" "$bundle_id" -demo "$@" >/dev/null
  sleep 4
  xcrun simctl io "$udid" screenshot "$out/$prefix$file.png" >/dev/null 2>&1
  if [[ -n "$width" ]]; then sips --resampleWidth "$width" "$out/$prefix$file.png" >/dev/null; fi
  echo "$out/$prefix$file.png"
}

shoot home
shoot work-hours -demo-screen work-hours
shoot on-call -demo-screen on-call
shoot days-off -demo-screen days-off
shoot calendars -demo-screen calendars
