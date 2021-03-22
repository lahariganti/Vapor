// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Gork",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.3.0")),
        .package(url: "https://github.com/vapor/fluent-mysql.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/vapor/leaf.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/twostraws/Markdown.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/twostraws/SwiftSlug.git", .upToNextMinor(from: "0.3.0"))
    ],
    targets: [
        .target(name: "App",  dependencies: ["Vapor", "Leaf", "FluentMySQL", "Markdown", "SwiftSlug"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

