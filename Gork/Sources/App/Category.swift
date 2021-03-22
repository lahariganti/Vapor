//
//  Category.swift
//  App
//
//  Created by Lahari Ganti on 8/13/19.
//

import Foundation
import FluentMySQL
import Vapor

struct Category: Content, MySQLModel, Migration {
    var id: Int?
    var name: String
}
