// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Liquid",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "Liquid",
            targets: ["Liquid"]),
    ],
    targets: [
        .target(
            name: "Liquid",
            path: "Liquid"),
        .target(
            name: "LiquidTests",
            dependencies: ["Liquid"],
            path: "LiquidTests")
    ],
    swiftLanguageVersions: [
      .v5
    ]
)
