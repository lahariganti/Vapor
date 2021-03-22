//
//  FrontEnd.swift
//  App
//
//  Created by Lahari Ganti on 8/13/19.
//

import Foundation
import Vapor
import Markdown
import SwiftSlug
import Vapor

class FrontEnd: RouteCollection {
    var categories = [Category]()

    func boot(router: Router) throws {
        router.get(use: getHomePage)
        router.get("read", Int.parameter, String.parameter, use: getStory)
        router.group("admin") { group in
            group.get(use: self.getAdminHome)
            group.get("edit", Int.parameter, use: self.getAdminEdit)
            group.get("edit", use: self.getAdminEdit)
            group.post("edit", Int.parameter, use: self.postAdminEdit)
            group.post("edit", use: self.postAdminEdit)
        }
    }

    func getHomePage(req: Request) throws -> Future<View> {
        return try req.client().get("/backend/stories").flatMap(to: View.self) { response in
            let posts = try response.content.syncDecode([Post].self)
            let categories = try self.getCategories(for: req)
            return categories.flatMap(to: View.self) { categories in
                let context = CategoryPage(title: "Top Stories", stories: posts, categories: categories)
                return try req.view().render("home", context)
            }
        }
    }

    func getStory(req: Request) throws -> Future<View> {
        guard let id = try? req.parameters.next(Int.self) else {
            return try req.view().render("error")
        }

        let uri = "/backend/story/\(id)"

        return try req.client().get(uri).flatMap(to: View.self) { response in
            if let post = try? response.content.syncDecode(Post.self) {
                return try self.getCategories(for: req).flatMap(to: View.self) { categories in
                    let context = StoryPage(title: post.title, story: post, categories: categories)
                    return try req.view().render("read", context)
                }
            } else {
                return try req.view().render("error")
            }
        }
    }

    func getCategories(for req: Request) throws -> Future<[Category]> {
        guard self.categories.count == 0 else {
            return Future.map(on: req) { self.categories }
        }

        return try req.client().get("/backend/categories").flatMap(to: [Category].self) { response in
            try response.content.decode([Category].self).map(to: [Category].self) { result in
                self.categories = result
                return result
            }
        }
    }

    func getAdminHome(req: Request) throws -> Future<View> {
        return try req.client().get("/backend/stories").flatMap(to: View.self) { response in
            let posts = try response.content.syncDecode([Post].self)
            let categories = try self.getCategories(for: req)

            return categories.flatMap(to: View.self) { categories in
                let context = CategoryPage(title: "Admin", stories: posts, categories: categories)
                return try req.view().render("admin_home", context)
            }
        }
    }

    func getAdminEdit(req: Request) throws -> Future<View> {
        if let id = try? req.parameters.next(Int.self) {
            let uri = "/backend/story/\(id)"
            return try req.client().get(uri).flatMap(to: View.self) { response in
                let post = try response.content.syncDecode(Post.self)
                let categories = try self.getCategories(for: req)

                return categories.flatMap(to: View.self) { categories in
                    let context = StoryPage(title: "Article Edit", story: post, categories: categories)

                    return try req.view().render("admin_edit", context)
                }
            }
        } else {
            let empty = Post(id: nil, title: "", strap: "", content: "", category: 1, slug: "", date: Date())
            return try getCategories(for: req).flatMap(to: View.self) { categories in
                let context = StoryPage(title: "Create Article", story: empty, categories: categories)
                return try req.view().render("admin_edit", context)
            }
        }
    }

    func postAdminEdit(req: Request) throws -> Future<Response> {
        let title: String = try req.content.syncGet(at: "title")
        let strap: String = try req.content.syncGet(at: "strap")
        let content: String = try req.content.syncGet(at: "content")
        let category: Int = try req.content.syncGet(at: "category")
        var slug: String = try req.content.syncGet(at: "slug")

        slug = slug.trimmingCharacters(in: .whitespacesAndNewlines)
        if slug.count == 0 {
            slug = try title.convertedToSlug()
        } else {
            slug = try slug.convertedToSlug()
        }

        let id = try? req.parameters.next(Int.self)
        let post = Post(id: id, title: title, strap: strap, content: content, category: category, slug: slug, date: Date())

        let uri = "/backend/story"
        let request = try req.client().post(uri) { postRequest in
            try postRequest.content.encode(post)
        }

        return request.map(to: Response.self) { response in
            if response.http.status == .ok {
                return req.redirect(to: "/admin")
            } else {
                return Response(http: HTTPResponse(status: .internalServerError), using: req)
            }
        }
    }
}
