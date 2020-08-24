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
    
    init(boardTheme: ColorTheme = ColorTheme(rawValue: 0)!, buttonTheme: ColorTheme = ColorTheme(rawValue: 0)!) {
        self.boardTheme = boardTheme
        self.dsColor = boardTheme.darkSquareColor
        self.lsColor = boardTheme.lightSquareColor
        self.dButtonColor = buttonTheme.darkSquareColor
        self.lButtonColor = buttonTheme.lightSquareColor
    }

    // MARK: - Solution Section
    
    func configRatingLabel() -> UILabel {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = UIFont(name: fontString, size: 19)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
    func configDeltaLabel() -> UILabel {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = CommonUI().redColor
        l.font = UIFont(name: fontString, size: 18)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
    func configSolutionLabel() -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont(name: fontStringLight, size: 19)
        label.numberOfLines = 0
        return label
    }
    
    func configSolutionText(solutionMoves: [WBMove], onIndex: Int) -> String {
        var solutionText = ""
        for i in 0..<onIndex {
            let move = solutionMoves[i]
            let response = move.response_san == "complete" ? "Complete" : move.response_san
            let readableMove = "        \(i + 1).  \(move.answer_san)  \(response)"
            solutionText = solutionText + readableMove
            if i%2 != 0 { solutionText = solutionText + "\n"}
        }
        return solutionText
    }
    
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
    
    func configureButton(title: String, imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName)?.withRenderingMode(.alwaysOriginal).withTintColor(.lightGray), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontStringLight, size: 16)
        button.backgroundColor = CommonUI().tabBarColor
        button.layer.borderWidth = 1
        button.layer.borderColor = CommonUI().tabBarColor.cgColor
        button.setTitleColor(.white, for: .normal)
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
        label.backgroundColor = playerToMove == "white" ? .lightGray : .black //CommonUI().blackColorLight
        label.textColor = playerToMove == "white" ? .black : .lightGray
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 19)
        label.text = "\(playerToMove.uppercased()) TO MOVE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: - Misc.
    
    func configurePiecesShownSegment(selectedSegmentIndex: Int = 0) -> UISegmentedControl {
        let sc = UISegmentedControl(items: ["Hide Pieces", "Show Pieces"])
        let font = UIFont(name: fontString, size: 15)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.lightGray], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.lightGray], for: .normal)
        sc.tintColor = .lightGray
        sc.selectedSegmentIndex = selectedSegmentIndex
        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = .black
        sc.layer.cornerRadius = 20
        sc.clipsToBounds = true
        return sc

    }
}

class ButtonWithImage: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 3, left: (bounds.width - 50), bottom: 3, right: 20)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!)
            imageView?.contentMode = .scaleAspectFit
        }
    }
}

extension UILabel {
    
    func setDelta(delta: Int32) {
        let sign = delta >= 0 ? "+" : ""
        let color = delta >= 0 ? CommonUI().greenColor : CommonUI().redColor
        self.text = "\(sign) \(delta)"
        self.textColor = color
    }
    
    func setRating(forPuzzledUser user: PuzzledUser, isBlindfold: Bool) {
        let rating = isBlindfold ? user.puzzleB_Elo : user.puzzle_Elo
        self.text = "ELO:  \(rating)"
    }
    
    func setPuzzleRating(forPuzzleReference pRef: PuzzleReference, isBlindfold: Bool) {
        let rating = isBlindfold ? pRef.eloBlindfold : pRef.eloRegular
        self.text = "DIFFICULTY:  \(rating)"
        self.textColor = .lightGray
        self.font = UIFont(name: fontStringLight, size: 18)
    }
}

