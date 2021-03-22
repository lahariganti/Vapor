import Crypto
import Foundation
import Routing
import Vapor
import Fluent
import FluentSQLite

public func routes(_ router: Router) throws {
    router.get() { req -> Future<View> in
        struct HomeContext: Codable {
            var username: String?
            var forums: [Forum]
        }

        return Forum.query(on: req).all().flatMap(to: View.self) { forums in
            let context = HomeContext(username: getUsername(req), forums: forums)
            return try req.view().render("home", context)
        }
    }

    router.get("setup") { req -> String in
        let item1 = Message(id: 1, forum: 1, title: "Welcome", body: "Hello!", parent: 0, user: "lganti", date: Date())
        let item2 = Message(id: 2, forum: 1, title: "Second post", body: "Hello!", parent: 0, user: "lganti", date: Date())
        let item3 = Message(id: 3, forum: 1, title: "Test reply", body: "Yay!", parent: 1, user: "lganti", date: Date())

        _ = item1.create(on: req)
        _ = item2.create(on: req)
        _ = item3.create(on: req)

        return "OK"
    }

    router.get("forum", Int.parameter) { req -> Future<View> in
        struct ForumContext: Codable {
            var username: String?
            var forum: Forum
            var messages: [Message]
        }

        let forumID = try req.parameters.next(Int.self)


        return Forum.find(forumID, on: req).flatMap(to: View.self) { forum in
            guard let forum = forum else {
                throw Abort(.notFound)
            }

            let query = Message.query(on: req)
                .filter(\.forum == forum.id!)
                .filter(\.parent == 0)
                .all()

            return query.flatMap(to: View.self) { messages in
                let context = ForumContext(username: getUsername(req), forum: forum, messages: messages)
                return try req.view().render("forum", context)
            }
        }
    }

    router.get("forum", Int.parameter, Int.parameter) { req -> Future<View> in
        struct MessageContext: Codable {
            var username: String?
            var forum: Forum
            var message: Message
            var replies: [Message]
        }

        let forumID = try req.parameters.next(Int.self)
        let messageID = try req.parameters.next(Int.self)

        return Forum.find(forumID, on: req).flatMap(to: View.self) { forum in
            guard let forum = forum else {
                throw Abort(.notFound)
            }

            return Message.find(messageID, on: req).flatMap(to: View.self) { message in
                guard let message = message else {
                    throw Abort(.notFound)
                }

                let query = Message.query(on: req)
                    .filter(\.parent == message.id!)
                    .all()

                return query.flatMap(to: View.self) { replies in
                    let context = MessageContext(username: getUsername(req), forum: forum, message: message, replies: replies)
                    return try req.view().render("message", context)
                }
            }
        }
    }

    router.get("users", "create") { req -> Future<View> in
        return try req.view().render("users-create")
    }

    router.post("users", "create") { req -> Future<View> in
        var user = try req.content.syncDecode(User.self)
        return User.query(on: req).filter(\.username == user.username).first().flatMap(to: View.self) { existing in
            if existing == nil {
                user.password = try BCrypt.hash(user.password)
                return user.save(on: req).flatMap(to: View.self) { user in
                    return try req.view().render("users-welcome")
                }
            } else {
                let context = ["error": "true"]
                return try req.view().render("users-welcome", context)
            }

        }
    }

    router.get("users", "login") { req -> Future<View> in
        return try req.view().render("users-login")
    }

    router.post(User.self, at: "users", "login") { req, user -> Future<View> in
        return User.query(on: req).filter(\.username == user.username).first().flatMap(to: View.self) { existing in
            if let existing = existing {
                if try BCrypt.verify(user.password, created: existing.password) {
                    let session = try req.session()
                    session["username"] = existing.username
                    return try req.view().render("users-welcome")
                }
            }
            
            let context = ["error": "true"]
            return try req.view().render("users-login", context)
        }
    }

    router.post("forum", Int.parameter, use: postOrReply)
    router.post("forum", Int.parameter, Int.parameter, use: postOrReply)
}

func postOrReply(req: Request) throws -> Future<Response> {
    guard let username = getUsername(req) else {
        throw Abort(.unauthorized)
    }

    let forumID = try req.parameters.next(Int.self)
    let parentID = (try? req.parameters.next(Int.self)) ?? 0
    let title: String = try req.content.syncGet(at: "title")
    let body: String = try req.content.syncGet(at: "body")
    let post = Message(id: nil, forum: forumID, title: title,
                       body: body, parent: parentID, user: username, date: Date())
    return post.save(on: req).map(to: Response.self) { post in
        if parentID == 0 {
            return req.redirect(to: "/forum/\(forumID)/\(post.id!)")
        } else {
            return req.redirect(to: "/forum/\(forumID)/\(parentID)")
        }
    }
}

func getUsername(_ req: Request) -> String? {
    let session = try? req.session()
    return session?["username"]
}
