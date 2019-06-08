//
//  SecondViewController.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    @IBOutlet weak var monthMigrainesLabel: UILabel!
    @IBOutlet weak var monthRztLabel: UILabel!
    @IBOutlet weak var monthIbuprofenLabel: UILabel!
    @IBOutlet weak var quarterMigrainesLabel: UILabel!
    @IBOutlet weak var quarterRztLabel: UILabel!
    @IBOutlet weak var quarterIbuprofenLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.monthMigrainesLabel.text = "\(Migraine.monthMigraineCount) migraines"
        self.monthRztLabel.text = "\(Treatment.monthRztCount) doses of rizatriptan"
        self.monthIbuprofenLabel.text = "\(Treatment.monthIbuprofenCount) doses of ibuprofen"
        
        self.quarterMigrainesLabel.text = "\(Migraine.quarterMigraineCount) migraines"
        self.quarterRztLabel.text = "\(Treatment.quarterRztCount) doses of rizatriptan"
        self.quarterIbuprofenLabel.text = "\(Treatment.quarterIbuprofenCount) doses of ibuprofen"
    }
    
    @IBAction func tappedExport(_ sender: UIButton) {
        let report = Migraine.generateReport()
        let activityVC = UIActivityViewController(activityItems: [report], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.postToFacebook, .postToTwitter, .openInIBooks]
        self.present(activityVC, animated: true, completion: nil)
    }
}

