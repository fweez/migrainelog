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
            //c.trace { print($0) }
        } catch {
            assertionFailure("Could not open migraines.sqlite3")
            c = (try? Connection())!
        }
        print("Connected to \(path)/migraines.sqlite3")
        return c
    }()
    
    static var shared = DB()
    
    init() {
        Migraine.createTable(connection: self.connection)
        Treatment.createTable(connection: self.connection)
    }
    
    func checkDBVersion() {
        switch self.connection.userVersion {
        case 0:
            self.connection.userVersion = 1
        case 1:
            let oldMigraineTable = Table("migraines_old")
            do {
                try self.connection.run(Migraine.table.rename(oldMigraineTable))
            } catch {
                print("Couldn't rename migraines table")
            }
            Migraine.createTable(connection: self.connection)
            
            struct OldMigraineColumns {
                static let id = Expression<Int>("id")
                static let date = Expression<Date>("date")
                static let length = Expression<TimeInterval>("length")
                static let cause = Expression<String>("cause")
                static let notes = Expression<String>("notes")
                static let severity = Expression<Int>("severity")
            }
            
            if let rows = try? self.connection.prepare(oldMigraineTable) {
                for row in rows {
                    let len = row[OldMigraineColumns.length]
                    let startDate = row[OldMigraineColumns.date]
                    let endDate = startDate.addingTimeInterval(len)
                    let m = Migraine(startDate: row[OldMigraineColumns.date], endDate: endDate, cause: row[OldMigraineColumns.cause], notes: row[OldMigraineColumns.notes], severity: row[OldMigraineColumns.severity])
                    _ = m.save()
                }
            }
            
            self.connection.userVersion = 2
        case 2:
            return
        default:
            assertionFailure("Unknown database version")
        }
    }
}

// MARK: SQlite stuff
extension DB {
    func run(_ insert: Insert) -> Int? {
        do {
            let id = try self.connection.run(insert)
            return Int(id)
        } catch {
            print("Couldn't run insert '\(insert)': \(error)")
            return nil
        }
    }
}

extension Connection {
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}
