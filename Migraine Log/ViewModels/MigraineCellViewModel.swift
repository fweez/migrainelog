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
            .map { $0.formattedStartDate }
            .asDriver(onErrorJustReturn: "Error")
        description = migraine
            .map { "\($0.formattedLength)  \($0.formattedSeverity)" }
            .asDriver(onErrorJustReturn: "")
    }
}
