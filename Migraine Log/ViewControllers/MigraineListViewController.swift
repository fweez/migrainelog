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
import FontAwesome_swift

class MigraineListViewController: UIViewController, UITableViewDelegate {
    var migraineList: UITableView = UITableView()
    var detailVC: DetailsViewController = DetailsViewController(nibName: nil, bundle: nil)
    
    private var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
    var viewModel = MigraineListViewModel()
    var disposeBag = DisposeBag()
    
    
    
    override func loadView() {
        view = migraineList
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recent Migraines"
        let normalTabIcon = UIImage.fontAwesomeIcon(name: .bolt, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
        tabBarItem = UITabBarItem(title: "Recent", image: normalTabIcon, tag:0)
        applyStyling()
        bindData()
    }
    
    fileprivate func applyStyling() {
        tallNavbarStyle(navigationController?.navigationBar)
        baseTabbarstyle(tabBarController?.tabBar)
        baseBackgroundStyle(view)
    }
    
    private func bindData() {
        viewModel.ids
            .bind(to: migraineList.rx.items) { (tableView: UITableView, tvRowIdx: Int, migraineId: Int) in
                return MigraineCell(migraineId: migraineId)
            }
            .disposed(by: disposeBag)
        migraineList.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.migraineList.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        migraineList.rx.modelDeleted(Int.self)
            .asDriver(onErrorJustReturn: -1)
            .drive(viewModel.deleteMigraine)
            .disposed(by: disposeBag)
        addButton.rx.tap
            .bind(to: viewModel.makeNew)
            .disposed(by: disposeBag)
        
        func pushNavToMigraineId(_ migraineId: Int) -> Void {
            let vc = self.detailVC
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let selectedCell = migraineList.rx.modelSelected(Int.self)
            .share()
        let createdNew = addButton.rx.tap.withLatestFrom(viewModel.newMigraine)
        
        [selectedCell, createdNew].forEach { observable in
            observable
                .asDriver(onErrorJustReturn: -1)
                .drive(self.detailVC.viewModel.migraineId)
                .disposed(by: disposeBag)
            observable
                .subscribe(onNext: pushNavToMigraineId)
                .disposed(by: disposeBag)
        }
        
        detailVC.viewModel.updated
            .drive(viewModel.updated)
            .disposed(by: disposeBag)
    }
}
