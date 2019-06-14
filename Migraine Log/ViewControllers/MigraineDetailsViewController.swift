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
    var startedPickerTitle = UILabel()
    var startedPicker = UIDatePicker()
    var startedPickerSave = UIButton()
    var endedButton = UIButton()
    var endedPickerTitle = UILabel()
    var endedPicker = UIDatePicker()
    var endedPickerSave = UIButton()
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
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var pickerView: UIDatePicker!
    
    var shouldDismissOnScroll = true
    
    override func loadView() {
        view = UIView()
        
        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        
        prepareForAutolayout(scrollView)
        view.addSubview(scrollView)
        
        prepareForAutolayout(stackView)
        
        let addViewToVStack = addViewToVStackFn(stackView: stackView)
        let addLabelWithTextToVStack = addLabelWithTextToVStackFn(stackView: stackView)
        let addButtonWithTextToVStack = addButtonWithTextToVStackFn(stackView: stackView)
        
        addLabelWithTextToVStack(migraineTitle, "Add/Edit Migraine (PH)")
        addButtonWithTextToVStack(startedButton, "Started <placeholder date>")
        addLabelWithTextToVStack(startedPickerTitle, "Set start time:")
        startedPicker.datePickerMode = .dateAndTime
        startedPicker.setDate(Date.distantPast, animated: false)
        addViewToVStack(startedPicker)
        addButtonWithTextToVStack(startedPickerSave, "Save")
        startedPicker.isHidden = true // show these when we hit the buttons
        startedPickerTitle.isHidden = true
        startedPickerSave.isHidden = true
        addButtonWithTextToVStack(endedButton, "Ended <placeholder date>")
        addLabelWithTextToVStack(endedPickerTitle, "Set end time:")
        endedPicker.datePickerMode = .dateAndTime
        endedPicker.setDate(Date.distantFuture, animated: false)
        addViewToVStack(endedPicker)
        addButtonWithTextToVStack(endedPickerSave, "Save")
        endedPicker.isHidden = true
        endedPickerTitle.isHidden = true
        endedPickerSave.isHidden = true
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
        
        scrollView.addSubview(stackView)
        
        bindData()
    }
    
    func bindData() {
        // INPUTS
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
        viewModel.rawStart
            .asDriver(onErrorJustReturn: Date.distantFuture)
            .drive(startedPicker.rx.date)
            .disposed(by: disposeBag)
        viewModel.rawEnd
            .map { $0 ?? Date() }
            .drive(endedPicker.rx.date)
            .disposed(by: disposeBag)
        viewModel.formattedSeverity
            .drive(severityButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        viewModel.cause
            .drive(causeView.rx.text)
            .disposed(by: disposeBag)
        viewModel.notes
            .drive(notesView.rx.text)
            .disposed(by: disposeBag)
        
        // OUTPUTS
        startedPicker.rx.value
            .asDriver()
            .drive(viewModel.setStarted)
            .disposed(by: disposeBag)
        startedPickerSave.rx.tap
            .asDriver()
            .drive(viewModel.saveStarted)
            .disposed(by: disposeBag)
        endedPicker.rx.value
            .asDriver()
            .drive(viewModel.setEnded)
            .disposed(by: disposeBag)
        endedPickerSave.rx.tap
            .asDriver()
            .drive(viewModel.saveEnded)
            .disposed(by: disposeBag)
        rztButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(viewModel.increaseRizatriptan)
            .disposed(by: disposeBag)
        cafButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(viewModel.increaseCaffeine)
            .disposed(by: disposeBag)
        ibuButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(viewModel.increaseIbuprofen)
            .disposed(by: disposeBag)
        severityButton.rx.tap
            .asDriver()
            .drive(viewModel.increaseSeverity)
            .disposed(by: disposeBag)
        causeView.rx.text.changed
            .asDriver(onErrorJustReturn: "")
            .map { $0 ?? "" }
            .drive(viewModel.setCause)
            .disposed(by: disposeBag)
        causeView.rx.controlEvent(.editingDidEnd)
            .asDriver()
            .drive(viewModel.saveCause)
            .disposed(by: disposeBag)
        causeView.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { _ in self.shouldDismissOnScroll = false })
            .disposed(by: disposeBag)
        notesView.rx.text.changed
            .asDriver(onErrorJustReturn: "")
            .map { $0 ?? "" }
            .drive(viewModel.setNotes)
            .disposed(by: disposeBag)
        notesView.rx.didEndEditing
            .asDriver()
            .drive(viewModel.saveNotes)
            .disposed(by: disposeBag)
        notesView.rx.didBeginEditing
            .subscribe(onNext: { _ in self.shouldDismissOnScroll = false })
            .disposed(by: disposeBag)
        
        // UI INTERACTIONS
        let pickerAnimationDuration: TimeInterval = 0.35
        func toggleViews(_ views: [UIView]) -> () -> Void {
            return { views.forEach { $0.isHidden.toggle() } }
        }
        
        let animateStartSelectionToggle = {
            UIView.animate(withDuration: pickerAnimationDuration, delay: 0, options: .curveEaseOut, animations: toggleViews([self.startedButton, self.startedPickerTitle, self.startedPicker, self.startedPickerSave]), completion: nil)
        }
        startedButton.rx.tap
            .subscribe(onNext: animateStartSelectionToggle)
            .disposed(by: disposeBag)
        startedPickerSave.rx.tap
            .subscribe(onNext: animateStartSelectionToggle)
            .disposed(by: disposeBag)
        let animateEndSelectionToggle = {
            UIView.animate(withDuration: pickerAnimationDuration, delay: 0, options: .curveEaseOut, animations: toggleViews([self.endedButton, self.endedPickerTitle, self.endedPicker, self.endedPickerSave]), completion: nil)
        }
        endedButton.rx.tap
            .subscribe(onNext: animateEndSelectionToggle)
            .disposed(by: disposeBag)
        endedPickerSave.rx.tap
            .subscribe(onNext: animateEndSelectionToggle)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraints()
        applyStyling()
    }
    
    fileprivate func setUpConstraints() {
        fullSizeEmbed(scrollView, within: view)
        commonInsetEmbed(stackView, within: scrollView)
        notesView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func applyStyling() {
        stackViewStyle(stackView)
        baseBackgroundStyle(view)
        baseNavbarStyle(navigationController?.navigationBar)
        [startedPickerTitle, endedPickerTitle].forEach(bodyLabelStyle)
        [migraineTitle, medicinesTitle, severityTitle, causeTitle, notesTitle].forEach(largeLabelStyle)
        [startedButton, startedPickerSave, endedButton, endedPickerSave, rztButton, cafButton, ibuButton, severityButton].forEach(baseButtonStyle)
        [causeView, notesView].forEach(textAreaStyle)
        [startedPicker, endedPicker].forEach(datePickerStyle)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(ignored:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeSize(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: Keyboard show/hide stuff
    @objc func keyboardWillShow(notification: NSNotification) {
        self.updateScrollRect(fromNotification: notification)
    }
    
    @objc func keyboardWillChangeSize(notification: NSNotification) {
        self.updateScrollRect(fromNotification: notification)
    }
    
    @objc func keyboardWillHide(ignored: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func updateScrollRect(fromNotification notification: NSNotification) {
        if let userinfo = notification.userInfo, let value = userinfo[UIResponder.keyboardFrameEndUserInfoKey] {
            let kbSize = (value as! NSValue).cgRectValue.size
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            self.scrollView.scrollRectToVisible(self.notesView.frame, animated: true)
        }
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
