import ProjectDescription

let project = Project(
    name: "Hopes",
    packages: [
        .local(path: ".."),
    ],
    targets: [
        .target(
            name: "Hopes",
            destinations: .iOS,
            product: .app,
            bundleId: "kr.hs.gsm.hopes",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [:],
                    "UIUserInterfaceStyle": "Light",
                ]
            ),
            sources: ["Sources/**"],
            dependencies: [
                .package(product: "HopesDesignSystem"),
            ]
        ),
    ]
)
