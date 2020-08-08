//
//  ChessBoardController.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/17/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit


class ChessBoardController: UIViewController {
    
    // MARK: - Properties
    var delegate: ChessBoardDelegate?
    var currentPosition: Position?
    var showPiecesInitially: Bool!
    var highlightedStartTag: Int?
    var highlightedEndTag: Int?
    
    var dsColor: UIColor!
    var lsColor: UIColor!
    
    var startSquare: Int?
    var startSquareUCI: String?
    var endSquare: Int?
    var endSquareUCI: String?
    var squareButtons: [UIButton]! // all squares on chessboard -> button.tag in [0,63], pieces are shown
    var squareButtonsBlank: [UIButton]! // all squares, pieces are not shown
    
    var vstack: UIStackView! // vertical stack of horizontal stacks with all chessboard squares
    var vstackBlank: UIStackView! // repeat above but squares don't show pieces
    
    
    // MARK: - Init
    
    init(position: Position, showPiecesInitially: Bool, boardTheme: ColorTheme) {
        self.currentPosition = position
        self.showPiecesInitially = showPiecesInitially
        let theme = UserDataManager().getBoardColor()
        self.dsColor = theme!.darkSquareColor
        self.lsColor = theme!.lightSquareColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setUpAutoLayout()
        
    }
    
    // MARK: - Config
    
    func configureUI() {
        squareButtons = configureSquareButtons() // squares with visible pieces
        squareButtonsBlank = configureSquareButtons() // squares without pieces
        vstack = configureSquaresVStack(piecesAreVisible: true)
        if showPiecesInitially { vstack.isHidden = false }
        else { vstack.isHidden = true}

        configureStartingPosition() // set piece images on squares in vstack
        vstackBlank = configureSquaresVStack(piecesAreVisible: false)
        
        view.addSubview(vstackBlank)
        view.addSubview(vstack)
    }
    
    func setUpAutoLayout() {
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0).isActive = true
        vstack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vstack.heightAnchor.constraint(equalTo: vstack.widthAnchor).isActive = true
        
        vstackBlank.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        vstackBlank.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0).isActive = true
        vstackBlank.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstackBlank.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vstackBlank.heightAnchor.constraint(equalTo: vstack.widthAnchor).isActive = true
    }
    
    func configureSquareButtons() -> [UIButton] {
        var buttons: [UIButton] = []
        for i in 0..<64 {
            let button = UIButton(type: .system)
            button.layer.borderWidth = 4
            button.layer.borderColor = UIColor.clear.cgColor
            button.imageView?.contentMode = .scaleAspectFit
            button.titleLabel?.textColor = .black
            button.tag = i
            button.addTarget(self, action: #selector(squareAction), for: .touchUpInside)
            button.backgroundColor = getSquareColor(squareIndex: i)
            button.setImage(#imageLiteral(resourceName: "clear_square"), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            buttons.append(button)
        }
        return buttons
    }
    
    func configureSquaresVStack(piecesAreVisible: Bool) -> UIStackView {
        var rankHStacks = [UIStackView](repeating: UIStackView(), count: 8)
        for i in 0..<8 {
            let rankButtons = piecesAreVisible ? Array(squareButtons[i*8...(i*8+7)]) : Array(squareButtonsBlank [i*8...(i*8+7)])
            let rankHStack = configureHStack(arrangedSubViews: rankButtons)
            let index = 7 - i // want first rank at bottom of vertical stack
            rankHStacks[index] = rankHStack
        }
        let boardVStack = configureVStack(arrangedSubViews: rankHStacks)
        return boardVStack
    }
    
    func configureStartingPosition() {
        guard let pos = currentPosition else {return}
        clearSelections()
        for i in 0..<64 {
            squareButtons[i].setImage(#imageLiteral(resourceName: "clear_square"), for: .normal)
        }
        let pieces: [[String]] = [pos.P, pos.p, pos.N, pos.n, pos.B, pos.b, pos.R, pos.r, pos.Q, pos.q, pos.K, pos.k]
        for i in 0..<pieces.count {
            for square in pieces[i] {
                let index: Int = squareNameToIndex(square: square)
                DispatchQueue.main.async {
                    self.squareButtons[index].setImage(PieceType(rawValue: i)?.image.withRenderingMode(.alwaysOriginal), for: .normal)
                    //self.squareButtons[index].setImage(pieceStyle.image.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc func squareAction(_ sender: UIButton) {
        let choseStart: Bool = startSquare != nil
        let choseEnd: Bool = endSquare != nil
        if !choseStart {
            startSquare = sender.tag
            startSquareUCI = indexToUCI(index: sender.tag)
        } else if !choseEnd {
            if sender.tag == startSquare {clearSelections(); return}
            print(sender.tag)
            endSquare = sender.tag
            endSquareUCI = indexToUCI(index: sender.tag)
            let moveUCI = "\(startSquareUCI!)\(endSquareUCI!)"
            delegate?.didMakeMove(moveUCI: moveUCI)
        } else if choseStart && choseEnd {
            clearSelections()
            startSquare = sender.tag
            startSquareUCI = indexToUCI(index: sender.tag)
        }
        DispatchQueue.main.async {
            self.squareButtonsBlank[sender.tag].layer.borderColor = UIColor.black.cgColor
            self.squareButtons[sender.tag].layer.borderColor = UIColor.black.cgColor
        }
    }
    
    // MARK: - Helper
    
    func configureVStack(arrangedSubViews: [UIView]) -> UIStackView {
        /*
         Creates vertical stack view of all ranks
         */
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func configureHStack(arrangedSubViews: [UIView]) -> UIStackView {
        /*
         Creates vertical stack view of all ranks
         */
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }
        
    func getSquareColor(squareIndex: Int) -> UIColor {
        if (squareIndex / 8)  % 2 == 0 {
            return squareIndex % 2 == 0 ? dsColor : lsColor
        } else {
            return squareIndex % 2 != 0 ? dsColor : lsColor
        }
    }
    
    func squareNameToIndex(square: String) -> Int {
        let file = square.first!
        let rank = Int(String(square.last!))!
        let files: [Character: Int] = ["a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7]
        return (rank-1)*8 + files[file]!
    }
    
    func indexToUCI(index: Int) -> String {
        let rank = index/8 + 1
        let fileIndex = index % 8
        let files = ["a","b","c","d","e","f","g","h"]
        let file = files[fileIndex]
        return "\(file)\(rank)"
    }
    
    // MARK: - Interface
    
    func setButtonInteraction(isEnabled: Bool) {
        guard let _ = squareButtons else {return}
        squareButtons.forEach{ (button) in
            button.isEnabled = isEnabled
        }
        guard let _ = squareButtonsBlank else {return}
        squareButtonsBlank.forEach{ (button) in
            button.isEnabled = isEnabled
        }
    }
    
    func clearSelections() {
        guard let start = startSquare else {return}
        startSquare = nil
        startSquareUCI = nil
        guard let end = endSquare else {
            squareButtons[start].layer.borderColor = UIColor.clear.cgColor
            squareButtonsBlank[start].layer.borderColor = UIColor.clear.cgColor
            return
        }
        endSquare = nil
        endSquareUCI = nil
        squareButtons[start].layer.borderColor = UIColor.clear.cgColor
        squareButtonsBlank[start].layer.borderColor = UIColor.clear.cgColor
        squareButtons[end].layer.borderColor = UIColor.clear.cgColor
        squareButtonsBlank[end].layer.borderColor = UIColor.clear.cgColor
    }
    
    func showPieces() {
        guard let _ = vstack else {return}
        vstack.isHidden = false
    }
    
    func hidePieces() {
        guard let _ = vstack else {return}
        vstack.isHidden = true
    }
    
    func pushMove(wbMove: WBMove, firstMovingPlayer: String) {
        let player1isWhite = firstMovingPlayer == "white" ? true : false
        displayMove(moveUCI: wbMove.answer_uci, playerIsWhite: player1isWhite )
        let seconds = 1.0
        if wbMove.response_uci == "complete" {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.clearSelections()
            self.displayMove(moveUCI: wbMove.response_uci, needsHighlight: true, playerIsWhite: !player1isWhite)
        }
    }
    
    func displayMove(moveUCI: String, needsHighlight: Bool = false, playerIsWhite: Bool) {
        if moveUCI == "complete" {return}
        var pieceImage: UIImage = UIImage()
        let start = squareNameToIndex(square: moveUCI[0,1])
        let end = squareNameToIndex(square: moveUCI[2,3])
        if moveUCI.count == 5 {
            var pieceName = String(moveUCI.last!)
            if playerIsWhite {pieceName = pieceName.uppercased()}
            pieceImage = PieceName(rawValue: pieceName)!.image.withRenderingMode(.alwaysOriginal)
        } else {
            pieceImage = self.squareButtons[start].currentImage!
        }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0) {
                if needsHighlight {
                    self.squareButtons[start].layer.borderColor = UIColor.black.cgColor
                    self.squareButtons[end].layer.borderColor = UIColor.black.cgColor
                    self.startSquare = start
                    self.endSquare = end
                }
                self.squareButtons[start].setImage(#imageLiteral(resourceName: "clear_square"), for: .normal)
                self.squareButtons[end].setImage(pieceImage, for: .normal)
            }
        }
    }
    
    // fix this
    func displaySolutionMoves(solutionMoves: [WBMove], playerToMove: String ) {
        var delay = 0.5
        for i in 0..<solutionMoves.count {
            let wbMove = solutionMoves[i]
            for moveUCI in [wbMove.answer_uci, wbMove.response_uci] {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    print(moveUCI)
                    if moveUCI == "complete" {
                        self.delegate?.didFinishShowingSolution()
                        return
                        
                    }
                    self.clearSelections()
                    let playerIsWhite = playerToMove == "white" ? true : false
                    self.displayMove(moveUCI: moveUCI, needsHighlight: true, playerIsWhite: playerIsWhite)
                })
                delay = delay + 1.0
            }
        }
    }
    
    // MARK: - Helper
    
}

extension String {
    subscript(from: Int, to: Int) -> String {
        /*
         only valid for substring of length 2
        */
        return String(self[index(startIndex, offsetBy: from)]) + String(self[index(startIndex, offsetBy: to)])
    }
}

class SquareButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if titleLabel != nil {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
        }
    }
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}


