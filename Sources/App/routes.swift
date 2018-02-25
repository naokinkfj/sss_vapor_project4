import Routing
import Vapor
import Foundation
import Fluent
import Async

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get("setup") { req -> String in
        //            let item1 = Forum(id: 1, name: "Taylor's Songs")
        //            let item2 = Forum(id: 2, name: "Taylor's Albums")
        //            let item3 = Forum(id: 3, name: "Taylor's Concerts")
        let item1 = Message(id: 1, forum: 1, title: "Welcome", body: "Hello!", parent: 0, user: "twostraws", date: Date())
        let item2 = Message(id: 2, forum: 1, title: "Second post", body: "Hello!", parent: 0, user: "twostraws", date: Date())
        let item3 = Message(id: 3, forum: 1, title: "Test reply", body: "Yay!", parent: 1, user: "twostraws", date: Date())

        _ = item1.create(on: req)
        _ = item2.create(on: req)
        _ = item3.create(on: req)

        return "OK"
    }

    router.get { req -> Future<View> in
        struct HomeContext: Codable {
            var username: String?
            var forums: [Forum]
        }
        let session = try req.session()
        session["username"] = "test"

        return Forum.query(on: req).all().flatMap(to: View.self) { forums in
            let context = HomeContext(username: getUserName(req), forums: forums)
            return try req.view().render("home", context)
        }
    }

    router.get("forum", Int.parameter) { req -> Future<View> in
        struct ForumContext: Codable {
            var username: String?
            var forum: Forum
            var messages: [Message]
        }

        let forumID = try req.parameter(Int.self)

        return Forum.find(forumID, on: req).flatMap(to: View.self) { forum in
            guard let forum = forum else {
                throw Abort(.notFound)
            }

            let query = Message.query(on: req)
                .filter(\.forum == forum.id!)
                .filter(\.parent == 0)
                .all()

            return query.flatMap(to: View.self) { messages in
                let context = ForumContext(username: getUserName(req), forum: forum, messages: messages)
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

        let forumID = try req.parameter(Int.self)
        let messageID = try req.parameter(Int.self)

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
                    let context = MessageContext(username: getUserName(req), forum: forum, message: message, replies: replies)
                    return try req.view().render("message", context)
                }
            }
        }
    }

    router.get("users", "create") { req -> Future<View> in
        return try req.view().render("users-create")
    }

    router.post(User.self, at: "users", "create") { req, user -> Future<View> in
        return User.query(on: req)
            .filter(\.username == user.username)
            .first().flatMap(to: View.self) { existing in
                if existing == nil {
                    user.password = try req.make(BCryptHasher.self).make(user.password)
                    return user.save(on: req).flatMap(to: View.self) { user in
                        let session = try req.session()
                        session["username"] = user.username
                        return try req.view().render("users-welcome")
                    }
                } else {
                    let context = ["error": "true"]
                    return try req.view().render("users-create", context)
                }
        }
    }

    router.get("users", "login") { req -> Future<View> in
        return try req.view().render("users-login")
    }

    router.post(User.self, at: "users", "login") { req, user -> Future<View> in
        return User.query(on: req)
            .filter(\.username == user.username)
            .first().flatMap(to: View.self) { existing in
                if let existing = existing {
                    if try req.make(BCryptHasher.self).verify(message: user.password, matches: existing.password) {
                        let session = try req.session()
                        session["username"] = existing.username
                        return try req.view().render("users-welcome")
                    }
                }
                let context = ["error": "true"]
                return try req.view().render("users-login", context)
        }
    }
}

private func getUserName(_ req: Request) -> String? {
    let session = try? req.session()
    return session?["username"]
}
