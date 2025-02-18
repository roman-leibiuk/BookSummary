// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioLibrary",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "AudioLibrary",
            targets: ["AudioLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.1"),
    ],
    targets: [
        .target(
            name: "AudioLibrary",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
