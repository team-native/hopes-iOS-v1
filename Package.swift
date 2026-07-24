// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HopesDesignSystem",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "HopesDesignSystem",
            targets: ["HopesDesignSystem"]
        ),
    ],
    targets: [
        .target(
            name: "HopesDesignSystem",
            path: ".",
            exclude: [
                ".github",
                "README.md",
                "Resources/DesignTokens.json",
                "Resources/README.md",
                "Tests",
            ],
            sources: ["Sources/HopesDesignSystem"],
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Fonts"),
            ]
        ),
        .testTarget(
            name: "HopesDesignSystemTests",
            dependencies: ["HopesDesignSystem"],
            path: "Tests/HopesDesignSystemTests"
        ),
    ]
)
