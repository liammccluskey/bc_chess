//
//  PuzzleRushUI.swift
//  BCPtest
//
//  Created by Guest on 8/8/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class PuzzleRushUI {
    
    func configNumCorrectLabel() -> UILabel {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = UIFont(name: fontString, size: 18)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
    func configTimeRemainingLabel() -> UILabel {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = UIFont(name: fontString, size: 18)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
    func configCorrectnessLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

extension UILabel {
    
    func setNumCorrect(numCorrect: Int) {
        self.text = "SCORE:  \(numCorrect)"
    }
    
    func setTimeRemaining(secondsLeft: Int) {
        let seconds = secondsLeft % 60
        let sec = seconds < 10 ? "0\(seconds)" : String(seconds)
        let min = String(secondsLeft/60)
        self.text = "TIME:  \(min):\(sec)"
    }
    
    func setCorrectness(isCorrect: Bool) {
        self.backgroundColor = isCorrect ? CommonUI().greenColor : CommonUI().redColor
        self.text = isCorrect ? "CORRECT" : "INCORRECT"
    }
    
}

class IncorrectMarksView: UIView {
    
    var numIncorrect = 0 {
        /*
        didSet {
            switch numIncorrect {
            case 0: m1.isHidden = true; m2.isHidden = true; m3.isHidden = true; layoutIfNeeded(); break
            case 1: m1.isHidden = false; layoutIfNeeded(); break
            case 2: m2.isHidden = false; layoutIfNeeded(); break
            case 3: m3.isHidden = false; layoutIfNeeded(); break
            default: break
            }
        }
        */
        didSet {
            switch numIncorrect {
            case 0: m1.alpha = 0; m2.alpha = 0; m3.alpha = 0; break
            case 1: m1.alpha = 1; break
            case 2: m2.alpha = 1; break
            case 3: m3.alpha = 1; break
            default: break
            }
        }
    }
    let m1: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.image = UIImage(systemName: "xmark.square.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(CommonUI().redColor)
        iv.contentMode = .scaleAspectFill
        //iv.clipsToBounds = true
        return iv
    }()
    let m2: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.image = UIImage(systemName: "xmark.square.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(CommonUI().redColor)
        iv.contentMode = .scaleAspectFill
        //iv.clipsToBounds = true
        return iv
    }()
    let m3: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.image = UIImage(systemName: "xmark.square.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(CommonUI().redColor)
        iv.contentMode = .scaleAspectFill
        //iv.clipsToBounds = true
        return iv
    }()
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        configView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configView() {
        let hstack = CommonUI().configureHStackView(arrangedSubViews: [m1, m2, m3])
        hstack.distribution = .fillEqually
        hstack.contentMode = .scaleAspectFill
        
        hstack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hstack)
        
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        hstack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        hstack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        hstack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
    }
}
