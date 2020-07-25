//
//  CommonUI.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class CommonUI {
    
    let fontString = "PingFangTC-Semibold"
    let fontStringLight = "PingFangTC-Medium"
    
    
    let purpleColor = UIColor(red: 90/255, green: 53/255, blue: 148/255, alpha: 1)
    let blueColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
    
    let purpleColorLight = UIColor(red: 165/255, green: 135/255, blue: 212/255, alpha: 1)
    
    
    let blueColorLight = UIColor(red: 141/255, green: 192/255, blue: 235/255, alpha: 1)
    let blueColorDark = UIColor(red: 0/255, green: 112/255, blue: 204/255, alpha: 1)
    
    let tanColorLight = UIColor(red: 236/255, green: 220/255, blue: 188/255, alpha: 1)
    let tanColorDark = UIColor(red: 180/255, green: 132/255, blue: 100/255, alpha: 1)
    
    
    let redColor = UIColor(red: 167/255, green: 11/255, blue: 11/255, alpha: 1)
    let greenColor = UIColor(red: 3/255, green: 127/255, blue: 68/255, alpha: 1)
    let blackColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
    
    func configureDividerLabel() -> UILabel {
    /*
        Creates blue divider
    */
        let label = UILabel()
        label.text = "should extend width of the screen"
        label.textColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 1)
        label.backgroundColor = blueColor
        return label
    }
    
    func configureHeaderLabel(title: String) -> UILabel {
    /*
         Creates header label
    */
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 18)
        label.backgroundColor = .clear
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
        //stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4 // edit: = 9
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
