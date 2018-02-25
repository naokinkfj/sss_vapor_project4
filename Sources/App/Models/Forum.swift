//
//  Forum.swift
//  App
//
//  Created by Naoki Fujii on 2018/02/24.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

final class Forum: SQLiteModel {
    var id: Int?
    var name: String

    init(id: Int?, name: String) {
        self.id = id
        self.name = name
    }
}

/// Allows `Forum` to be used as a dynamic migration.
extension Forum: Migration { }

/// Allows `Forum` to be encoded to and decoded from HTTP messages.
extension Forum: Content { }
