//
//  CommonUI.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

public let fontString = "Avenir-Medium"
public let fontStringLight = "Avenir-Book"

class CommonUI {
    
    let csBlue = UIColor(red: 20/255, green: 92/255, blue: 158/255, alpha: 1)
    //let csRed = UIColor(red: 7/255, green: 160/255, blue: 195/255, alpha: 1) // good light blue
    //
    //let csRed = UIColor(red: 197/255, green: 51/255, blue: 51/255, alpha: 1)
    let csRed = UIColor.white//UIColor(red: 13/255, green: 137/255, blue: 78/255, alpha: 1) // good green colr

    let purpleColor = UIColor(red: 90/255, green: 53/255, blue: 148/255, alpha: 1)
    let blueColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
    let purpleColorLight = UIColor(red: 165/255, green: 135/255, blue: 212/255, alpha: 1)
    let blueColorLight = UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1)
    let blueColorDark = UIColor(red: 14/255, green: 77/255, blue: 146/255, alpha: 1)
    let lightGray = UIColor(red: 134/255, green: 136/255, blue: 138/255, alpha: 1)
    let tanColorLight = UIColor(red: 226/255, green: 210/255, blue: 178/255, alpha: 1)
    let tanColorDark = UIColor(red: 180/255, green: 132/255, blue: 100/255, alpha: 1)
    let redColor = UIColor(red: 167/255, green: 11/255, blue: 11/255, alpha: 1)
    let greenColor = UIColor(red: 3/255, green: 127/255, blue: 68/255, alpha: 1)
    //let blackColor = UIColor(red: 39/255, green: 41/255, blue: 43/255, alpha: 1)
    
    let goldColor = UIColor(red: 201/255, green: 176/255, blue: 55/255, alpha: 1)
    let silverColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
    let bronzeColor = UIColor(red: 173/255, green: 138/255, blue: 86/255, alpha: 1)
    
    let blackColorLight = UIColor(red: 33/255, green: 34/255, blue: 37/255, alpha: 1)
    //let blackColor = UIColor(red: 19/255, green: 21/255, blue: 23/255, alpha: 1)
    let blackColor = UIColor.black
    let whiteColor = UIColor(red: 237/255, green: 227/255, blue: 214/255, alpha: 1)
    
    // MARK: - User Data
    
    func dsColor() -> UIColor {
        guard let theme = UserDataManager().getBoardColor() else {
            let theme = ColorTheme(rawValue: 2)
            return theme!.darkSquareColor
        }
        return theme.darkSquareColor
    }
    func lsColor() -> UIColor {
        guard let theme = UserDataManager().getBoardColor() else {
            let theme = ColorTheme(rawValue: 2)
            return theme!.lightSquareColor
        }
        return theme.lightSquareColor
    }
 
    
    func configSpacer() -> UILabel {
    /*
        Really shouldn't use this hackish method
    */
        let label = UILabel()
        label.text = "       "
        label.textColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 12)
        label.backgroundColor = .clear
        return label
    }
    
    func configureHeaderLabel(title: String, backC: UIColor = .clear, textC: UIColor = CommonUI().whiteColor) -> UILabel {
    /*
         Creates header label
    */
        let label = UILabel()
        label.numberOfLines = 0
        label.text = title
        label.textColor = textC
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 18)
        label.backgroundColor = backC
        return label
    }
    
    func configureSubheaderLabel(title: String) -> UILabel {
    /*
        Creates subheader label to be placed in a stack view
    */
        let label = UILabel()
        label.text = "->  " + title
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: fontString, size: 16)
        label.backgroundColor = .clear
        return label
    }
    
    func configureStackView(arrangedSubViews: [UIView]) -> UIStackView {
    /*
         Creates vertical stack view
    */
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func configureHStackView(arrangedSubViews: [UIView]) -> UIStackView {
        /*
         Creates horizontal stack view
         */
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

}

// testing this below

enum ColorTheme: Int, CustomStringConvertible, CaseIterable {
    case darkBlue
    case gray
    case green
    case tan
    case purple
    case lightBlue
    var darkSquareColor: UIColor {
        switch self {
        case .darkBlue: return UIColor(red: 14/255, green: 77/255, blue: 146/255, alpha: 1)
        case .gray: return UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)
        case .green: return UIColor(red: 118/255, green: 150/255, blue: 86/255, alpha: 1)
        case .tan: return UIColor(red: 181/255, green: 136/255, blue: 99/255, alpha: 1)
        case .purple: return UIColor(red: 90/255, green: 53/255, blue: 148/255, alpha: 1)
        case .lightBlue: return UIColor(red: 140/255, green: 162/255, blue: 173/255, alpha: 1)
        }
    }
    var lightSquareColor: UIColor {
        switch self {
            case .darkBlue: return UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1)
            case .gray: return UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1)
            case .green: return UIColor(red: 238/255, green: 238/255, blue: 210/255, alpha: 1)
            case .tan: return UIColor(red: 240/255, green: 217/255, blue: 181/255, alpha: 1)
            case .purple: return UIColor(red: 155/255, green: 125/255, blue: 202/255, alpha: 1)
            case .lightBlue: return UIColor(red: 216/255, green: 221/255, blue: 219/255, alpha: 1)
        }
    }
    var description: String {
        switch self {
        case .darkBlue: return "Dark Blue"
        case .gray: return "Gray"
        case .green: return "Green"
        case .tan: return "Tan"
        case .purple: return "Purple"
        case .lightBlue: return "Light Blue"
        }
    }
}

//public var pieceStyle = "lichess"
public var pieceStyle = UserDataManager().getPieceStyle()
enum PieceStyleTheme: Int, CaseIterable, CustomStringConvertible {
    case lichess
    case simple
    case fancy
    case minimal
    var fileExtension: String {
        switch self {
        case .lichess: return "lichess_"
        case .simple: return "simple_"
        case .fancy: return "fancy_"
        case .minimal: return "minimal_"
        }
    }
    var description: String {
        switch self {
        case .lichess: return "Standard"
        case .simple: return "Fancy"
        case .fancy: return "Default"
        case .minimal: return "Minimal"
        }
    }
    var imageSet: UIImage {
        switch self {
        case .lichess: return UIImage(named: "lichess_set") ?? UIImage()
        case .simple: return UIImage(named: "simple_set") ?? UIImage()
        case .fancy: return UIImage(named: "fancy_set") ?? UIImage()
        case .minimal: return UIImage(named: "minimal_set") ?? UIImage()
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func setTitle(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }
    
    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else { return }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : messageFont],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        
        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }
    
    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
}

extension Date {

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
}

