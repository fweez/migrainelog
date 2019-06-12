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
    var setStarted = PublishSubject<Date>()
    var saveStarted = PublishSubject<Void>()
    var setEnded = PublishSubject<Date>()
    var saveEnded = PublishSubject<Void>()
    var increaseRizatriptan = PublishSubject<Void>()
    var increaseCaffeine = PublishSubject<Void>()
    var increaseIbuprofen = PublishSubject<Void>()
    var increaseSeverity = PublishSubject<Void>()
    var setCause = PublishSubject<String>()
    var saveCause = PublishSubject<Void>()
    var setNotes = PublishSubject<String>()
    var saveNotes = PublishSubject<Void>()
    
    // outputs
    var title: Driver<String>
    var rawStart: Observable<Date>
    var formattedStart: Driver<String>
    var rawEnd: Driver<Date?>
    var formattedEnd: Driver<String>
    var formattedRizatriptanAmount: Driver<String>
    var formattedCaffeineAmount: Driver<String>
    var formattedIbuprofenAmount: Driver<String>
    var formattedSeverity: Driver<String>
    var cause: Driver<String>
    var notes: Driver<String>
    
    private var migraine: Observable<Migraine>
    private var rizatriptanId: BehaviorRelay<Int> = BehaviorRelay(value: -1)
    private var rizatriptan: Observable<Treatment>
    private var caffeineId: BehaviorRelay<Int> = BehaviorRelay(value: -1)
    private var caffeine: Observable<Treatment>
    private var ibuprofenId: BehaviorRelay<Int> = BehaviorRelay(value: -1)
    private var ibuprofen: Observable<Treatment>
    
    private let disposeBag = DisposeBag()
    
    init() {
        migraine = migraineId
            .flatMap { id -> Observable<Migraine> in
                let m = Migraine.fetch(migraineId: id) ?? Migraine()
                return Observable.of(m)
            }
            .share(replay: 1, scope: .forever)
        
        migraine
            .map { $0.treatment(medicine: .Rizatriptan).id }
            .asDriver(onErrorJustReturn: -1)
            .drive(rizatriptanId)
            .disposed(by: disposeBag)
        migraine
            .map { $0.treatment(medicine: .Caffeine).id }
            .asDriver(onErrorJustReturn: -1)
            .drive(caffeineId)
            .disposed(by: disposeBag)
        migraine
            .map { $0.treatment(medicine: .Ibuprofen).id }
            .asDriver(onErrorJustReturn: -1)
            .drive(ibuprofenId)
            .disposed(by: disposeBag)
        
        let fetchTreatment = { (id: Int) -> Observable<Treatment> in
            let t = Treatment.fetch(id: id) ?? Treatment(migraineId: -1, medicine: .Rizatriptan, amount: 0)
            return Observable.of(t)
        }
        
        rizatriptan = rizatriptanId
            .flatMap(fetchTreatment)
            .share(replay: 1, scope: .forever)
        caffeine = caffeineId
            .flatMap(fetchTreatment)
            .share(replay: 1, scope: .forever)
        ibuprofen = ibuprofenId
            .flatMap(fetchTreatment)
            .share(replay: 1, scope: .forever)
        title = migraine
            .map { "Migraine on \($0.formattedStartDate)" }
            .asDriver(onErrorJustReturn: "Error")
        rawStart = migraine
            .map { $0.startDate }
            .debug("Raw start", trimOutput: false)
        
        formattedStart = migraine
            .map { "Started: \($0.formattedStartDate)" }
            .asDriver(onErrorJustReturn: "Error")
        rawEnd = migraine
            .map { $0.endDate }
            .asDriver(onErrorJustReturn: Date.distantFuture)
        formattedEnd = migraine
            .map { "Ended: \($0.formattedEndDate)" }
            .asDriver(onErrorJustReturn: "Error")
        formattedRizatriptanAmount = rizatriptan
            .map { "Rizatriptan: \($0.amountDescription)" }
            .asDriver(onErrorJustReturn: "Error")
        formattedCaffeineAmount = caffeine
            .map { "Caffeine: \($0.amountDescription)" }
            .asDriver(onErrorJustReturn: "Error")
        formattedIbuprofenAmount = ibuprofen
            .map { "Ibuprofen: \($0.amountDescription)" }
            .asDriver(onErrorJustReturn: "Error")
        formattedSeverity = migraine
            .map { $0.formattedSeverity }
            .asDriver(onErrorJustReturn: "Error")
        cause = migraine
            .map { $0.cause }
            .asDriver(onErrorJustReturn: "")
        notes = migraine
            .map { $0.notes }
            .asDriver(onErrorJustReturn: "")
        
        let startInfo = Observable.combineLatest(setStarted, migraine)
        saveStarted.withLatestFrom(startInfo)
            .debug("Combiner, before filter", trimOutput: false)
            .filter { t in
                let (newDate, migraine) = t
                return newDate != migraine.startDate
            }
            .map { (t: (Date, Migraine)) -> Int in
                let (newDate, migraine) = t
                return migraine.updateStart(newDate)
            }
            .asDriver(onErrorJustReturn: -1)
            .debug("Combiner, driver mode, set start", trimOutput: false)
            .drive(migraineId)
            .disposed(by: disposeBag)
        
        let endInfo = Observable.combineLatest(setEnded, migraine)
        saveEnded.withLatestFrom(endInfo)
            .filter { t in
                let (newDate, migraine) = t
                return newDate != migraine.startDate
            }
            .map { (t: (Date, Migraine)) -> Int in
                let (newDate, migraine) = t
                return migraine.updateEnd(newDate)
            }
            .asDriver(onErrorJustReturn: -1)
            .drive(migraineId)
            .disposed(by: disposeBag)
        
        increaseRizatriptan.withLatestFrom(rizatriptan)
            .map { $0.incrementAmount() }
            .asDriver(onErrorJustReturn: -1)
            .drive(rizatriptanId)
            .disposed(by: disposeBag)
        increaseCaffeine.withLatestFrom(caffeine)
            .map { $0.incrementAmount() }
            .asDriver(onErrorJustReturn: -1)
            .drive(caffeineId)
            .disposed(by: disposeBag)
        increaseIbuprofen.withLatestFrom(ibuprofen)
            .map { $0.incrementAmount() }
            .asDriver(onErrorJustReturn: -1)
            .drive(ibuprofenId)
            .disposed(by: disposeBag)
        
        increaseSeverity.withLatestFrom(migraine)
            .map { $0.increaseSeverity() }
            .asDriver(onErrorJustReturn: -1)
            .drive(migraineId)
            .disposed(by: disposeBag)
        
        let causeInfo = Observable.combineLatest(setCause, migraine)
        saveCause.withLatestFrom(causeInfo)
            .map { (t: (String, Migraine)) -> Int in
                let (newCause, migraine) = t
                return migraine.updateCause(newCause)
            }
            .asDriver(onErrorJustReturn: -1)
            .drive(migraineId)
            .disposed(by: disposeBag)
        
        let notesInfo = Observable.combineLatest(setNotes, migraine)
        saveNotes.withLatestFrom(notesInfo)
            .map { (t: (String, Migraine)) -> Int in
                let (newNotes, migraine) = t
                return migraine.updateNotes(newNotes)
            }
            .asDriver(onErrorJustReturn: -1)
            .drive(migraineId)
            .disposed(by: disposeBag)
    }
}
