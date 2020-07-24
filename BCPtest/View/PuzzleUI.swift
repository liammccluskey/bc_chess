//
//  PuzzleUI.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class PuzzleUI {
    
    let fontString = "PingFangTC-Semibold"
    let fontStringLight = "PingFangTC-Medium"
    
    // MARK: - Solution Section
    
    func configureAnswerView(move: WBMove, matePly: Int) -> UIView {
        let answer = UILabel()
        answer.translatesAutoresizingMaskIntoConstraints = false
        answer.backgroundColor = .clear
        answer.textColor = .white
        answer.font = UIFont(name: fontStringLight, size: 23)
        answer.layer.cornerRadius = 5
        answer.layer.borderColor = CommonUI().blueColorDark.cgColor
        answer.layer.borderWidth = 3
        answer.clipsToBounds = true
        let response = move.response_san == "complete" ? "Checkmate" : move.response_san
        let readableMove = " #\(matePly):    \(move.answer_san) -> \(response)"
        answer.text = readableMove
        
        let correct = UIImageView()
        correct.translatesAutoresizingMaskIntoConstraints = false
        correct.contentMode = .scaleAspectFit
        correct.image = #imageLiteral(resourceName: "checkmark").withRenderingMode(.alwaysOriginal)
        
        let container = UIView()
        container.addSubview(answer)
        container.addSubview(correct)
        container.heightAnchor.constraint(equalTo: correct.heightAnchor).isActive = true
        correct.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        correct.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        answer.heightAnchor.constraint(equalTo: correct.heightAnchor).isActive = true
        answer.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        answer.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        answer.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -55).isActive = true
        
        return container
    }
    
    // MARK: - Buttons
    
    func configureButton(title: String, titleColor: UIColor, borderColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontStringLight, size: 18)
        button.backgroundColor = .clear
        button.layer.borderWidth = 2
        //button.layer.borderColor = borderColor.cgColor
        //button.layer.cornerRadius = 5
        //button.clipsToBounds = true
        button.setTitleColor(titleColor, for: .normal)
        return button
    }
    
    func configureButtonHStack(arrangedSubViews: [UIView]) -> UIStackView {
        /*
         Creates horizontal stack view for bottom button bar
         */
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Labels
    
    func configureToMoveLabel(playerToMove: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = CommonUI().blueColorLight
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 18)
        label.text = "\(playerToMove.uppercased()) TO MOVE"
        return label
    }
    
    // MARK: - Misc.
    
    func configurePiecesShownSegCont() -> UISegmentedControl {
        let sc = UISegmentedControl(items: ["HIDE PIECES", "SHOW PIECES"])
        sc.isEnabled = true
        sc.selectedSegmentIndex = 0
        sc.layer.cornerRadius = 5
        sc.backgroundColor = .black
        sc.tintColor = CommonUI().blueColorLight
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc

    }
    
    
    
    
}
