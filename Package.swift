// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "TimeTracker",
    platforms: [
        .macOS(.v13) // This line is strictly required for modern SwiftUI Menu Bar APIs
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-format.git", branch: "release/6.0"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.2")
    ],
    targets: [
        .executableTarget(
            name: "TimeTracker",
            path: "Sources"
        )
    ]
)
