// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FactoryKit",
    platforms: [.iOS(.v17)],
    products: [.library(name: "FactoryKit", targets: ["FactoryKit"])],
    targets: [
        .target(name: "FactoryKit", resources: [.process("PrivacyInfo.xcprivacy")]),
        .testTarget(name: "FactoryKitTests", dependencies: ["FactoryKit"]),
    ]
)
