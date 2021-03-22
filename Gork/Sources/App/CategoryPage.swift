//
//  CategoryPage.swift
//  App
//
//  Created by Lahari Ganti on 8/14/19.
//

import Foundation

struct CategoryPage: Codable {
    var title: String
    var stories: [Post]
    var categories: [Category]
}
