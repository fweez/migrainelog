//
//  MigraineDetailsViewModel.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 5/31/19.
//  Copyright © 2019 rmf. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct MigraineDetailsViewModel {
    // inputs
    var migraineId = BehaviorRelay<Int>(value: -1)
    var save = PublishSubject<Void>()
    var startTime = PublishSubject<Date>()
    var endTime = PublishSubject<Date>()
    var rizatriptanAmount = PublishSubject<Int>()
    var caffeineAmount = PublishSubject<Int>()
    var ibuprofenAmount = PublishSubject<Int>()
    
    // outputs
    var title: Driver<String>
    var formattedStart: Driver<String>
    var formattedRizatriptanAmount: Driver<String>
    var formattedCaffeineAmount: Driver<String>
    var formattedIbuprofenAmount: Driver<String>
    var formattedSeverity: Driver<String>
    var formattedEnd: Driver<String>
    
    // input-outputs
    var cause: Observable<String>
    var notes: Observable<String>
    
    private var migraine: Observable<Migraine>
    
    private let disposeBag = DisposeBag()
    
    init() {
        migraine = migraineId
            .map { Migraine.fetch(migraineId: $0) ?? Migraine() }
            .share(replay: 1, scope: .forever)
        title = migraine
            .map { "Migraine on \($0.formattedStartDate)" }
            .asDriver(onErrorJustReturn: "Error")
        formattedStart = migraine
            .map { $0.formattedStartDate }
            .asDriver(onErrorJustReturn: "Error")
        formattedRizatriptanAmount = migraine
            .map { $0.treatment(medicine: .Rizatriptan).amountDescription }
            .asDriver(onErrorJustReturn: "Error")
        formattedCaffeineAmount = migraine
            .map { $0.treatment(medicine: .Caffeine).amountDescription }
            .asDriver(onErrorJustReturn: "Error")
        formattedIbuprofenAmount = migraine
            .map { $0.treatment(medicine: .Ibuprofen).amountDescription }
            .asDriver(onErrorJustReturn: "Error")
        formattedSeverity = migraine
            .map { $0.formattedSeverity }
            .asDriver(onErrorJustReturn: "Error")
        formattedEnd = migraine
            .map { $0.formattedEndDate }
            .asDriver(onErrorJustReturn: "Error")
        cause = migraine
            .map { $0.cause }
        notes = migraine
            .map { $0.notes }
        
        let combinedInputs = Observable.combineLatest(migraine, startTime, endTime, cause, notes)
        save.withLatestFrom(combinedInputs)
            .subscribe(onNext: { inputs in
                let (migraine, startTime, endTime, cause, notes) = inputs
                migraine.startDate = startTime
                migraine.endDate = endTime
                migraine.cause = cause
                migraine.notes = notes
                migraine.save()
                
            })
            .disposed(by: disposeBag)
        save.withLatestFrom(Observable.combineLatest(migraine, rizatriptanAmount))
            .subscribe(onNext: { inputs in
                let (migraine, rizatriptanAmount) = inputs
                let r = migraine.treatment(medicine: .Rizatriptan)
                r.amount = rizatriptanAmount
                r.save()
            })
            .disposed(by: disposeBag)
        save.withLatestFrom(Observable.combineLatest(migraine, caffeineAmount))
            .subscribe(onNext: { inputs in
                let (migraine, caffeineAmount) = inputs
                let c = migraine.treatment(medicine: .Caffeine)
                c.amount = caffeineAmount
                c.save()
            })
            .disposed(by: disposeBag)
        save.withLatestFrom(Observable.combineLatest(migraine, ibuprofenAmount))
            .subscribe(onNext: { inputs in
                let (migraine, ibuprofenAmount) = inputs
                let i = migraine.treatment(medicine: .Ibuprofen)
                i.amount = ibuprofenAmount
                i.save()
            })
            .disposed(by: disposeBag)
        migraineId.accept(-1)
    }
}
