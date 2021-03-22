//
//  StoryPage.swift
//  App
//
//  Created by Lahari Ganti on 8/15/19.
//

import Foundation

struct StoryPage: Codable {
    var title: String
    var story: Post
    var categories: [Category]
}
