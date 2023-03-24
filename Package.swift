import PackageDescription

let package = Package(
    name: "roxchat-client-sdk-ios",
    products: [
        .library(name: "RoxchatClientLibrary", targets: ["RoxchatClientLibrary"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.2")
    ],
    targets: [
        .target(
            name: "RoxchatClientLibrary",
            dependencies: ["SQLite"],
            path: "RoxchatClientLibrary"
        )
    ]
)
