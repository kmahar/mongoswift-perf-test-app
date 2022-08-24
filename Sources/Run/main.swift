import App
import MongoDBVapor
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
try configure(app)

let options = MongoClientOptions(Environment.get("THREADPOOL_SIZE") ?? 5)
try app.mongoDB.configure(Environment.get("MONGODB_URI") ?? "mongodb://localhost:27017", options: options)

defer {
    app.mongoDB.cleanup()
    cleanupMongoSwift()
    app.shutdown()
}

try app.run()
