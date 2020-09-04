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
        l.numberOfLines = 0
        l.backgroundColor = .clear
        l.textColor = .white
        l.textAlignment = .center
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
        label.textColor = .lightGray
        //label.font = UIFont(name: fontString, size: 25)
        label.numberOfLines = 0
        return label
    }
    
    func configSolutionText(solutionMoves: [WBMove], onIndex: Int, firstMovingPlayer: String="white") -> NSAttributedString {
        let numAttr = [NSAttributedString.Key.font:UIFont(name: fontString, size: 19), NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        let unicodeAttr = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30), NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let txtAttr = [NSAttributedString.Key.font:UIFont(name: fontString, size: 19) , NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let highlightAttr = [NSAttributedString.Key.underlineColor: UIColor.lightGray]
        let attrSolution = NSMutableAttributedString(string: "")
        let buff1 = NSAttributedString(string: " ")
        let buff2 = NSAttributedString(string: "  ")
        
        for i in 0..<onIndex {
            let move = solutionMoves[i]
            var answerP = String(move.answer_san.first!)
            answerP = firstMovingPlayer == "black" ? answerP.capitalized : answerP.lowercased()
            var responseP = String(move.response_san.first!)
            responseP = firstMovingPlayer == "black" ? responseP.lowercased() : responseP.uppercased()
            
            attrSolution.append(NSAttributedString(string: "\(i + 1).", attributes: numAttr))
            attrSolution.append(buff1)
            let attrMove = NSMutableAttributedString(string: "")
            [[move.answer_san, move.answer_uci, answerP],[move.response_san, move.response_uci, responseP]].forEach({
                if $0[0] == "complete" {
                    attrMove.append(NSAttributedString(string: "\u{2713}", attributes: unicodeAttr))
                } else if $0[0][0,1] == $0[1][0,1] { // piece is pawn
                    attrMove.append(NSAttributedString(string: $0[0], attributes: txtAttr))
                } else if let pieceName = PieceName(rawValue: $0[2]) {
                    attrMove.append(NSAttributedString(string: pieceName.unicode, attributes: unicodeAttr))
                    attrMove.append(NSAttributedString(string: String($0[0].dropFirst()), attributes: txtAttr))
                } else {
                    attrMove.append(NSAttributedString(string:$0[0], attributes: txtAttr))
                }
                attrMove.append(buff2)
            })
            attrSolution.append(attrMove)
            attrSolution.append(buff1)
        }
        
        return attrSolution
    }
    
    // MARK: - Buttons
    
    func configBannerButton(title: String, imageName: String, bgColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontStringBold, size: 18)
        button.backgroundColor = bgColor
        button.setTitleColor(.white, for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .medium)
        button.setImage(UIImage(systemName: imageName, withConfiguration: config)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white), for: .normal)
        return button
    }
    
    func configureButton(title: String, imageName: String, weight: UIImage.SymbolWeight = .regular) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: weight, scale: .medium)
        button.setImage(UIImage(systemName: imageName, withConfiguration: config)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(CommonUI().lightGray)
            , for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = CommonUI().tabBarColor
        return button
    }
    
    func configureButtonHStack(arrangedSubViews: [UIView]) -> UIStackView {
        /*
         Creates horizontal stack view for bottom button bar
         */
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Labels
    
    func configureToMoveLabel(playerToMove: String) -> UILabel {
        let label = UILabel()
        label.backgroundColor = playerToMove == "white" ? CommonUI().softWhite : .black //CommonUI().blackColorLight
        label.textColor = playerToMove == "white" ? CommonUI().blackColorLight : CommonUI().softWhite
        label.textAlignment = .center
        label.font = UIFont(name: fontStringBold, size: 18)
        label.text = "\(playerToMove.capitalized) to Move"
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

extension UIButton {
    func tint(withColor color: UIColor) -> UIButton {
        self.imageView?.image = self.imageView?.image?.withTintColor(color)
        self.titleLabel?.textColor = color
        return self
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
        let color = delta >= 0 ? CommonUI().greenCorrect : CommonUI().redIncorrect
        self.text = "\(sign) \(delta)"
        self.textColor = color
    }
    
    func setRating(forPuzzledUser user: PuzzledUser, isBlindfold: Bool) {
        
        self.textAlignment = .left
        let rating = isBlindfold ? user.puzzleB_Elo : user.puzzle_Elo
        let attrSmall = [NSAttributedString.Key.foregroundColor:UIColor.lightGray, NSAttributedString.Key.font:UIFont(name: fontString, size: 15)]
        let attrLarge = [NSAttributedString.Key.foregroundColor:UIColor.lightGray, NSAttributedString.Key.font:UIFont(name: fontString, size: 20)]
        
        let attrText = NSMutableAttributedString(string: "")
        attrText.append(NSAttributedString(string: "Your Rating\n", attributes: attrSmall))
        attrText.append(NSAttributedString(string: String(rating), attributes: attrLarge))
        self.attributedText = attrText
    }
    
    func setPuzzleRating(forPuzzleReference pRef: PuzzleReference, isBlindfold: Bool) {
        self.textAlignment = .right
        let rating = isBlindfold ? pRef.eloBlindfold : pRef.eloRegular
        let attrSmall = [NSAttributedString.Key.foregroundColor:UIColor.lightGray, NSAttributedString.Key.font:UIFont(name: fontString, size: 15)]
        let attrLarge = [NSAttributedString.Key.foregroundColor:UIColor.lightGray, NSAttributedString.Key.font:UIFont(name: fontString, size: 20)]
        
        let attrText = NSMutableAttributedString(string: "")
        attrText.append(NSAttributedString(string: "Difficulty\n", attributes: attrSmall))
        attrText.append(NSAttributedString(string: String(rating), attributes: attrLarge))
        self.attributedText = attrText
    }
}

