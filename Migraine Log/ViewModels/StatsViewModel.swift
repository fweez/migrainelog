//
//  StatsViewModel.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 6/13/19.
//  Copyright © 2019 rmf. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct MigraineStats {
    let migraines: Int
    let doses: [Medicine: Int]
    
    init() {
        migraines = 0
        doses = [:]
    }
    
    init(range: StatsTimeRange) {
        switch range {
        case .month:
            migraines = Migraine.monthMigraineCount
            doses = Dictionary<Medicine, Int>.init(uniqueKeysWithValues: Medicine.allCases
                .map { ($0, Treatment.monthMedicineCount(medicine: $0)) })
        case .quarter:
            migraines = Migraine.quarterMigraineCount
            doses = Dictionary<Medicine, Int>.init(uniqueKeysWithValues: Medicine.allCases
                .map { ($0, Treatment.quarterMedicineCount(medicine: $0)) })
        }
    }
}

enum StatsTimeRange: String {
    case month = "30 days"
    case quarter = "90 days"
}

struct StatsBlockViewModel {
    // OUTPUTS
    let title: Driver<String>
    let migraineCount: Driver<String>
    let rizatriptanCount: Driver<String>
    let ibuprofenCount: Driver<String>
    
    // INPUTS
    let range: BehaviorSubject<StatsTimeRange> = BehaviorSubject(value: .month)
    
    private let stats: Observable<MigraineStats>
    
    init() {
        stats = range
            .observeOn(DBScheduler)
            .map { MigraineStats(range: $0) }
            .share(replay: 1, scope: .forever)
        
        func pluralizeOn(_ i: Int) -> String { return i > 1 ? "s" : "" }
        
        title = range
            .map { $0.rawValue }
            .asDriver(onErrorJustReturn: "ERROR")
        migraineCount = stats
            .map { "\($0.migraines) migraine" + pluralizeOn($0.migraines) }
            .asDriver(onErrorJustReturn: "ERROR")
        rizatriptanCount = stats
            .map { stats in
                let rzt = stats.doses[.Rizatriptan] ?? 0
                return "\(rzt) dose" + pluralizeOn(rzt) + " of rizatriptan"
            }
            .asDriver(onErrorJustReturn: "ERROR")
        ibuprofenCount = stats
            .map { stats in
                let ibu = stats.doses[.Ibuprofen] ?? 0
                return "\(ibu) dose" + pluralizeOn(ibu) + " of rizatriptan"
            }
            .asDriver(onErrorJustReturn: "ERROR")
    }
}
