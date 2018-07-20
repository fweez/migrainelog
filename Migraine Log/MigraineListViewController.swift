//
//  FirstViewController.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit

class MigraineListViewController: UIViewController {
    
}

// MARK: Button targets
extension MigraineListViewController {
    
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
        case .Migraines: return Migraine.count(connection: DB.shared.connection)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = MigraineListSections(rawValue: indexPath.section) else {
            return tableView.dequeueReusableCell(withIdentifier: "crash app", for: indexPath)
        }
        switch section {
        case .NewEntry: return tableView.dequeueReusableCell(withIdentifier: "newEntryCell", for: indexPath)
        case .Migraines: return tableView.dequeueReusableCell(withIdentifier: "migraineCell", for: indexPath)
        }
        
    }
}

extension MigraineListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = MigraineListSections(rawValue: indexPath.section) else {
            assertionFailure()
            return
        }
        let migraine: Migraine
        switch section {
        case .NewEntry: migraine = Migraine()
        case .Migraines: migraine = Migraine() // fixme
        }
        
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "migraineDetailVC") as? MigraineDetailsViewController else {
            assertionFailure()
            return
        }
        
        detailVC.migraine = migraine
        self.present(detailVC, animated: true, completion: nil)
    }
}
