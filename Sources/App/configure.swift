import MongoDBVapor
import Vapor

/// Configures the application.
public func configure(_ app: Application) throws {
    ContentConfiguration.global.use(encoder: ExtendedJSONEncoder(), for: .json)
    ContentConfiguration.global.use(decoder: ExtendedJSONDecoder(), for: .json)

    // register routes
    try routes(app)
}
