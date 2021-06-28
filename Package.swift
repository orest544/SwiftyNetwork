// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Network",
            targets: ["Network"]
        )
    ],
    targets: [
        .target(name: "Network"),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["Network"]
        )
    ]
)
