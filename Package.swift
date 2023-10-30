// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RKLoader",
    platforms: [.iOS("13.0"), .macOS(.v10_15)],
    products: [
        .library(name: "RKLoader", targets: ["RKLoader"]),
    ],
    dependencies: [
        .package(name: "RKUtilities", url: "https://github.com/Reality-Dev/RealityKit-Utilities", from: "1.0.0"),
    ],
    targets: [
        .target(name: "RKLoader",
                dependencies: [.product(name: "RKUtilities", package: "RKUtilities")]),
    ],
    swiftLanguageVersions: [.v5]
)
