//
//  MigraineCellViewModel.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 6/7/19.
//  Copyright © 2019 rmf. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct MigraineCellViewModel {
    // Outputs
    let title: Driver<String>
    let description: Driver<String>
    let migraine: BehaviorSubject<Migraine>
    
    private let disposeBag = DisposeBag()
    
    init(id: Int) {
        migraine = BehaviorSubject(value: Migraine.fetch(migraineId: id)!)
        
        title = migraine
            .map { CommonDateFormatter.string(from: $0.startDate) }
            .asDriver(onErrorJustReturn: "Error")
        description = migraine
            .map { m in
                let dcfmt = DateComponentsFormatter()
                dcfmt.allowsFractionalUnits = false
                dcfmt.unitsStyle = .short
                dcfmt.includesApproximationPhrase = false
                dcfmt.allowedUnits = [.day, .hour, .minute]
                let lenString = dcfmt.string(from: m.length) ?? "Error"
                let sevString = severityString(m.severity)
                return "\(lenString)  \(sevString)" }
            .asDriver(onErrorJustReturn: "")
    }
}
