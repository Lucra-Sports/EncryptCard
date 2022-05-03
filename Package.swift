// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EncryptCard",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "EncryptCard",
            targets: ["EncryptCard"]
        ),
    ],
    targets: [
        .target(
            name: "EncryptCard",
            path: "Sources"
        ),
        .testTarget(
            name: "EncryptCardTests",
            dependencies: ["EncryptCard"],
            path: "Tests",
            resources: [
                .copy("keys"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
