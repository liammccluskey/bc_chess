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
    
    var startSquare: Int?
    var startSquareUCI: String?
    var endSquare: Int?
    var endSquareUCI: String?
    var squareButtons: [UIButton]! // all squares on chessboard -> button.tag in [0,63], pieces are shown
    var squareButtonsBlank: [UIButton]! // all squares, pieces are not shown
    
    var vstack: UIStackView! // vertical stack of horizontal stacks with all chessboard squares
    var vstackBlank: UIStackView! // repeat above but squares don't show pieces
    
    
    // MARK: - Init
    
    init(position: Position, showPiecesInitially: Bool) {
        self.currentPosition = position
        self.showPiecesInitially = showPiecesInitially
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
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        vstack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vstack.heightAnchor.constraint(equalTo: vstack.widthAnchor).isActive = true
        
        vstackBlank.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        vstackBlank.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        vstackBlank.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstackBlank.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vstackBlank.heightAnchor.constraint(equalTo: vstack.widthAnchor).isActive = true
    }
    
    func configureSquareButtons() -> [UIButton] {
        var buttons: [UIButton] = []
        for i in 0..<64 {
            let button = UIButton(type: .system)
            button.tag = i
            button.addTarget(self, action: #selector(squareAction), for: .touchUpInside)
            button.backgroundColor = getSquareColor(squareIndex: i)
            button.setImage(#imageLiteral(resourceName: "clear_square"), for: .normal)
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
        for i in 0..<64 {
            squareButtons[i].setImage(#imageLiteral(resourceName: "clear_square"), for: .normal)
        }
        let pieces: [[String]] = [pos.P, pos.p, pos.N, pos.n, pos.B, pos.b, pos.R, pos.r, pos.Q, pos.q, pos.K, pos.k]
        for i in 0..<pieces.count {
            for square in pieces[i] {
                let index: Int = squareNameToIndex(square: square)
                DispatchQueue.main.async {
                    self.squareButtons[index].setImage(PieceType(rawValue: i)?.image.withRenderingMode(.alwaysOriginal), for: .normal)
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
            DispatchQueue.main.async {
                self.squareButtonsBlank[sender.tag].backgroundColor = CommonUI().blueColorDark
                self.squareButtons[sender.tag].backgroundColor = CommonUI().blueColorDark
            }
        } else if !choseEnd {
            if sender.tag == startSquare {clearSelections(); return}
            print(sender.tag)
            endSquare = sender.tag
            endSquareUCI = indexToUCI(index: sender.tag)
            let moveUCI = "\(startSquareUCI!)\(endSquareUCI!)"
            delegate?.didMakeMove(moveUCI: moveUCI)
            DispatchQueue.main.async {
                self.squareButtonsBlank[sender.tag].backgroundColor = CommonUI().blueColorLight
                self.squareButtons[sender.tag].backgroundColor = CommonUI().blueColorLight
            }
        } else if choseStart && choseEnd {
            clearSelections()
            startSquare = sender.tag
            startSquareUCI = indexToUCI(index: sender.tag)
            DispatchQueue.main.async {
                sender.backgroundColor = CommonUI().blueColorDark
            }
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
        /*
         Returns correct color of the square based on square index
        */
        /*
        if (squareIndex / 8)  % 2 == 0 {
            return squareIndex % 2 == 0 ? CommonUI().blueColorDark : CommonUI().blueColorLight
        } else {
            return squareIndex % 2 != 0 ? CommonUI().blueColorDark : CommonUI().blueColorLight
        }
        */
        if (squareIndex / 8)  % 2 == 0 {
            return squareIndex % 2 == 0 ? CommonUI().tanColorDark : CommonUI().tanColorLight
        } else {
            return squareIndex % 2 != 0 ? CommonUI().tanColorDark : CommonUI().tanColorLight
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
        squareButtons.forEach{ (button) in
            button.isEnabled = isEnabled
        }
        squareButtonsBlank.forEach{ (button) in
            button.isEnabled = isEnabled
        }
    }
    
    func clearSelections() {
        if let start = startSquare {
            DispatchQueue.main.async {
                self.squareButtons[start].backgroundColor = self.getSquareColor(squareIndex: start)
                self.squareButtonsBlank[start].backgroundColor = self.getSquareColor(squareIndex: start)
            }
            self.startSquare = nil
            self.startSquareUCI = nil
        }
        if let end = endSquare {
            DispatchQueue.main.async {
                self.squareButtons[end].backgroundColor = self.getSquareColor(squareIndex: end)
                self.squareButtonsBlank[end].backgroundColor = self.getSquareColor(squareIndex: end)
            }
            self.endSquare = nil
            self.endSquareUCI = nil
        }
    }
    
    func showPieces() {
        guard let _ = vstack else {return}
        vstack.isHidden = false
    }
    
    func hidePieces() {
        guard let _ = vstack else {return}
        vstack.isHidden = true
    }
    
    func pushMove(wbMove: WBMove) {
        displayMove(moveUCI: wbMove.answer_uci)
    }
    
    func displayMove(moveUCI: String) {
        let startIndex = squareNameToIndex(square: moveUCI[0,1])
        let endIndex = squareNameToIndex(square: moveUCI[2,3])
        let pieceImage = self.squareButtons[startIndex].currentImage
        UIView.animate(withDuration: 0.3) {
            self.squareButtons[startIndex].setImage(#imageLiteral(resourceName: "clear_square"), for: .normal)
            self.squareButtons[endIndex].setImage(pieceImage, for: .normal)
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
