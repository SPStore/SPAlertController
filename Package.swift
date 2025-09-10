// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPAlertController",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "SPAlertController",
            targets: ["SPAlertController"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SPAlertController",
            path: "SPAlertController",
            publicHeadersPath: ".")
    ]
)
