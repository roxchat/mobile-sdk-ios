// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "mobile-sdk-ios",
    products: [
        .library(name: "RoxchatClientLibrary", targets: ["RoxchatClientLibrary"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.3")
    ],
    targets: [
        .target(
            name: "RoxchatClientLibrary",
            dependencies: ["SQLite"],
            path: "RoxchatClientLibrary"
        )
    ]
)
