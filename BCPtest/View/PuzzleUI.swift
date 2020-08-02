//
//  PuzzleUI.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class PuzzleUI {
    
    let boardTheme: ColorTheme!
    let dsColor: UIColor!
    let lsColor: UIColor!
    let dButtonColor: UIColor!
    let lButtonColor: UIColor!
    
    init(boardTheme: ColorTheme, buttonTheme: ColorTheme) {
        self.boardTheme = boardTheme
        self.dsColor = boardTheme.darkSquareColor
        self.lsColor = boardTheme.lightSquareColor
        self.dButtonColor = buttonTheme.darkSquareColor
        self.lButtonColor = buttonTheme.lightSquareColor
    }

    // MARK: - Solution Section
    
    func configureAnswerView(move: WBMove, matePly: Int) -> UIView {
        let answer = UILabel()
        answer.translatesAutoresizingMaskIntoConstraints = false
        answer.backgroundColor = .clear
        answer.textColor = .white
        answer.font = UIFont(name: fontStringLight, size: 20)
        answer.layer.cornerRadius = 5
        answer.layer.borderColor = UIColor.clear.cgColor
        answer.layer.borderWidth = 3
        answer.clipsToBounds = true
        let response = move.response_san == "complete" ? "Checkmate" : move.response_san
        let spaceString = String(repeating: " ", count: 14 - move.answer_san.count)
        let readableMove = "    #\(matePly):    \(move.answer_san)" + spaceString + response
        answer.text = readableMove
        
        let correct = UIImageView()
        correct.translatesAutoresizingMaskIntoConstraints = false
        correct.contentMode = .scaleAspectFit
        correct.image = #imageLiteral(resourceName: "check").withRenderingMode(.alwaysOriginal)
        
        let container = UIView()
        container.addSubview(answer)
        container.addSubview(correct)
        container.heightAnchor.constraint(equalTo: correct.heightAnchor).isActive = true
        correct.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        correct.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -10).isActive = true
        answer.heightAnchor.constraint(equalTo: correct.heightAnchor).isActive = true
        answer.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        answer.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 10).isActive = true
        answer.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -55).isActive = true
        
        return container
    }
    
    // MARK: - Buttons
    
    func configureButton(title: String, titleColor: UIColor, borderColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontStringLight, size: 16)
        button.backgroundColor = .black
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.setTitleColor(.lightGray, for: .normal)
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
        label.backgroundColor = dButtonColor
        label.textColor = playerToMove == "white" ? .white : .black
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 19)
        label.text = "\(playerToMove.uppercased()) TO MOVE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: - Misc.
    
    func configurePiecesShownSegCont() -> UISegmentedControl {
        let sc = UISegmentedControl(items: ["HIDE PIECES", "SHOW PIECES"])
        sc.isEnabled = true
        let font = UIFont(name: fontString, size: 13)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.black], for: .normal)
        sc.tintColor = .white
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = dButtonColor
        sc.selectedSegmentTintColor = lButtonColor
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc

    }
    
    
    
    
}
