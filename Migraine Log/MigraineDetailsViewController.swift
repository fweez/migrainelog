//
//  MigraineDetailsViewController.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit

class MigraineDetailsViewController: UIViewController {
    var migraine: Migraine!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var notesView: UITextView!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(ignored:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)) , name: .UIKeyboardDidShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    var shouldDismissOnScroll = true
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userinfo = notification.userInfo, let value = userinfo[UIKeyboardFrameEndUserInfoKey] {
            let kbSize = (value as! NSValue).cgRectValue.size
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
            self.scrollView.scrollRectToVisible(self.notesView.frame, animated: true)
            self.shouldDismissOnScroll = false
        }
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        self.shouldDismissOnScroll = true
    }
    
    @objc func keyboardWillHide(ignored: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
    }
}

extension MigraineDetailsViewController {
    @IBAction func tappedDone(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MigraineDetailsViewController: UITextViewDelegate {
    
}

extension MigraineDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.shouldDismissOnScroll {
            self.notesView.resignFirstResponder()
        }
    }
}
