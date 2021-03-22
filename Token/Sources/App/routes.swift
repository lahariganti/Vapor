import Routing
import Vapor
import Fluent
import FluentSQLite

public func routes(_ router: Router) throws {
    router.post(User.self, at: "create"){ req, user -> Future<User> in
        return User.find(user.id!, on: req).flatMap(to: User.self) { existing in
            guard existing == nil else {
                throw Abort(.badRequest)
            }

            return user.create(on: req).map(to: User.self) { user in
                return user
            }
        }
    }

    router.post("login") { req -> Future<Token> in
        let username: String = try req.content.syncGet(at: "id")
        let password: String = try req.content.syncGet(at: "password")

        guard username.count > 0, password.count > 0 else {
            throw Abort(.badRequest)
        }

        return User.find(username, on: req).flatMap(to: Token.self) { user in
            _ = Token.query(on: req).filter(\.expiry < Date()).delete()

            guard let user = user else {
                throw Abort(.notFound)
            }

            guard user.password == password else {
                throw Abort(.unauthorized)
            }

            let newToken = Token(id: nil, username: username, expiry: Date().addingTimeInterval(86400))

            return newToken.create(on: req).map(to: Token.self) { newToken in
                return newToken
            }
        }
    }
}
