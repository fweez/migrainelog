//
//  FirstViewController.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MigraineListViewController: UIViewController, UITableViewDelegate {
    var migraineList: UITableView = UITableView()
    var detailVC: DetailsViewController = DetailsViewController(nibName: nil, bundle: nil)
    
    var viewModel = MigraineListViewModel()
    var disposeBag = DisposeBag()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func loadView() {
        view = migraineList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.ids
            .bind(to: migraineList.rx.items) { (tableView: UITableView, tvRowIdx: Int, migraineId: Int) in
                return MigraineCell(migraineId: migraineId)
            }
            .disposed(by: disposeBag)
        let selection = migraineList.rx.modelSelected(Int.self)
            .share()
        selection
            .subscribe(onNext: { [weak self] migraineId in
                guard let vc = self?.detailVC else { return }
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        selection
            .asDriver(onErrorJustReturn: -1)
            .drive(self.detailVC.viewModel.migraineId)
            .disposed(by: disposeBag)
        migraineList.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.migraineList.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addButton
        addButton.rx.tap
            .subscribe { [weak self] _ in
                guard let vc = self?.detailVC else { return }
                vc.viewModel.migraineId.accept(-1)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
