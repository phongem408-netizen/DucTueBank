#!/bin/bash
set -e
rm -rf build Payload DucTueFinanceDemo.ipa
xcodebuild \
  -project DucTueFinanceDemo.xcodeproj \
  -scheme DucTueFinanceDemo \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""
mkdir -p Payload
cp -R build/Build/Products/Release-iphoneos/DucTueFinanceDemo.app Payload/
zip -r DucTueFinanceDemo.ipa Payload
printf '\nDone: %s/DucTueFinanceDemo.ipa\n' "$PWD"
