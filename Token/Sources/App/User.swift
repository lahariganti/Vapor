//
//  User.swift
//  App
//
//  Created by Lahari Ganti on 8/13/19.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct User: Content, SQLiteStringModel, Migration {
    var id: String?
    var password: String
}
