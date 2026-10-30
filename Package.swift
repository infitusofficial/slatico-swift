// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SlaticoIcons",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SlaticoIcons",
            targets: ["SlaticoIcons"]
        ),
        .library(
            name: "SlaticoIconsExample",
            targets: ["SlaticoIconsExample"]
        )
    ],
    targets: [
        .target(
            name: "SlaticoIcons",
            path: "Sources/SlaticoIcons",
            resources: [
                .copy("Resources/svg")
            ]
        ),
        .target(
            name: "SlaticoIconsExample",
            dependencies: ["SlaticoIcons"],
            path: "Examples/SlaticoIconsExample"
        ),
        .testTarget(
            name: "SlaticoIconsTests",
            dependencies: ["SlaticoIcons", "SlaticoIconsExample"],
            path: "Tests/SlaticoIconsTests"
        )
    ]
)
