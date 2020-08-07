//
//  ProgressUI.swift
//  BCPtest
//
//  Created by Guest on 8/5/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

extension UIView {
    
    func configScoreLabel(scoreTitle: String, scoreValue: String) -> UIView{
        // label for score value
        let value = UILabel()
        value.translatesAutoresizingMaskIntoConstraints = false
        value.text = scoreValue
        value.textColor = .white
        value.textAlignment = .center
        value.font = UIFont(name: "AvenirNext-Bold", size: 25)
        value.backgroundColor = .clear
     
        // label for score title
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = scoreTitle
        title.textColor = .lightGray
        title.textAlignment = .center
        title.font = UIFont(name: fontString, size: 14)
        title.backgroundColor = .clear
        
        self.addSubview(value)
        self.addSubview(title)
        
        value.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        value.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        value.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        title.topAnchor.constraint(equalTo: value.bottomAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        self.layer.borderWidth = 4
        self.layer.borderColor = CommonUI().blackColorLight.cgColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = true
        return self
    }
}

extension UILabel {
    func configHeaderLabel(title: String) -> UILabel {
        //self.translatesAutoresizingMaskIntoConstraints = true
        self.text = title
        self.textAlignment = .center
        self.textColor = .white
        self.textAlignment = .center
        self.font = UIFont(name: fontString, size: 25)
        self.backgroundColor = .clear
        return self
    }
    
    func configCellLabel(text: String, textColor: UIColor) -> UILabel{
        self.text = text
        self.textAlignment = .center
        self.textColor = textColor
        self.textAlignment = .center
        self.font = UIFont(name: fontString, size: 18)
        self.backgroundColor = .clear
        return self
    }
}
