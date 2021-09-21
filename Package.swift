// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SwiftyBridgesClient",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "SwiftyBridgesClient",
            targets: ["SwiftyBridgesClient"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftyBridgesClient",
            dependencies: []),
        .testTarget(
            name: "SwiftyBridgesClientTests",
            dependencies: ["SwiftyBridgesClient"]),
    ]
)
