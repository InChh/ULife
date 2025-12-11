// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift Package: UlifeLib

import PackageDescription;

let package = Package(
    name: "UlifeLib",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "UlifeLib",
            targets: ["UlifeLib"]
        )
    ],
    dependencies: [ ],
    targets: [
        .binaryTarget(name: "RustFramework", path: "./RustFramework.xcframework"),
        .target(
            name: "UlifeLib",
            dependencies: [
                .target(name: "RustFramework")
            ]
        ),
    ]
)