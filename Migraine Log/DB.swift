//
//  DB.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import Foundation
import SQLite

class DB {
    var connection: Connection
    static var shared = DB()
    
    static var version = 1
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
            self.connection = try Connection("\(path)/migraines.sqlite3")
            self.connection.trace { print($0) }
        } catch {
            assertionFailure("Could not open migraines.sqlite3")
            self.connection = (try? Connection())!
        }
        print("Connected to \(path)/migraines.sqlite3")
        
        if let pluck = try? self.connection.pluck(DB.table), let row = pluck, row[Columns.version] == DB.version {
            return
        }
        
        // NO UPGRADES!
//        do {
//            try self.connection.run(DB.table.drop())
//            try self.connection.run(Migraine.table.drop())
//            try self.connection.run(Treatment.table.drop())
//        } catch {
//            print("Couldn't drop: \(error)")
//        }
        DB.createTable(connection: self.connection)
        Migraine.createTable(connection: self.connection)
        Treatment.createTable(connection: self.connection)
    }
}

// MARK: SQlite stuff
extension DB {
    struct Columns {
        static let version = Expression<Int>("version")
    }
    
    static var table = Table("meta")
    static func createTable(connection: Connection) {
        do {
            try connection.run(self.table.create { t in
                t.column(Columns.version)
            })
        } catch {
            print("didn't create meta table: \(error)")
        }
    }
}
