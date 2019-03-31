// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dot",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/atsushi130/Commandy", from: "1.1.3"),
        .package(url: "https://github.com/atsushi130/Scripty", from: "1.0.1"),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "12.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "dot",
            dependencies: ["Commandy", "Scripty", "RxMoya"]),
        .testTarget(
            name: "dotTests",
            dependencies: ["dot"]),
    ]
)
