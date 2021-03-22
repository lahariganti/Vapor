import Foundation
import Routing
import Vapor

public func routes(_ router: Router) throws {
    router.post(Poll.self, at: "polls", "create") {req, poll -> Future<Poll> in
        return poll.save(on: req)
    }

    router.get("polls", "list") { req -> Future<[Poll]> in
       return Poll.query(on: req).all()
    }

    router.post("polls", "vote", UUID.parameter, Int.parameter) { req -> Future<Poll> in
        let id = try req.parameters.next(UUID.self)
        let vote = try req.parameters.next(Int.self)

        return Poll.find(id, on: req).flatMap(to: Poll.self) { poll in
            guard var poll = poll else {
                throw Abort(.notFound)
            }

            if vote == 1 {
                poll.votes1 += 1
            } else {
                poll.votes2 += 1
            }

            return poll.save(on: req)
        }
    }
}
