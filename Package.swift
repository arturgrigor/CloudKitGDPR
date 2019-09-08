// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CloudKitGDPR",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "CloudKitGDPR", targets: ["CloudKitGDPR"])
    ],
    targets: [
        .target(
            name: "CloudKitGDPR",
            dependencies: ["Settings"],
            path: "Sources",
            exclude: ["Sources/Info.plist", "Sources/CloudKitGDPR.h"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
