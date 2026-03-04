#!/usr/bin/env bash
set -euo pipefail

flutter create . --platforms=android --org com.lookup

cp tooling/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
cp tooling/android/google_maps_api.xml android/app/src/main/res/values/google_maps_api.xml
