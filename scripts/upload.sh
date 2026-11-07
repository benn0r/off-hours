#!/usr/bin/env bash
# Archives a Release build and uploads it to App Store Connect (automatic signing).
# Needs the Family Controls (Distribution) entitlement approved for the team.
# The build number is BUILD_NUMBER if set (CI: `npm run appstore next-build`), otherwise
# CURRENT_PROJECT_VERSION in project.yml, which you then bump before each upload.
# With ASC_KEY_ID, ASC_ISSUER_ID (and ASC_KEY_PATH) set, Xcode signs in with the API key
# instead of the Apple ID in Xcode's settings.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi
npm run -s project:generate >/dev/null
rm -rf .build/OffHours.xcarchive .build/export

auth=(-allowProvisioningUpdates)
if [[ -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" ]]; then
  key="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8}"
  auth+=(-authenticationKeyPath "$key" -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID")
fi
build=()
if [[ -n "${BUILD_NUMBER:-}" ]]; then
  build=(CURRENT_PROJECT_VERSION="$BUILD_NUMBER")
fi

xcodebuild archive -project OffHours.xcodeproj -scheme OffHours -configuration Release \
  -destination 'generic/platform=iOS' -archivePath .build/OffHours.xcarchive \
  -derivedDataPath .build/DerivedData "${auth[@]}" -quiet ${build[@]+"${build[@]}"}
xcodebuild -exportArchive -archivePath .build/OffHours.xcarchive \
  -exportOptionsPlist scripts/ExportOptions.plist -exportPath .build/export "${auth[@]}"
