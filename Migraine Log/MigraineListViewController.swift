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
    
    var viewModel = MigraineListViewModel()
    var disposeBag = DisposeBag()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func loadView() {
        view = migraineList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.items
            .bind(to: migraineList.rx.items(cellIdentifier: "migraineCell", cellType: MigraineCell.self)) { (row, element, cell) in
                cell.migraine = element
            }
            .disposed(by: disposeBag)
        migraineList.rx
            .itemSelected
            .subscribe { genericEvent in
                _ = genericEvent.map { [unowned self] indexPath in
                    self.migraineList.deselectRow(at: indexPath, animated: true)
                }
            }
            .disposed(by: disposeBag)
        migraineList.rx
            .modelSelected(Migraine.self)
            .subscribe { migraineEvent in
                _ = migraineEvent.map({ [unowned self] migraine in
                    guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "migraineDetailVC") as? MigraineDetailsViewController else {
                        assertionFailure()
                        return
                    }
                    detailVC.migraine = migraine
                    self.present(detailVC, animated: true, completion: nil)
                })
            }
            .disposed(by: disposeBag)
    }
}

enum MigraineListSections: Int {
    case NewEntry
    case Migraines
}

/*
extension MigraineListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = MigraineListSections(rawValue: section) else {
            return -1
        }
        switch section {
        case .NewEntry: return 1
        case .Migraines: return self.ids.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = MigraineListSections(rawValue: indexPath.section) else {
            return tableView.dequeueReusableCell(withIdentifier: "crash app", for: indexPath)
        }
        switch section {
        case .NewEntry: return self.newEntryCell(tableView, cellForRowAt: indexPath)
        case .Migraines: return migraineCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    fileprivate func newEntryCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "newEntryCell", for: indexPath)
    }
    
    fileprivate func migraineCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "migraineCell", for: indexPath) as? MigraineCell else {
            return tableView.dequeueReusableCell(withIdentifier: "crash app", for: indexPath)
        }
        cell.migraine = self.getMigraine(row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return MigraineListSections(rawValue: indexPath.section) == .Migraines
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        assert(editingStyle == .delete)
        guard let migraine = self.getMigraine(row: indexPath.row) else { return }
        migraine.delete()
        self.refreshMigraineList()
    }
}

extension MigraineListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = MigraineListSections(rawValue: indexPath.section) else {
            assertionFailure()
            return
        }

        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "migraineDetailVC") as? MigraineDetailsViewController else {
            assertionFailure()
            return
        }
        
        switch section {
        case .NewEntry:
            let migraine = Migraine()
            migraine.save()
            detailVC.migraine = migraine
        case .Migraines:
            detailVC.migraine = self.getMigraine(row: indexPath.row)!
        }
        
        
        self.present(detailVC, animated: true, completion: nil)
    }
}
*/
