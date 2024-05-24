// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Ziggy",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "Ziggy", targets: ["Ziggy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "Ziggy",
            dependencies: [
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "./src"
        ),
    ]
)
