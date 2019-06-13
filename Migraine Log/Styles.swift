//
//  Styles.swift
//  Migraine Log
//
//  Created by Ryan Forsythe on 6/8/19.
//  Copyright © 2019 rmf. All rights reserved.
//

import Foundation
import UIKit

let roundedCornerRadius: CGFloat = 4
let commonInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
let veryDarkGray = UIColor.init(white: 0.1, alpha: 1)
let extremelyDarkGray = UIColor.init(white: 0.05, alpha: 1)
let background = UIColor.black

func prepareForAutolayout(_ view: UIView) { view.translatesAutoresizingMaskIntoConstraints = false }
func baseBackgroundStyle(_ view: UIView?) { view?.backgroundColor = background }

func font(named fontName: String, for textStyle: UIFont.TextStyle, baseSize: CGFloat = UIFont.labelFontSize) -> UIFont {
    guard let customFont = UIFont(name: fontName, size: baseSize) else {
        fatalError("Couldn't load font \(fontName)")
    }
    return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: customFont)
}
func bodyFont(for textStyle: UIFont.TextStyle) -> UIFont {
    let fontName = "LibreFranklin-Regular"
    return font(named: fontName, for: textStyle)
}

func titleFont(for textStyle: UIFont.TextStyle) -> UIFont {
    let fontName = "LibreFranklin-ExtraLight"
    return font(named: fontName, for: textStyle, baseSize: 35)
}

func barButtonFont(for textStyle: UIFont.TextStyle) -> UIFont {
    let fontName = "LibreFranklin-ExtraLight"
    return font(named: fontName, for: textStyle, baseSize: 18)
}

func baseNavbarStyle(_ navbar: UINavigationBar?) {
    navbar?.barTintColor = background
    navbar?.tintColor = UIColor.lightGray
    
    let largeTitleAttribs = [
        NSAttributedString.Key.foregroundColor: UIColor.lightGray,
        NSAttributedString.Key.font: titleFont(for: .largeTitle),
    ]
    navbar?.largeTitleTextAttributes = largeTitleAttribs
    
    let smallTitleAttribs = [
        NSAttributedString.Key.foregroundColor: UIColor.lightGray,
        NSAttributedString.Key.font: barButtonFont(for: .body),
    ]
    navbar?.titleTextAttributes = smallTitleAttribs
}

func tallNavbarStyle(_ navbar: UINavigationBar?) {
    baseNavbarStyle(navbar)
    navbar?.prefersLargeTitles = true
}

func shortNavbarStyle(_ navbar: UINavigationBar?) {
    baseNavbarStyle(navbar)
    navbar?.prefersLargeTitles = false
}

func baseTabbarstyle(_ tabbar: UITabBar?) {
    tabbar?.barTintColor = background
    tabbar?.tintColor = UIColor.lightGray
}

func setHuggingAndCompression(_ view: UIView?) {
    view?.setContentHuggingPriority(.required, for: .vertical)
    view?.setContentCompressionResistancePriority(.required, for: .vertical)
}

func baseLabelStyle(_ label: UILabel?) {
    setHuggingAndCompression(label)
    label?.numberOfLines = 0
    label?.lineBreakMode = .byWordWrapping
    label?.font = bodyFont(for: .body)
    label?.adjustsFontForContentSizeCategory = true
    label?.textColor = UIColor.white
}

func baseButtonStyle(_ button: UIButton?) {
    setHuggingAndCompression(button)
    baseLabelStyle(button?.titleLabel)
    button?.setTitleColor(UIColor.white, for: .normal)
    button?.contentHorizontalAlignment = .left
    button?.titleEdgeInsets = commonInsets
    button?.backgroundColor = veryDarkGray
    button?.layer.cornerRadius = roundedCornerRadius
}

func cellStyle(_ cell: UITableViewCell) {
    baseBackgroundStyle(cell.contentView)
    baseLabelStyle(cell.textLabel)
    baseLabelStyle(cell.detailTextLabel)
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.darkGray
    cell.selectedBackgroundView = backgroundView
}

func bodyLabelStyle(_ label: UILabel?) {
    baseLabelStyle(label)
    baseBackgroundStyle(label)
}

func largeLabelStyle(_ label: UILabel?) {
    baseLabelStyle(label)
    label?.font = titleFont(for: .title1)
}

func stackViewStyle(_ stack: UIStackView?) {
    stack?.spacing = 8
    stack?.distribution = .equalSpacing
}

func textAreaStyle(_ view: UIView) {
    setHuggingAndCompression(view)
    view.backgroundColor = extremelyDarkGray
    view.layer.cornerRadius = roundedCornerRadius
    let textAreaFont = bodyFont(for: .body)
    if let tv = view as? UITextView {
        tv.font = textAreaFont
        tv.textColor = UIColor.white
        tv.textContainerInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 5)
    }
    if let tf = view as? UITextField {
        tf.font = textAreaFont
        tf.textColor = UIColor.white
    }
}

func printAllFonts() {
    for family in UIFont.familyNames.sorted() {
        let names = UIFont.fontNames(forFamilyName: family)
        print("Family: \(family) Font names: \(names)")
    }
}

func datePickerStyle(_ picker: UIDatePicker) {
    picker.backgroundColor = UIColor.white
}
