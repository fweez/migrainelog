//
//  MigraineCell.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/20/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MigraineCell: UITableViewCell {
    var viewModel: MigraineCellViewModel!    
    let disposeBag = DisposeBag()

    convenience init(migraineId: Int) {
        self.init(style: .subtitle, reuseIdentifier: "migraineCell")
        viewModel = MigraineCellViewModel(id: migraineId)
        
        viewModel.title
            .drive(textLabel!.rx.text)
            .disposed(by: disposeBag)
        viewModel.description
            .drive(detailTextLabel!.rx.text)
            .disposed(by: disposeBag)
        
        cellStyle(self)
    }
}
