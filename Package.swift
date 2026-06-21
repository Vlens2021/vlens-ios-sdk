// swift-tools-version: 5.5
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
        .package(url: "https://github.com/AndyQ/NFCPassportReader.git", from: "2.3.0"),
    ],
    targets: [
        .target(
            name: "VLensLib",
            dependencies: [
                "Alamofire",
                "NFCPassportReader",
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
