//
//  MigraineCell.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/20/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit

class MigraineCell: UITableViewCell {
    var migraine: Migraine! {
        didSet {
            self.textLabel?.text = self.migraine.formattedStartDate
            self.detailTextLabel?.text = "\(self.migraine.formattedLength)  \(self.migraine.formattedSeverity)"
        }
    }
    
    
}
