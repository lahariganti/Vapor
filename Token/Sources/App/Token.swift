//
//  Token.swift
//  App
//
//  Created by Lahari Ganti on 8/13/19.
//

import Foundation
import FluentSQLite
import Vapor
struct Token: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var username: String
    var expiry: Date
}
