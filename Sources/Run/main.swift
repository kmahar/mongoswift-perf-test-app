import App
import MongoDBVapor
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
try configure(app)

try app.mongoDB.configure(Environment.get("MONGODB_URI") ?? "mongodb://localhost:27017")

defer {
    app.mongoDB.cleanup()
    cleanupMongoSwift()
    app.shutdown()
}

try app.run()
