//
//  ViewControllerUtility.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 6/13/19.
//  Copyright © 2019 rmf. All rights reserved.
//

import UIKit

func addViewToVStackFn(stackView: UIStackView) -> (_ view: UIView) -> Void {
    return { view in
        prepareForAutolayout(view)
        stackView.addArrangedSubview(view)
    }
}

func addLabelWithTextToVStackFn(stackView: UIStackView) -> (_ label: UILabel, _ title: String) -> Void {
    return { label, text in
        label.text = text
        prepareForAutolayout(label)
        stackView.addArrangedSubview(label)
    }
}

func addButtonWithTextToVStackFn(stackView: UIStackView) -> (_ button: UIButton, _ title: String) -> Void {
    return { button, title in
        button.setTitle(title, for: .normal)
        prepareForAutolayout(button)
        stackView.addArrangedSubview(button)
    }
}

func fullSizeEmbed(_ containedView: UIView, within containerView: UIView) -> Void {
    containedView.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor).isActive = true
    containedView.rightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.rightAnchor).isActive = true
    containedView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor).isActive = true
    containedView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
}

func commonInsetEmbed(_ containedView: UIView, within containerView: UIView) -> Void {
    containedView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
    containedView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
    containedView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
    containedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20).isActive = true
    containedView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -40).isActive = true
}

class TabBarController: UITabBarController {
    override var childForStatusBarStyle: UIViewController? { return self.children.first }
}

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}
