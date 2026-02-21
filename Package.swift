// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NoLockApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "NoLockApp",
            targets: ["NoLockApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "NoLockApp"
        )
    ]
)
