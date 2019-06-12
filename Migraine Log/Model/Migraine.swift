//
//  Migraine.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import Foundation
import SQLite

struct Migraine {
    var id: Int = -1
    var startDate: Date
    var endDate: Date?
    var cause: String
    var notes: String
    var severity: Int
    
    var incrementedSeverity: Int { return (severity + 1) % 5 }
    
    var length: TimeInterval {
        guard let endDate = self.endDate else { return 0 }
        return endDate.timeIntervalSince(self.startDate)
    }
    
    init(startDate: Date = Date(), endDate: Date? = nil, cause: String = "", notes: String = "", severity: Int = 1) {
        self.startDate = startDate
        self.endDate = endDate
        self.cause = cause
        self.notes = notes
        self.severity = severity
    }
}

// MARK: SQlite stuff
extension Migraine {
    struct Columns {
        static let id = Expression<Int>("id")
        static let date = Expression<Date>("date")
        static let endDate = Expression<Date?>("endDate")
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
                t.column(Columns.endDate)
                t.column(Columns.cause)
                t.column(Columns.notes)
                t.column(Columns.severity)
            })
        } catch {
            print("didn't create course table: \(error)")
        }
    }
    
    init(fromRow row: Row) {
        self.init(startDate: row[Columns.date], endDate: row[Columns.endDate], cause: row[Columns.cause], notes: row[Columns.notes], severity: row[Columns.severity])
        self.id = row[Columns.id]
    }
    
    func treatment(medicine: Medicine) -> Treatment {
        if self.id != -1, let t = Treatment.fetch(in: self, forMedicine: medicine) {
            return t
        }
        var t = Treatment(migraine: self, medicine: medicine, amount: 0)
        let id = t.save()
        t.id = id
        return t
    }
    
    func save() -> Int {
        if id != -1 {
            let existing = Migraine.table.filter(Columns.id == id)
            let updateQuery = existing.update(Columns.date <- startDate, Columns.endDate <- endDate, Columns.cause <- cause, Columns.notes <- notes, Columns.severity <- severity)
            if let count = try? DB.shared.connection.run(updateQuery), count == 1 {
                return id
            }
        }
        
        assert(id == -1)
        let insert = Migraine.table.insert(Columns.date <- startDate, Columns.endDate <- endDate, Columns.cause <- cause, Columns.notes <- notes, Columns.severity <- severity)
        guard let id = DB.shared.run(insert) else {
            assertionFailure("Didn't insert a migraine!")
            return -1
        }
        return id
    }
    
    static func allIds() -> [Int] {
        let query = self.table
            .select(Columns.id, Columns.date)
            .order(Columns.date.desc)
        if let rows = try? DB.shared.connection.prepare(query) { return rows.map { $0[Columns.id] } }
        return []
    }
    
    static func fetch(migraineId: Int) -> Migraine? {
        if let row = try? DB.shared.connection.pluck(self.table.filter(Columns.id == migraineId)) {
            return Migraine(fromRow: row)
        }
        return nil
    }
    
    static let oneMonth = TimeInterval(-60 * 60 * 24 * 30)
    static let quarter = TimeInterval(-60 * 60 * 24 * 30 * 3)
    
    static func historicalMigraineCount(since: Date) -> Int {
        let query = Migraine.table.filter(Columns.date > since).count
        if let count = try? DB.shared.connection.scalar(query) {
            return count
        }
        return 0
    }
    
    static var monthMigraineCount: Int { return self.historicalMigraineCount(since: Date(timeIntervalSinceNow: Migraine.oneMonth)) }
    static var quarterMigraineCount: Int { return self.historicalMigraineCount(since: Date(timeIntervalSinceNow: Migraine.quarter)) }
}

// Suport for MigraineListViewModel
extension Migraine {
    static func new() -> Int {
        let m = Migraine()
        let id = m.save()
        Medicine.allCases.forEach { _ = Treatment(migraineId: id, medicine: $0, amount: 0).save() }
        return id
    }
    
    static func deleteId(_ id: Int)  {
        let query = Migraine.table.filter(Columns.id == id).delete()
        do {
            try DB.shared.connection.run(query)
        } catch {
            print("Couldn't delete migraine id \(id)")
        }
    }
}

// Support for the MigraineDetailsViewModel
extension Migraine {
    func update(createUpdateQuery: (Table) -> Update) -> Int {
        assert(id != -1)
        let existing = Migraine.table.filter(Columns.id == id)
        let updateQuery = createUpdateQuery(existing)
        guard let count = try? DB.shared.connection.run(updateQuery), count == 1 else { return -1 }
        return id
    }
    
    func updateCause(_ cause: String) -> Int {
        return update { existing in existing.update(Columns.cause <- cause) }
    }
    
    func updateNotes(_ notes: String) -> Int {
        return update { existing in existing.update(Columns.notes <- notes) }
    }
    
    func increaseSeverity() -> Int {
        return update { existing in existing.update(Columns.severity <- incrementedSeverity) }
    }
    
    func updateStart(_ newStart: Date) -> Int {
        return update { existing in existing.update(Columns.date <- newStart) }
    }
    
    func updateEnd(_ newEnd: Date?) -> Int {
        return update { existing in existing.update(Columns.endDate <- newEnd) }
    }
}

extension Migraine {
    static func generateReport() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = false
        
        var output = """
        Migraine report: generated on \(dateFormatter.string(from: Date()))

        Migraines in the last 30 days: \(self.monthMigraineCount)
        Doses of Rizatriptan in the last 30 days: \(Treatment.monthRztCount)
        
        Migraines in the last 90 days: \(self.quarterMigraineCount)
        Doses of Rizatriptan in the last 90 days: \(Treatment.quarterRztCount)
        
        All recorded migraines:
        
        """
        
        if let rows = try? DB.shared.connection.prepare(self.table.order(Columns.date.desc)) {
            for row in rows {
                let m = Migraine(fromRow: row)
                let rzt = m.treatment(medicine: .Rizatriptan)
                let ibu = m.treatment(medicine: .Ibuprofen)
                let caf = m.treatment(medicine: .Caffeine)
                
                //output += "\(dateFormatter.string(from: m.startDate)) - \(m.formattedLength) migraine, severity \(m.severity)\n"
                if rzt.amount > 0 {
                    output += "\(rzt.amountDescription) rizatriptan\n"
                }
                if ibu.amount > 0 {
                    output += "\(ibu.amountDescription) ibuprofen\n"
                }
                if caf.amount > 0 {
                    output += "\(caf.amountDescription) caffeine\n"
                }
                
                output += "Cause: "
                if m.cause.count > 0 {
                    output += m.cause
                } else {
                    output += "Unknown"
                }
                
                output += "\nNotes: "
                if m.notes.count > 0 {
                    output += m.notes
                } else {
                    output += "None"
                }
                output += "\n"
            }
        }
        
        return output
    }
}
