//
//  Poll.swift
//  App
//
//  Created by Lahari Ganti on 8/10/19.
//

import Vapor
import Foundation
import Fluent
import FluentSQLite

struct Poll: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var title: String
    var option1: String
    var option2: String
    var votes1: Int
    var votes2: Int
}
