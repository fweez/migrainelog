//
//  MigraineDetailsViewController.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

func prepareForAutolayout(_ view: UIView) { view.translatesAutoresizingMaskIntoConstraints = false }
func baseBackgroundStyle(_ view: UIView) { view.backgroundColor = UIColor.white }
func baseLabelStyle(_ label: UILabel) { label.textColor = UIColor.black }

func baseButtonStyle(_ button: UIButton) {
    button.setTitleColor(UIColor.black, for: .normal)
    button.contentHorizontalAlignment = .left
}

class DetailsViewController: UIViewController {
    var viewModel: MigraineDetailsViewModel = MigraineDetailsViewModel()
    
    var scrollView: UIScrollView = UIScrollView()
    var stackView: UIStackView = UIStackView()
    var migraineTitle: UILabel = UILabel()
    var startedButton: UIButton = UIButton()
    var rztButton: UIButton = UIButton()
    var cafButton: UIButton = UIButton()
    var ibuButton: UIButton = UIButton()
    var severityButton: UIButton = UIButton()
    var endedButton: UIButton = UIButton()
    var causeView: UITextField = UITextField()
    var notesView: UITextView = UITextView()
    var saveButton: UIButton = UIButton()
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var pickerView: UIDatePicker!
    
    var shouldDismissOnScroll = true
    
   override func loadView() {
        view = UIView()
        view.addSubview(stackView)
        
        func addLabelWithTextToVStack(_ label: UILabel, _ text: String) {
            label.text = text
            prepareForAutolayout(label)
            baseLabelStyle(label)
            stackView.addArrangedSubview(label)
        }
        
        addLabelWithTextToVStack(migraineTitle, "Add/Edit Migraine (PH)")
        print("SET TITLE TO PLACEHOLDER")
        func addButtonWithTextToVStack(_ button: UIButton, _ title: String) {
            button.setTitle(title, for: .normal)
            prepareForAutolayout(button)
            baseButtonStyle(button)
            stackView.addArrangedSubview(button)
        }
        
        addButtonWithTextToVStack(startedButton, "Started <placeholder date>")
        addLabelWithTextToVStack(UILabel(), "Medicines")
        
        [(rztButton, "Rizatriptan: 99 mg"),
         (cafButton, "Caffeine: 420 mg"),
         (ibuButton, "Ibuprofen: 666 mg")]
            .forEach(addButtonWithTextToVStack)
        addButtonWithTextToVStack(severityButton, "Severity: X X X X")
        addButtonWithTextToVStack(endedButton, "Ended <placeholder date>")
        
        addLabelWithTextToVStack(UILabel(), "Cause")
        causeView = UITextField()
        prepareForAutolayout(causeView)
        stackView.addArrangedSubview(causeView)
        
        addLabelWithTextToVStack(UILabel(), "Notes")
        notesView = UITextView()
        prepareForAutolayout(notesView)
        stackView.addArrangedSubview(notesView)
        
        addButtonWithTextToVStack(saveButton, "Save")
        
        bindData()
    }
    
    func bindData() {
        viewModel.title
            .drive(self.migraineTitle.rx.text)
            .disposed(by: disposeBag)
        let buttonBindings: [(Driver<String>, UIButton)] = [
            (viewModel.formattedStart, startedButton),
            (viewModel.formattedRizatriptanAmount, rztButton),
            (viewModel.formattedCaffeineAmount, cafButton),
            (viewModel.formattedIbuprofenAmount, ibuButton),
            (viewModel.formattedEnd, endedButton)]
        buttonBindings
            .forEach( { binding in
                let (driver, button) = binding
                driver
                    .drive(button.rx.title(for: .normal))
                    .disposed(by: disposeBag)
            })
        
        viewModel.cause
            .bind(to: causeView.rx.text)
            .disposed(by: disposeBag)
        viewModel.notes
            .bind(to: notesView.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseBackgroundStyle(view)
        prepareForAutolayout(stackView)
        stackView.axis = .vertical
        stackView.backgroundColor = UIColor.red
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(ignored:)), name: UIWindow.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)) , name: UIWindow.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeSize(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: Keyboard show/hide stuff
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
//        if let userinfo = notification.userInfo, let value = userinfo[UIResponder.keyboardFrameEndUserInfoKey] {
//            let kbSize = (value as! NSValue).cgRectValue.size
//            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
//            self.scrollView.scrollRectToVisible(self.notesView.frame, animated: true)
//            self.shouldDismissOnScroll = false
//        }
    }
    
}
    
    /*
        
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
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.migraine.startDate != Migraine.newMigraineDate {
            self.migraine.save()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
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
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.dismissPicker()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.migraine.cause = textField.text ?? ""
    }
}

extension MigraineDetailsViewController: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.dismissPicker()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.migraine.notes = textView.text
    }
}

extension MigraineDetailsViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dismissAllInputViews()
    }
}
*/
