import MongoDBVapor
import Vapor

func routes(_ app: Application) throws {
    let setup = app.grouped("setup")
    setup.get("populate") { req async throws -> Response in
        try await req.collection.drop()
        let docs: [BSONDocument] = (1...100).map { ["_id": .int64(Int64($0)), "string": "abcdef"] }
        try await req.collection.insertMany(docs)
        return Response(status: .ok)
    }

    let asyncAwait = app.grouped("aa")
    let elf = app.grouped("elf")

    asyncAwait.get("find") { req async throws -> [BSONDocument] in
        try await req.collection.find(getRandomFilter()).toArray()
    }

    elf.get("find") { req -> EventLoopFuture<[BSONDocument]> in
        req.collection.find(getRandomFilter()).flatMap { cursor in cursor.toArray() }
    }

    asyncAwait.get("countDocuments") { req async throws -> Int in
        try await req.collection.countDocuments(getRandomFilter())
    }

    elf.get("distinct") { req -> EventLoopFuture<Int> in
        req.collection.countDocuments(getRandomFilter())
    }
}

func getRandomFilter() -> BSONDocument {
    let randomInt = Int.random(in: 1...100)
    return ["_id": ["$lt": .int64(Int64(randomInt))]]
}

extension Request {
    var collection: MongoCollection<BSONDocument> {
        self.mongoDB.client.db("home").collection("find")
    }
}
