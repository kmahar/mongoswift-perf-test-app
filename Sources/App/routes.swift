import MongoDBVapor
import Vapor

func routes(_ app: Application) throws {
    let setup = app.grouped("setup")
    /// GET at /setup/populate populates the DB with test data.
    setup.get("populate") { req async throws -> Response in
        try await req.collection.drop()
        let docs: [BSONDocument] = (1...100).map { ["_id": .int64(Int64($0)), "string": "abcdef"] }
        try await req.collection.insertMany(docs)
        return Response(status: .ok)
    }

    let asyncAwait = app.grouped("aa")
    let elf = app.grouped("elf")

    /// Perform a find that results in a random amount of documents being returned.

    asyncAwait.get("find") { req async throws -> [BSONDocument] in
        try await req.collection.find(getRandomFilter()).toArray()
    }

    elf.get("find") { req -> EventLoopFuture<[BSONDocument]> in
        req.elBoundCollection.find(getRandomFilter()).flatMap { cursor in cursor.toArray() }
    }

    /// Count documents, passing a filter that matches a random number of documents.

    asyncAwait.get("countDocuments") { req async throws -> Int in
        try await req.collection.countDocuments(getRandomFilter())
    }

    elf.get("countDocuments") { req -> EventLoopFuture<Int> in
        req.elBoundCollection.countDocuments(getRandomFilter())
    }
}

/// Generate a query filter that matches a random number of documents, somewhere between 1 and 100.
func getRandomFilter() -> BSONDocument {
    let randomInt = Int.random(in: 1...100)
    return ["_id": ["$lt": .int64(Int64(randomInt))]]
}

extension Request {
    /// Access a collection "bound" to the same `EventLoop` as this `Request`, meaning it will always return
    /// `EventLoopFuture`s on that `EventLoop`. Meant for use with `EventLoopFuture` API.
    var elBoundCollection: MongoCollection<BSONDocument> {
        self.mongoDB.client.db("home").collection("find")
    }

    /// Access a collection that is not bound to a particular `EventLoop`. Meant for use with async/await API.
    var collection: MongoCollection<BSONDocument> {
        self.application.mongoDB.client.db("home").collection("find")
    }
}
