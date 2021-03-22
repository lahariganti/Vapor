//
//  Cupcake.swift
//  App
//
//  Created by Lahari Ganti on 8/9/19.
//

import Foundation
import Vapor
import FluentSQLite

struct Cupcake: Content, SQLiteModel, Migration {
    var id: Int?
    var name: String
    var description: String
    var price: Int
}
