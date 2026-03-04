$ErrorActionPreference = "Stop"

flutter create . --platforms=android --org com.lookup

Copy-Item tooling/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml -Force
Copy-Item tooling/android/google_maps_api.xml android/app/src/main/res/values/google_maps_api.xml -Force
