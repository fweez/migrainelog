//
//  MigraineListViewModel.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 5/29/19.
//  Copyright © 2019 rmf. All rights reserved.
//

import Foundation
import RxSwift

struct MigraineListViewModel {
    // OUTPUTS
    var ids: BehaviorSubject<[Int]>
    var makeNew = PublishSubject<Void>()
    var newMigraine: Observable<Int>
    var deleteMigraine = PublishSubject<Int>()
    
    //INPUTS
    var updated = PublishSubject<Int>()
    
    private let disposeBag = DisposeBag()

    init() {
        ids = BehaviorSubject(value: Migraine.allIds())
        
        newMigraine = makeNew
            .subscribeOn(DBScheduler)
            .map(Migraine.new)
            .share(replay: 1, scope: .forever)
        makeNew
            .observeOn(DBScheduler)
            .map(Migraine.allIds)
            .asDriver(onErrorJustReturn: [])
            .drive(ids)
            .disposed(by: disposeBag)
        
        deleteMigraine
            .observeOn(DBScheduler)
            .map { id in
                Migraine.deleteId(id)
                return Migraine.allIds()
            }
            .asDriver(onErrorJustReturn: [])
            .drive(ids)
            .disposed(by: disposeBag)
        
        updated
            .observeOn(DBScheduler)
            .map { _ in Migraine.allIds() }
            .asDriver(onErrorJustReturn: [])
            .drive(ids)
            .disposed(by: disposeBag)
    }
}
