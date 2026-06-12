// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Monomi",
    platforms: [.macOS(.v15)],
    targets: [
        .target(name: "CShims"),
        .target(name: "MonomiKit", dependencies: ["CShims"]),
        .executableTarget(name: "Monomi", dependencies: ["MonomiKit"]),
        .testTarget(name: "MonomiKitTests", dependencies: ["MonomiKit"]),
    ]
)
