//
//  SecondViewController.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 7/19/18.
//  Copyright © 2018 rmf. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class StatBlock {
    let viewModel = StatsBlockViewModel()
    
    let title = UILabel()
    let migrainesLabel = UILabel()
    let rztLabel = UILabel()
    let ibuprofenLabel = UILabel()
    
    private let disposeBag = DisposeBag()

    func addTo(stackView: UIStackView, withRange range: StatsTimeRange) {
        let addLabelToVStack = addLabelWithTextToVStackFn(stackView: stackView)
        addLabelToVStack(title, "Last Placeholder days")
        addLabelToVStack(migrainesLabel, "Placeholder migraines")
        addLabelToVStack(rztLabel, "Placeholder doses of rizatriptan")
        addLabelToVStack(ibuprofenLabel, "Placeholder doses of ibuprofen")
    }
    
    func bindData() {
        viewModel.title
            .drive(title.rx.text)
            .disposed(by: disposeBag)
        viewModel.migraineCount
            .drive(migrainesLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.rizatriptanCount
            .drive(rztLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.ibuprofenCount
            .drive(ibuprofenLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func applyStyling() {
        labelStyle(title, for: .title1)
        [migrainesLabel, rztLabel, ibuprofenLabel].forEach { labelStyle($0, for: .body) }
    }
}

class StatsViewController: UIViewController {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let monthStatBlock = StatBlock()
    let quarterStatBlock = StatBlock()
    let exportButton = UIButton()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func loadView() {
        view = UIView()
        
        prepareForAutolayout(scrollView)
        view.addSubview(scrollView)
        prepareForAutolayout(stackView)
        scrollView.addSubview(stackView)
        
        monthStatBlock.addTo(stackView: stackView, withRange: .month)
        quarterStatBlock.addTo(stackView: stackView, withRange: .quarter)
        let addButtonToVStack = addButtonWithTextToVStackFn(stackView: stackView)
        addButtonToVStack(exportButton, "Export")
        
        bindData()
    }
    
    func bindData() {
        monthStatBlock.bindData()
        quarterStatBlock.bindData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        
        setupConstraints()
        applyStyling()
        
        monthStatBlock.viewModel.range.onNext(.month)
        quarterStatBlock.viewModel.range.onNext(.quarter)
    }
    
    func setupConstraints() {
        fullSizeEmbed(scrollView, within: view)
        commonInsetEmbed(stackView, within: scrollView)
    }
    
    func applyStyling() {
        tallNavbarStyle(navigationController?.navigationBar)
        baseTabbarstyle(tabBarController?.tabBar)
        baseBackgroundStyle(view)
        stackViewStyle(stackView)
        monthStatBlock.applyStyling()
        quarterStatBlock.applyStyling()
        baseButtonStyle(exportButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fire an update, probably
    }
    
    @IBAction func tappedExport(_ sender: UIButton) {
        let report = Migraine.generateReport()
        let activityVC = UIActivityViewController(activityItems: [report], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.postToFacebook, .postToTwitter, .openInIBooks]
        self.present(activityVC, animated: true, completion: nil)
    }
}

