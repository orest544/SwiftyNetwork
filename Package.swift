// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftyNetwork",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "SwiftyNetwork",
            targets: ["SwiftyNetwork"]
        )
    ],
    targets: [
        .target(name: "SwiftyNetwork"),
        .testTarget(
            name: "SwiftyNetworkTests",
            dependencies: ["SwiftyNetwork"]
        )
    ]
)
