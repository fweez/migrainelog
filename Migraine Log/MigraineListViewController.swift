//
//  FirstViewController.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit

class MigraineListViewController: UIViewController {
    @IBOutlet weak var migraineList: UITableView!

    var ids: [Int]!
    var migraineCache: [Int: Migraine] = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshMigraineList()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    func getMigraine(row: Int) -> Migraine? {
        let migraineId = self.ids[row]
        if let migraine = self.migraineCache[migraineId] { return migraine }
        let migraine = Migraine.fetch(migraineId: migraineId)
        self.migraineCache[migraineId] = migraine
        return migraine
    }
    
    func refreshMigraineList() {
        self.ids = Migraine.newestIds(location: 0, length: 1000)
        self.migraineList.reloadSections(IndexSet(integer: MigraineListSections.Migraines.rawValue), with: .none)
    }
}

enum MigraineListSections: Int {
    case NewEntry
    case Migraines
}

extension MigraineListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        let migraine: Migraine
        switch section {
        case .NewEntry: migraine = Migraine()
        case .Migraines: migraine = self.getMigraine(row: indexPath.row)!
        }
        
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "migraineDetailVC") as? MigraineDetailsViewController else {
            assertionFailure()
            return
        }
        
        detailVC.migraine = migraine
        self.present(detailVC, animated: true, completion: nil)
    }
}
