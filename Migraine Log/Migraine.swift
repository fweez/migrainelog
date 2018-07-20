//
//  Migraine.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import Foundation
import SQLite

class Migraine {
    var id: Int = 0
    var date: Date
    var length: TimeInterval
    var cause: String
    var treatments: [String]
    var notes: String
    var severity: Int
    
    static var newMigraineDate = Date(timeIntervalSince1970: 0)
    init(date: Date = Migraine.newMigraineDate, length: TimeInterval = 0, cause: String = "", treatments: [String] = [], notes: String = "", severity: Int = 0) {
        self.date = date
        self.length = length
        self.cause = cause
        self.treatments = treatments
        self.notes = notes
        self.severity = severity
    }
}

// MARK: SQlite stuff
extension Migraine {
    struct Columns {
        static let id = Expression<Int>("id")
        static let date = Expression<Date>("date")
        static let length = Expression<TimeInterval>("length")
        static let cause = Expression<String>("cause")
        static let notes = Expression<String>("notes")
        static let severity = Expression<Int>("severity")
    }
    
    static var table = Table("migraines")
    static func createTable(connection: Connection) {
        do {
            try connection.run(self.table.create { t in
                t.column(Columns.id, primaryKey: true)
                t.column(Columns.date)
                t.column(Columns.length)
                t.column(Columns.cause)
                t.column(Columns.notes)
                t.column(Columns.severity)
            })
        } catch {
            print("didn't create course table: \(error)")
        }
    }
    
    static func count(connection: Connection) -> Int {
        return (try? connection.scalar(self.table.count)) ?? 0
    }
}
