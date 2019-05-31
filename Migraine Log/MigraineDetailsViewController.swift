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
    @IBOutlet weak var whenButton: UIButton!
    @IBOutlet weak var rztAmountLabel: UILabel!
    @IBOutlet weak var caffeineAmountLabel: UILabel!
    @IBOutlet weak var ibuprofenAmountLabel: UILabel!
    @IBOutlet weak var severityButton: UIButton!
    @IBOutlet weak var lengthButton: UIButton!
    @IBOutlet weak var causeView: UITextField!
    @IBOutlet weak var notesView: UITextView!
    
    @IBOutlet weak var pickerView: UIDatePicker!
    
    var shouldDismissOnScroll = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(ignored:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)) , name: UIWindow.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeSize(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        
        if self.migraine.startDate == Migraine.newMigraineDate {
            self.titleLabel.text = "Add Migraine"
        } else {
            self.titleLabel.text = "Edit Migraine"
        }
        
        self.notesView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.whenUpdated()
        self.rztUpdated()
        self.caffeineUpdated()
        self.ibuprofenUpdated()
        self.severityUpdated()
        self.lengthUpdated()
        self.causeView.text = self.migraine.cause
        self.notesView.text = self.migraine.notes
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.migraine.startDate != Migraine.newMigraineDate {
            self.migraine.save()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}

// MARK: UI Updates
extension MigraineDetailsViewController {
    func whenUpdated() {
        if self.migraine.startDate == Migraine.newMigraineDate {
            self.whenButton.setTitle("Set time", for: .normal)
        } else {
            self.whenButton.setTitle(self.migraine.formattedStartDate, for: .normal)
        }
    }
    
    func lengthUpdated() {
        if self.migraine.length == 0 {
            self.lengthButton.setTitle("Set end time", for: .normal)
        } else {
            self.lengthButton.setTitle(self.migraine.formattedEndDate, for: .normal)
        }
    }
    
    func rztUpdated() {
        let t = self.migraine.treatment(medicine: .Rizatriptan)
        self.rztAmountLabel.text = t.amountDescription
    }
    
    func caffeineUpdated() {
        let t = self.migraine.treatment(medicine: .Caffeine)
        self.caffeineAmountLabel.text = t.amountDescription
    }
    
    func ibuprofenUpdated() {
        let t = self.migraine.treatment(medicine: .Ibuprofen)
        self.ibuprofenAmountLabel.text = t.amountDescription
    }
    
    func severityUpdated() {
        self.severityButton.setTitle(self.migraine.formattedSeverity, for: .normal)
    }
    
    func dismissAllInputViews() {
        if self.shouldDismissOnScroll {
            self.notesView.resignFirstResponder()
            self.causeView.resignFirstResponder()
            self.dismissPicker()
        }
    }
    
    func dismissPicker() {
        self.pickerView.isHidden = true
    }
    
    @IBAction func tappedScrollview(_ sender: Any) {
        self.dismissAllInputViews()
    }
}

// MARK: Keyboard show/hide stuff
extension MigraineDetailsViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        self.updateScrollRect(fromNotification: notification)
    }
    
    @objc func keyboardWillChangeSize(notification: NSNotification) {
        self.updateScrollRect(fromNotification: notification)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        self.shouldDismissOnScroll = true
    }
    
    @objc func keyboardWillHide(ignored: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func updateScrollRect(fromNotification notification: NSNotification) {
        if let userinfo = notification.userInfo, let value = userinfo[UIResponder.keyboardFrameEndUserInfoKey] {
            let kbSize = (value as! NSValue).cgRectValue.size
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            self.scrollView.scrollRectToVisible(self.notesView.frame, animated: true)
            self.shouldDismissOnScroll = false
        }
    }
    
}

// MARK: Button handling
extension MigraineDetailsViewController {
    @IBAction func tappedWhen(_ sender: Any) {
        self.pickerView.datePickerMode = .dateAndTime
        self.pickerView.minuteInterval = 15
        if self.migraine.startDate == Migraine.newMigraineDate {
            self.pickerView.date = Date()
        } else {
            self.pickerView.date = self.migraine.startDate
        }
        self.pickerView.maximumDate = Date(timeIntervalSinceNow: TimeInterval(60 * self.pickerView.minuteInterval))
        self.pickerView.isHidden = false
        self.pickerView.removeTarget(nil, action: nil, for: .valueChanged)
        self.pickerView.addTarget(self, action: #selector(whenValueUpdated), for: .valueChanged)
        self.shouldDismissOnScroll = true
    }
    
    @IBAction func tappedRzt(_ sender: Any) {
        let t = self.migraine.treatment(medicine: .Rizatriptan)
        t.amount += 1
        t.save()
        self.rztUpdated()
    }
    
    @IBAction func tappedCaffeine(_ sender: Any) {
        let t = self.migraine.treatment(medicine: .Caffeine)
        t.amount += 1
        t.save()
        self.caffeineUpdated()
    }
    
    @IBAction func tappedIbuprofen(_ sender: Any) {
        let t = self.migraine.treatment(medicine: .Ibuprofen)
        t.amount += 1
        t.save()
        self.ibuprofenUpdated()
    }
    
    @IBAction func tappedSeverity(_ sender: Any) {
        self.migraine.severity += 1
        self.severityUpdated()
    }
    
    @IBAction func tappedEndDate(_ sender: Any) {
        self.pickerView.datePickerMode = .dateAndTime
        self.pickerView.minuteInterval = 15
        self.pickerView.date = self.migraine.endDate ?? Date()
        self.pickerView.maximumDate = nil
        self.pickerView.isHidden = false
        self.pickerView.removeTarget(nil, action: nil, for: .valueChanged)
        self.pickerView.addTarget(self, action: #selector(endDateUpdated), for: .valueChanged)
        self.shouldDismissOnScroll = true
    }
    
    @IBAction func tappedDone(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Picker handling
extension MigraineDetailsViewController {
    @objc func whenValueUpdated() {
        self.migraine.startDate = self.pickerView.date
        self.whenUpdated()
    }
    
    @objc func endDateUpdated() {
        self.migraine.endDate = self.pickerView.date
        self.lengthUpdated()
    }
}

extension MigraineDetailsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.dismissPicker()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.migraine.cause = textField.text ?? ""
    }
}

extension MigraineDetailsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.dismissPicker()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.migraine.notes = textView.text
    }
}

extension MigraineDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dismissAllInputViews()
    }
}
