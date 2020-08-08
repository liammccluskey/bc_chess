//
//  ProgressUI.swift
//  BCPtest
//
//  Created by Guest on 8/5/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class ScoreLabel: UIView {
    
    var title: UILabel! = UILabel()
    var scoreTitle: String!
    var value: UILabel = UILabel()
    var scoreValue: String!
    
    init(puzzledUser: PuzzledUser, attemptType: Int, isBlindfold: Bool) {
        super.init(frame: .zero)
        self.setLabelValues(forPuzzledUser: puzzledUser, forAttemptType: attemptType, isBlindfold: isBlindfold)
        self.configLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabelValues(forPuzzledUser puzzledUser: PuzzledUser, forAttemptType attemptType: Int, isBlindfold: Bool) {
        let visibility = isBlindfold ? "(Blindfold)" : "(Regular)"
        switch attemptType {
        case 0: // rated puzzles
            scoreTitle = "Rating  " + visibility
            scoreValue = String(isBlindfold ? puzzledUser.puzzleB_Elo : puzzledUser.puzzle_Elo)
            break
        case 1: // rush 3min attempt
            scoreTitle = "HIGH SCORE  " + visibility
            scoreValue = String(isBlindfold ? puzzledUser.rush3B_HS: puzzledUser.rush3_HS)
            break
        case 2: // rush 5min attempt
            scoreTitle = "HIGH SCORE  " + visibility
            scoreValue = String(isBlindfold ? puzzledUser.rush5B_HS : puzzledUser.rush5_HS)
            break
        default: break
        }
        title.text = scoreTitle
        value.text = scoreValue
    }
    
    func configLabels() {
        value.translatesAutoresizingMaskIntoConstraints = false
        value.text = scoreValue
        value.textColor = .white
        value.textAlignment = .center
        value.font = UIFont(name: "AvenirNext-Bold", size: 25)
        value.backgroundColor = .clear

        // label for score title
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

        //self.layer.borderWidth = 3.5
        //self.layer.borderColor = CommonUI().blackColorLight.cgColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}

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
        self.font = UIFont(name: fontString, size: 22)
        self.backgroundColor = .clear
        return self
    }
    
    func configCellLabel(text: String, textColor: UIColor) -> UILabel{
        self.text = text
        self.textColor = textColor
        self.textAlignment = .center
        self.font = UIFont(name: fontString, size: 17)
        self.backgroundColor = .clear
        return self
    }
}
