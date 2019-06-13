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
    var updated: Driver<Int>
    
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
            .observeOn(DBScheduler)
            .flatMap { id -> Observable<Migraine> in
                let m = Migraine.fetch(migraineId: id) ?? Migraine()
                return Observable.of(m)
            }
            .share(replay: 1, scope: .forever)
        
        migraine
            .observeOn(DBScheduler)
            .map { $0.treatment(medicine: .Rizatriptan).id }
            .asDriver(onErrorJustReturn: -1)
            .drive(rizatriptanId)
            .disposed(by: disposeBag)
        migraine
            .observeOn(DBScheduler)
            .map { $0.treatment(medicine: .Caffeine).id }
            .asDriver(onErrorJustReturn: -1)
            .drive(caffeineId)
            .disposed(by: disposeBag)
        migraine
            .observeOn(DBScheduler)
            .map { $0.treatment(medicine: .Ibuprofen).id }
            .asDriver(onErrorJustReturn: -1)
            .drive(ibuprofenId)
            .disposed(by: disposeBag)
        
        let fetchTreatment = { (id: Int) -> Observable<Treatment> in
            let t = Treatment.fetch(id: id) ?? Treatment(migraineId: -1, medicine: .Rizatriptan, amount: 0)
            return Observable.of(t)
        }
        
        rizatriptan = rizatriptanId
            .observeOn(DBScheduler)
            .flatMap(fetchTreatment)
            .share(replay: 1, scope: .forever)
        caffeine = caffeineId
            .observeOn(DBScheduler)
            .flatMap(fetchTreatment)
            .share(replay: 1, scope: .forever)
        ibuprofen = ibuprofenId
            .observeOn(DBScheduler)
            .flatMap(fetchTreatment)
            .share(replay: 1, scope: .forever)
        
        rawStart = migraine
            .map { $0.startDate }
        title = rawStart
            .map { "Migraine on \(CommonDateFormatter.string(from: $0))" }
            .asDriver(onErrorJustReturn: "Error")
        formattedStart = rawStart
            .map { "Started: \(CommonDateFormatter.string(from: $0))" }
            .asDriver(onErrorJustReturn: "Error")
        rawEnd = migraine
            .map { $0.endDate }
            .asDriver(onErrorJustReturn: Date.distantFuture)
        formattedEnd = rawEnd
            .map { date in
                guard let date = date else { return "Set end time" }
                return "Ended: \(CommonDateFormatter.string(from: date))"
            }
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
            .map { severityString($0.severity) }
            .asDriver(onErrorJustReturn: "Error")
        cause = migraine
            .map { $0.cause }
            .asDriver(onErrorJustReturn: "")
        notes = migraine
            .map { $0.notes }
            .asDriver(onErrorJustReturn: "")
        updated = migraineId
            .asDriver(onErrorJustReturn: -1)
        
        let startInfo = Observable.combineLatest(setStarted, migraine)
        saveStarted.withLatestFrom(startInfo)
            .filter { t in
                let (newDate, migraine) = t
                return newDate != migraine.startDate
            }
            .map { (t: (Date, Migraine)) -> Int in
                let (newDate, migraine) = t
                return migraine.updateStart(newDate)
            }
            .asDriver(onErrorJustReturn: -1)
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
            .observeOn(DBScheduler)
            .map { $0.incrementAmount() }
            .asDriver(onErrorJustReturn: -1)
            .drive(rizatriptanId)
            .disposed(by: disposeBag)
        increaseCaffeine.withLatestFrom(caffeine)
            .observeOn(DBScheduler)
            .map { $0.incrementAmount() }
            .asDriver(onErrorJustReturn: -1)
            .drive(caffeineId)
            .disposed(by: disposeBag)
        increaseIbuprofen.withLatestFrom(ibuprofen)
            .observeOn(DBScheduler)
            .map { $0.incrementAmount() }
            .asDriver(onErrorJustReturn: -1)
            .drive(ibuprofenId)
            .disposed(by: disposeBag)
        
        increaseSeverity.withLatestFrom(migraine)
            .observeOn(DBScheduler)
            .map { $0.increaseSeverity() }
            .asDriver(onErrorJustReturn: -1)
            .drive(migraineId)
            .disposed(by: disposeBag)
        
        let causeInfo = Observable.combineLatest(setCause, migraine)
        saveCause.withLatestFrom(causeInfo)
            .observeOn(DBScheduler)
            .map { (t: (String, Migraine)) -> Int in
                let (newCause, migraine) = t
                return migraine.updateCause(newCause)
            }
            .asDriver(onErrorJustReturn: -1)
            .drive(migraineId)
            .disposed(by: disposeBag)
        
        let notesInfo = Observable.combineLatest(setNotes, migraine)
        saveNotes.withLatestFrom(notesInfo)
            .observeOn(DBScheduler)
            .map { (t: (String, Migraine)) -> Int in
                let (newNotes, migraine) = t
                return migraine.updateNotes(newNotes)
            }
            .asDriver(onErrorJustReturn: -1)
            .drive(migraineId)
            .disposed(by: disposeBag)
    }
}
