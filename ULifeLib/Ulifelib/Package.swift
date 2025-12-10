// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift Package: Ulifelib

import PackageDescription;

let package = Package(
    name: "Ulifelib",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Ulifelib",
            targets: ["Ulifelib"]
        )
    ],
    dependencies: [ ],
    targets: [
        .binaryTarget(name: "RustFramework", path: "./RustFramework.xcframework"),
        .target(
            name: "Ulifelib",
            dependencies: [
                .target(name: "RustFramework")
            ]
        ),
    ]
)