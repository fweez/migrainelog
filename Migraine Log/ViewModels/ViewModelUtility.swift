//
//  ViewModelUtility.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 6/12/19.
//  Copyright © 2019 rmf. All rights reserved.
//

import Foundation
import RxSwift

let DBScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())

// MARK: Formatted strings
let CommonDateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .medium
    fmt.timeStyle = .short
    return fmt
}()

func severityString(_ severity: Int) -> String {
    let symbols = Array<String>(repeating: "⚡️", count: severity)
    return symbols.joined(separator: " ")
}
