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
    var ids: BehaviorSubject<[Int]>
    var makeNew = PublishSubject<Void>()
    var newMigraine: Observable<Int>
    var deleteMigraine = PublishSubject<Int>()
    
    private let disposeBag = DisposeBag()

    init() {
        ids = BehaviorSubject(value: Migraine.allIds())
        
        newMigraine = makeNew
            .map {
                Migraine.new()
            }
            .debug()
        
        makeNew
            .map(Migraine.allIds)
            .asDriver(onErrorJustReturn: [])
            .drive(ids)
            .disposed(by: disposeBag)
        
        deleteMigraine
            .map { id in
                Migraine.deleteId(id)
                return Migraine.allIds()
            }
            .asDriver(onErrorJustReturn: [])
            .drive(ids)
            .disposed(by: disposeBag)
    }
}
