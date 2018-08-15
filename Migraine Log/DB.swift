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
    var connection: Connection = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        var c: Connection
        do {
            c = try Connection("\(path)/migraines.sqlite3")
            c.trace { print($0) }
        } catch {
            assertionFailure("Could not open migraines.sqlite3")
            c = (try? Connection())!
        }
        print("Connected to \(path)/migraines.sqlite3")
        return c
    }()
    static var shared = DB()
    
    static var version = 1
    
    init() {
        Migraine.createTable(connection: self.connection)
        Treatment.createTable(connection: self.connection)
    }
    
    func checkDBVersion() {
        switch self.connection.userVersion {
        case 0:
            self.connection.userVersion = 1
        case 1:
            do {
                try self.connection.run(Migraine.table.addColumn(Migraine.Columns.endDate))
            } catch let Result.error(_, code, _) where code == SQLITE_ERROR {
                print("probably a duplicate column name")
            } catch {
                assertionFailure()
            }
            let query = "select id, length from migraines"
            if let rows = try? self.connection.prepare(query) {
                for row in rows {
                    if let m = Migraine.fetch(migraineId: Int(row[0] as! Int64)) {
                        m.endDate = m.date.addingTimeInterval(TimeInterval(row[1] as! Double))
                        m.save()
                    }
                }
            }
            
            self.connection.userVersion = 2
        default:
            assertionFailure("Unknown database version")
        }
    }
}

// MARK: SQlite stuff
extension DB {
    func run(_ insert: Insert) {
        do {
            try self.connection.run(insert)
        } catch {
            print("Couldn't run insert '\(insert)': \(error)")
        }
    }
}

extension Connection {
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}
