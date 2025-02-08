// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EvccMenuBar",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "EvccMenuBar",
            dependencies: [],
            resources: [
                .process("EvccMenuBar.entitlements")
            ]
        )
    ]
) 