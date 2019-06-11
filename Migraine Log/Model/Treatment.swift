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
    
    var limit: Int {
        switch self {
        case .Rizatriptan: return 2
        case .Caffeine: return 4
        case .Ibuprofen: return 4
        }
    }
    
    var dose: Int {
        switch self {
        case .Rizatriptan: return 10
        case .Caffeine: return 60
        case .Ibuprofen: return 200
        }
    }
    
    var unit: String {
        return "mg"
    }
}

struct Treatment {
    var id: Int = -1
    var migraineId: Int
    var medicine: Medicine
    var amount: Int {
        didSet {
            self.amount = self.amount % (self.medicine.limit + 1)
        }
    }
    
    init(migraineId: Int, medicine: Medicine, amount: Int) {
        self.migraineId = migraineId
        self.medicine = medicine
        self.amount = amount
    }
    
    init(migraine: Migraine, medicine: Medicine, amount: Int) {
        self.init(migraineId: migraine.id, medicine: medicine, amount: amount)
    }
    
    var amountDescription: String {
        return "\(self.amount * self.medicine.dose) \(self.medicine.unit)"
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
    
    init?(fromRow row: Row) {
        guard let medicine = Medicine(rawValue: row[Columns.medicine]) else { return nil }
        self.init(migraineId: row[Columns.migraineId], medicine: medicine, amount: row[Columns.amount])
        self.id = row[Columns.id]
    }
    
    func save() -> Int {
        if id != -1 {
            let existing = Treatment.table.filter(Columns.id == id)
            if let count = try? DB.shared.connection.run(existing.update(Columns.amount <- amount)) {
                assert(count == 1, "Didn't update?!")
            }
            return id
        }
        
        guard let id = DB.shared.run(Treatment.table.insert(Columns.migraineId <- migraineId, Columns.medicine <- medicine.rawValue, Columns.amount <- amount)) else {
            assertionFailure("Couldn't insert treatment")
            return -1
        }
        return id
    }
    
    static func fetch(in migraine: Migraine, forMedicine medicine: Medicine) -> Treatment? {
        if let row = try? DB.shared.connection.pluck(self.table.filter(Columns.migraineId == migraine.id && Columns.medicine == medicine.rawValue)) {
            return Treatment(fromRow: row)
        }
        return nil
    }
    
    static func fetch(id: Int) -> Treatment? {
        guard let row = try? DB.shared.connection.pluck(self.table.filter(Columns.id == id)) else { return nil }
        return Treatment(fromRow: row)
    }
    
    static func historicalMedicineCount(medicine: Medicine, since: Date) -> Int {
        let query = Treatment.table.join(Migraine.table, on: Columns.migraineId == Migraine.table[Migraine.Columns.id]).filter(Migraine.Columns.date > since && Columns.medicine == medicine.rawValue).select(Columns.amount.sum)
        if let statement = try? DB.shared.connection.prepare(query.asSQL()), let result = try? statement.scalar(), let count = result as? Int64 {
            return Int(count)
        }
        return 0
    }
    
    static func monthMedicineCount(medicine: Medicine) -> Int {
        return self.historicalMedicineCount(medicine: medicine, since: Date(timeIntervalSinceNow: Migraine.oneMonth))
    }
    
    static var monthRztCount: Int { return self.monthMedicineCount(medicine: .Rizatriptan) }
    static var monthIbuprofenCount: Int { return self.monthMedicineCount(medicine: .Ibuprofen) }
    
    static func quarterMedicineCount(medicine: Medicine) -> Int {
        return self.historicalMedicineCount(medicine: medicine, since: Date(timeIntervalSinceNow: Migraine.quarter))
    }
    static var quarterRztCount: Int { return self.quarterMedicineCount(medicine: .Rizatriptan) }
    static var quarterIbuprofenCount: Int { return self.quarterMedicineCount(medicine: .Ibuprofen) }
    
    func incrementedAmount() -> Int {
        return (amount + 1) % (medicine.limit + 1)
    }
    
    func incrementAmount() -> Int {
        precondition(id != -1)
        let existing = Treatment.table.filter(Columns.id == id)
        guard let count = try? DB.shared.connection.run(existing.update(Columns.amount <- incrementedAmount())), count == 1 else {
            assertionFailure("Didn't update?!")
            return -1
        }
        return id
    }
}
