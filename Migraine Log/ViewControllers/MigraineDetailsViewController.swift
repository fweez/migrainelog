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

class DetailsViewController: UIViewController {
    var viewModel: MigraineDetailsViewModel = MigraineDetailsViewModel()
    
    var scrollView = UIScrollView()
    var stackView = UIStackView()
    
    var migraineTitle = UILabel()
    var startedButton = UIButton()
    var endedButton = UIButton()
    
    var medicinesTitle = UILabel()
    var rztButton = UIButton()
    var cafButton = UIButton()
    var ibuButton = UIButton()
    var severityTitle = UILabel()
    var severityButton = UIButton()
    var causeTitle = UILabel()
    var causeView = UITextField()
    var notesTitle = UILabel()
    var notesView = UITextView()
    var saveButton: UIButton = UIButton()
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var pickerView: UIDatePicker!
    
    var shouldDismissOnScroll = true
    
    override func loadView() {
        view = UIView()
        
        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        prepareForAutolayout(scrollView)
        view.addSubview(scrollView)
        
        prepareForAutolayout(stackView)
        
        func addViewToVStack(_ view: UIView) {
            prepareForAutolayout(view)
            stackView.addArrangedSubview(view)
        }
        
        func addLabelWithTextToVStack(_ label: UILabel, _ text: String) {
            label.text = text
            addViewToVStack(label)
        }
        
        func addButtonWithTextToVStack(_ button: UIButton, _ title: String) {
            button.setTitle(title, for: .normal)
            addViewToVStack(button)
        }
        
        addLabelWithTextToVStack(migraineTitle, "Add/Edit Migraine (PH)")
        addButtonWithTextToVStack(startedButton, "Started <placeholder date>")
        addButtonWithTextToVStack(endedButton, "Ended <placeholder date>")
        
        addLabelWithTextToVStack(medicinesTitle, "Medicines")
        [(rztButton, "Rizatriptan: 99 mg"),
         (cafButton, "Caffeine: 420 mg"),
         (ibuButton, "Ibuprofen: 666 mg")]
            .forEach(addButtonWithTextToVStack)
        
        addLabelWithTextToVStack(severityTitle, "Severity")
        addButtonWithTextToVStack(severityButton, "X X X X")
        
        addLabelWithTextToVStack(causeTitle, "Cause")
        causeView = UITextField()
        prepareForAutolayout(causeView)
        stackView.addArrangedSubview(causeView)
        
        addLabelWithTextToVStack(notesTitle, "Notes")
        notesView = UITextView()
        prepareForAutolayout(notesView)
        stackView.addArrangedSubview(notesView)
        
        addButtonWithTextToVStack(saveButton, "Save")
        
        scrollView.addSubview(stackView)
        
        bindData()
    }
    
    func bindData() {
        viewModel.title
            .drive(self.migraineTitle.rx.text)
            .disposed(by: disposeBag)
        let buttonBindings: [(Driver<String>, UIButton)] = [
            (viewModel.formattedStart, startedButton),
            (viewModel.formattedEnd, endedButton),
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
        viewModel.formattedSeverity
            .drive(severityButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        viewModel.cause
            .bind(to: causeView.rx.text)
            .disposed(by: disposeBag)
        viewModel.notes
            .bind(to: notesView.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraints()
        applyStyling()
    }
    
    fileprivate func setUpConstraints() {
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        notesView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func applyStyling() {
        stackView.axis = .vertical
        stackViewStyle(stackView)
        baseBackgroundStyle(view)
        baseNavbarStyle(navigationController?.navigationBar)
        [migraineTitle, medicinesTitle, severityTitle, causeTitle, notesTitle].forEach(largeLabelStyle)
        [startedButton, endedButton, rztButton, cafButton, ibuButton, severityButton].forEach(baseButtonStyle)
        [causeView, notesView].forEach(textAreaStyle)
        saveButtonStyle(saveButton)
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
