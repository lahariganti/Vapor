//
//  User.swift
//  App
//
//  Created by Lahari Ganti on 8/11/19.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor


struct User: Content, SQLiteModel, Migration {
    var id: Int?
    var username: String
    var password: String
}
