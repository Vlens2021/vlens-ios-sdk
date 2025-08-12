// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VLensLib",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VLensLib",
            targets: ["VLensLib"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VLensLib",
            dependencies: [
                "Alamofire",
            ],
            path: "Sources",
            resources: [
                .process("Resources"),
                .process("VLensLib/Localization/en.lproj"),
                .process("VLensLib/Localization/ar.lproj")
            ]
        ),
        .testTarget(
            name: "VLensLibTests",
            dependencies: ["VLensLib"]
        ),
    ]
)
