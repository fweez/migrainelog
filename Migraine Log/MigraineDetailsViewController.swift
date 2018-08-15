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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(ignored:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)) , name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeSize(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
        if self.migraine.date == Migraine.newMigraineDate {
            self.titleLabel.text = "Add Migraine"
        } else {
            self.titleLabel.text = "Edit Migraine"
        }
        
        self.notesView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
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
        
        if self.migraine.date != Migraine.newMigraineDate {
            self.migraine.save()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}

// MARK: UI Updates
extension MigraineDetailsViewController {
    func whenUpdated() {
        if self.migraine.date == Migraine.newMigraineDate {
            self.whenButton.setTitle("Set time", for: .normal)
        } else {
            self.whenButton.setTitle(self.migraine.formattedDate, for: .normal)
        }
    }
    
    func lengthUpdated() {
        if self.migraine.length == 0 {
            self.lengthButton.setTitle("Set length", for: .normal)
        } else {
            self.lengthButton.setTitle(self.migraine.formattedLength, for: .normal)
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
        if self.pickerView.isHidden { return }
        
        switch self.pickerView.datePickerMode {
        case .countDownTimer: self.lengthValueUpdated()
        case .dateAndTime: self.whenValueUpdated()
        default: break
        }
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
        if let userinfo = notification.userInfo, let value = userinfo[UIKeyboardFrameEndUserInfoKey] {
            let kbSize = (value as! NSValue).cgRectValue.size
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
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
        if self.migraine.date == Migraine.newMigraineDate {
            self.pickerView.date = Date()
        } else {
            self.pickerView.date = self.migraine.date
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
    
    @IBAction func tappedLength(_ sender: Any) {
        self.pickerView.datePickerMode = .countDownTimer
        self.pickerView.countDownDuration = self.migraine.length
        self.pickerView.minuteInterval = 15
        self.pickerView.isHidden = false
        self.pickerView.removeTarget(nil, action: nil, for: .valueChanged)
        self.pickerView.addTarget(self, action: #selector(lengthValueUpdated), for: .valueChanged)
        self.shouldDismissOnScroll = true
    }
    
    @IBAction func tappedDone(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Picker handling
extension MigraineDetailsViewController {
    @objc func whenValueUpdated() {
        self.migraine.date = self.pickerView.date
        self.whenUpdated()
    }
    
    @objc func lengthValueUpdated() {
        //self.migraine.length = self.pickerView.countDownDuration
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
