// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

import PackageDescription

let package = Package(
  name: "RKAssetLoading",
  platforms: [.iOS("13.0")],
  products: [
    .library(name: "RKAssetLoading", targets: ["RKAssetLoading"])
  ],
  dependencies: [],
  targets: [
    .target(name: "RKAssetLoading", dependencies: [])
  ],
  swiftLanguageVersions: [.v5]
)

