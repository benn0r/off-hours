#!/usr/bin/env bash
# Archives a Release build and uploads it to App Store Connect (automatic signing).
# Needs the Family Controls (Distribution) entitlement approved for the team.
# Bump CURRENT_PROJECT_VERSION in project.yml before uploading another build of the same version.
set -euo pipefail
cd "$(dirname "$0")/.."
npm run -s project:generate >/dev/null
rm -rf .build/OffHours.xcarchive .build/export
xcodebuild archive -project OffHours.xcodeproj -scheme OffHours -configuration Release \
  -destination 'generic/platform=iOS' -archivePath .build/OffHours.xcarchive \
  -derivedDataPath .build/DerivedData -allowProvisioningUpdates -quiet
xcodebuild -exportArchive -archivePath .build/OffHours.xcarchive \
  -exportOptionsPlist scripts/ExportOptions.plist -exportPath .build/export -allowProvisioningUpdates
