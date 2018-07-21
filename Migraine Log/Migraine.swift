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
    var id: Int = -1
    var date: Date
    var length: TimeInterval
    var cause: String
    var notes: String
    var severity: Int {
        didSet {
            if self.severity > 5 {
                self.severity = 1
            }
        }
    }
    
    static var newMigraineDate = Date(timeIntervalSince1970: 0)
    init(date: Date = Migraine.newMigraineDate, length: TimeInterval = 0, cause: String = "", notes: String = "", severity: Int = 1) {
        self.date = date
        self.length = length
        self.cause = cause
        self.notes = notes
        self.severity = severity
    }

    // MARK: Formatted strings
    private var dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.doesRelativeDateFormatting = true
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt
    }()
    var formattedDate: String {
        return self.dateFormatter.string(from: self.date)
    }
    
    private var lengthFormatter: DateComponentsFormatter = {
        let dcfmt = DateComponentsFormatter()
        dcfmt.allowsFractionalUnits = false
        dcfmt.unitsStyle = .short
        dcfmt.includesApproximationPhrase = false
        dcfmt.allowedUnits = [.day, .hour, .minute]
        return dcfmt
    }()
    var formattedLength: String {
        return self.lengthFormatter.string(from: self.length) ?? ""
    }
    
    var formattedSeverity: String {
        let symbols = Array<String>(repeating: "⚡️", count: self.severity)
        return symbols.joined(separator: " ")
        
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
    
    convenience init(fromRow row: Row) {
        self.init(date: row[Columns.date], length: row[Columns.length], cause: row[Columns.cause], notes: row[Columns.notes], severity: row[Columns.severity])
        self.id = row[Columns.id]
    }
    
    static func count() -> Int {
        return (try? DB.shared.connection.scalar(self.table.count)) ?? 0
    }
    
    func treatment(medicine: Medicine) -> Treatment {
        if let t = Treatment.fetch(in: self, forMedicine: medicine) {
            return t
        }
        let t = Treatment(migraine: self, medicine: medicine, amount: 0)
        t.save()
        return t
    }
    
    func save() {
        if self.id != -1 {
            let existing = Migraine.table.filter(Columns.id == self.id)
            let updateQuery = existing.update(Columns.date <- self.date, Columns.length <- self.length, Columns.cause <- self.cause, Columns.notes <- self.notes, Columns.severity <- self.severity)
            if let count = try? DB.shared.connection.run(updateQuery), count == 1 { return }
        }
        
        assert(self.id == -1)
        DB.shared.run(Migraine.table.insert(Columns.date <- self.date, Columns.length <- self.length, Columns.cause <- self.cause, Columns.notes <- self.notes, Columns.severity <- self.severity))
    }
    
    static func newestIds(location: Int, length: Int) -> [Int] {
        let query = self.table
            .select(Columns.id, Columns.date)
            .order(Columns.date.desc)
            .limit(length, offset: location)
        if let rows = try? DB.shared.connection.prepare(query) {
            return rows.map { $0[Columns.id] }
        }
        return []
    }
    
    static func fetch(migraineId: Int) -> Migraine? {
        if let pluck = try? DB.shared.connection.pluck(self.table.filter(Columns.id == migraineId)), let row = pluck {
            return Migraine(fromRow: row)
        }
        return nil
    }
    
    func delete() {
        let query = Migraine.table.filter(Columns.id == self.id).delete()
        do {
            try DB.shared.connection.run(query)
        } catch {
            print("Couldn't delete migraine id \(self.id)")
        }
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
                
                output += "\(dateFormatter.string(from: m.date)) - \(m.formattedLength) migraine, severity \(m.severity)\n"
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