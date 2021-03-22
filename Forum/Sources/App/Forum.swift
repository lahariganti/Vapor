//
//  Forum.swift
//  App
//
//  Created by Lahari Ganti on 8/11/19.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

struct Forum: Content, SQLiteModel, Migration {
    var id: Int?
    var name: String?
}
