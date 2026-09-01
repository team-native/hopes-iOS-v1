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
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
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
                    "MARKETING_VERSION": "1.0.1",
                    "CURRENT_PROJECT_VERSION": "2",
                ]
            )
        ),
    ]
)
