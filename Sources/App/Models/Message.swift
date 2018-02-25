//
//  Message.swift
//  project4PackageDescription
//
//  Created by Naoki Fujii on 2018/02/24.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

final class Message: SQLiteModel {
    var id: Int?
    var forum: Int
    var title: String
    var body: String
    var parent: Int
    var user: String
    var date: Date

    public init(id: Int?, forum: Int, title: String, body: String, parent: Int, user: String, date: Date) {
        self.id = id
        self.forum = forum
        self.title = title
        self.body = body
        self.parent = parent
        self.user = user
        self.date = date
    }
}

/// Allows `Forum` to be used as a dynamic migration.
extension Message: Migration { }

/// Allows `Forum` to be encoded to and decoded from HTTP messages.
extension Message: Content { }
