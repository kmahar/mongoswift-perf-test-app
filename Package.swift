// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MongoSwiftPerfTestApp",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", .upToNextMajor(from: "4.50.0")),
        .package(url: "https://github.com/mongodb/mongodb-vapor", .branch("async-await"))
    ],
    targets: [
        .executableTarget(
            name: "Run",
            dependencies: [
                .target(name: "App"),
                .product(name: "MongoDBVapor", package: "mongodb-vapor"),
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                .product(name: "MongoDBVapor", package: "mongodb-vapor"),
                .product(name: "Vapor", package: "vapor")
            ]
        )
    ]
)
