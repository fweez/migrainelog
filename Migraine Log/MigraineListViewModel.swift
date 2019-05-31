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
    var items = Observable.just(
        Migraine
            .newestIds(location: 0, length: 100)
            .compactMap { Migraine.fetch(migraineId: $0) }
    )
}
