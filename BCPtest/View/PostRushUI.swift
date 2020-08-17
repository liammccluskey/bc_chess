//
//  PostRushUI.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/16/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class RankingLabel: UIView {
    
    var title: UILabel! = UILabel()
    var value: UILabel = UILabel()
    
    init(rankTitle: String, rankValue: Int) {
        super.init(frame: .zero)
        self.configLabels()
        self.setLabelValues(rankTitle: rankTitle, rankValue: rankValue)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabelValues(rankTitle: String, rankValue: Int) {
        value.text = "# \(rankValue)"
        title.text = rankTitle
    }
    
    func configLabels() {
        value.translatesAutoresizingMaskIntoConstraints = false
        value.textColor = .white
        value.textAlignment = .center
        value.font = UIFont(name: "AvenirNext-Bold", size: 18)
        value.backgroundColor = .clear

        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .lightGray
        title.textAlignment = .center
        title.font = UIFont(name: fontString, size: 12)
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
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}
