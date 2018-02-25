//
//  User.swift
//  project4PackageDescription
//
//  Created by Naoki Fujii on 2018/02/24.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

final class User: SQLiteModel {
    var id: Int?
    var username: String
    var password: String

    public init(id: Int?, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}

extension User: Content { }

extension User: Migration { }
