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
                    "UILaunchScreen": [
                        "UIColorName": "HopesLaunchBackground",
                        "UIImageName": "HopesLaunchLogo",
                    ],
                    "UIUserInterfaceStyle": "Light",
                    "NSAppTransportSecurity": [
                        "NSExceptionDomains": [
                            "service.gsmsv.site": [
                                "NSExceptionAllowsInsecureHTTPLoads": true,
                                "NSIncludesSubdomains": true,
                            ],
                        ],
                    ],
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                "../Resources/**",
            ],
            dependencies: [
                .package(product: "HopesDesignSystem"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                ]
            )
        ),
    ]
)
