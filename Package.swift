// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImPAWsibleMusicKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ImPAWsibleMusicKit",
            targets: ["ImPAWsibleMusicKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ImPAWsibleMusicKit",
            dependencies: [],
            path: "Sources/ImPAWsibleMusicKit"
        ),
        .testTarget(
            name: "ImPAWsibleMusicKitTests",
            dependencies: ["ImPAWsibleMusicKit"],
            path: "Tests/ImPAWsibleMusicKitTests"
        ),
    ]
)
