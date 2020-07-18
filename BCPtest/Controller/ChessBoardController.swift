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
    var currentPosition: Position?
    
    var startSquare: Int?
    var endSquare: Int?
    var squareButtons: [UIButton]! // all squares on chessboard -> button.tag in [0,63]
    
    var vstack: UIStackView! // vertical stack of horizontal stacks with all chessboard squares
    
    
    // MARK: - Init
    
    init(position: Position) {
        self.currentPosition = position
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
        squareButtons = configureSquareButtons()
        vstack = configureSquaresVStack()
        
        view.addSubview(vstack)
        
        showPieces()
        
    }
    
    func setUpAutoLayout() {
        
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0).isActive = true
        //vstack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        vstack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vstack.heightAnchor.constraint(equalTo: vstack.widthAnchor).isActive = true
        
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
    
    func configureSquaresVStack() -> UIStackView {
        var rankHStacks = [UIStackView](repeating: UIStackView(), count: 8)
        for i in 0..<8 {
            let rankButtons = Array(squareButtons[i*8...(i*8+7)])
            let rankHStack = configureHStack(arrangedSubViews: rankButtons)
            let index = 7 - i // want first rank at bottom of vertical stack
            rankHStacks[index] = rankHStack
        }
        let boardVStack = configureVStack(arrangedSubViews: rankHStacks)
        return boardVStack
    }
    
    // MARK: - Selectors
    
    @objc func squareAction(_ sender: UIButton) {
        let choseStart: Bool = startSquare != nil
        let choseEnd: Bool = endSquare != nil
        if !choseStart {
            print(sender.tag)
            startSquare = sender.tag
            DispatchQueue.main.async {
                self.squareButtons[sender.tag].backgroundColor = .green
            }
        } else if !choseEnd {
            print(sender.tag)
            endSquare = sender.tag
            DispatchQueue.main.async {
                self.squareButtons[sender.tag].backgroundColor = .red
            }
        } else {
            print("called clear selections")
            clearSelections()
        }
    }
    
    // MARK: - Interface
    
    func clearSelections() {
        if let start = startSquare {
            DispatchQueue.main.async {
                self.squareButtons[start].backgroundColor = self.getSquareColor(squareIndex: start)

            }
            
            self.startSquare = nil
        }
        if let end = endSquare {
            DispatchQueue.main.async {
                self.squareButtons[end].backgroundColor = self.getSquareColor(squareIndex: end)
            }
            self.endSquare = nil
        }
    }
    
    func showPieces() {
        guard let pos = currentPosition else {return}
        let pieces: [[String]] = [pos.P, pos.p, pos.N, pos.n, pos.B, pos.b, pos.R, pos.r, pos.Q, pos.q, pos.K, pos.k]
        for i in 0..<pieces.count {
            for square in pieces[i] {
                let index: Int = squareToIndex(square: square)
                DispatchQueue.main.async {
                    self.squareButtons[index].setImage(PieceType(rawValue: i)?.image.withRenderingMode(.alwaysOriginal), for: .normal)
                }
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
        if (squareIndex / 8)  % 2 == 0 {
            return squareIndex % 2 == 0 ? CommonUI().blueColorDark : CommonUI().blueColorLight
        } else {
            return squareIndex % 2 != 0 ? CommonUI().blueColorDark : CommonUI().blueColorLight
        }
    }
    
    func squareToIndex(square: String) -> Int {
        let file = square.first!
        let rank = Int(String(square.last!))!
        let files: [Character: Int] = ["a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7]
        return (rank-1)*8 + files[file]!
    }
    
}

extension String {
    subscript (characterIndex: Int) -> Character {
        return self[index(startIndex, offsetBy: characterIndex)]
    }
}
