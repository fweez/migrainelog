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
    var ids: Observable<[Int]> = Observable.of(Migraine.allIds())
}
