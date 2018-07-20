//
//  Treatment.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import Foundation
import SQLite

enum Medicine: String {
    case Rizatriptan
    case Caffeine
    case Ibuprofen
}

class Treatment {
    var migraineId: Int
    var medicine: Medicine
    var amount: Int
    
    init(migraine: Migraine, medicine: Medicine, amount: Int) {
        self.migraineId = migraine.id
        self.medicine = medicine
        self.amount = amount
    }
}

// MARK: SQLite stuff
extension Treatment {
    struct Columns {
        static let id = Expression<Int>("id")
        static let migraineId = Expression<Int>("migraineId")
        static let medicine = Expression<String>("medicine")
        static let amount = Expression<Int>("amount")
    }
    
    static var table = Table("treatments")
    static func createTable(connection: Connection) {
        do {
            try connection.run(self.table.create { t in
                t.column(Columns.id, primaryKey: true)
                t.column(Columns.migraineId)
                t.column(Columns.medicine)
                t.column(Columns.amount)
                t.foreignKey(Columns.migraineId, references: Migraine.table, Migraine.Columns.id)
            })
        } catch {
            print("didn't create course table: \(error)")
        }
    }
}
