//
//  ChessBoardImageController.swift
//  BCPtest
//
//  Created by Guest on 8/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class ChessBoardImageController: UIViewController {
    
    // MARK: - Properties
    var currentPosition: Position?
    
    var dsColor: UIColor!
    var lsColor: UIColor!
   
    var squareImages: [UIImageView]!
    
    var vstack: UIStackView! // vertical stack of horizontal stacks with all chessboard squares
    
    
    // MARK: - Init
    
    init(position: Position, boardTheme: ColorTheme) {
        self.currentPosition = position
        let theme = UserDataManager().getBoardColor()
        pieceStyle = UserDataManager().getPieceStyle()
        self.dsColor = UserDataManager().getBoardColor()!.darkSquareColor
        self.lsColor = UserDataManager().getBoardColor()!.lightSquareColor
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
        squareImages = configureSquareImages() // squares with visible pieces
        vstack = configureSquaresVStack(piecesAreVisible: true)
        configureStartingPosition()
        
        view.addSubview(vstack)
    }
    
    func setUpAutoLayout() {
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0).isActive = true
        vstack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vstack.heightAnchor.constraint(equalTo: vstack.widthAnchor).isActive = true
    }
    
    func configureSquareImages() -> [UIImageView] {
        var imViews: [UIImageView] = Array.init(repeating: UIImageView(), count: 64)
        for i in 0..<64 {
            let imView = UIImageView()
            imView.contentMode = .scaleAspectFit
            imView.tag = i
            imView.backgroundColor = getSquareColor(squareIndex: i)
            imView.image = #imageLiteral(resourceName: "clear_square")
            
            imViews[i] = imView
        }
        return imViews
    }
    
    func configureSquaresVStack(piecesAreVisible: Bool) -> UIStackView {
        var rankHStacks = [UIStackView](repeating: UIStackView(), count: 8)
        for i in 0..<8 {
            let rankImageViews =  Array(squareImages[i*8...(i*8+7)])
            let rankHStack = configureHStack(arrangedSubViews: rankImageViews)
            let index = 7 - i // want first rank at bottom of vertical stack
            rankHStacks[index] = rankHStack
        }
        let boardVStack = configureVStack(arrangedSubViews: rankHStacks)
        return boardVStack
    }
    
    func configureStartingPosition() {
        guard let pos = currentPosition else {return}
        let pieces: [[String]] = [pos.P, pos.p, pos.N, pos.n, pos.B, pos.b, pos.R, pos.r, pos.Q, pos.q, pos.K, pos.k]
        for i in 0..<pieces.count {
            for square in pieces[i] {
                let index: Int = squareNameToIndex(square: square)
                self.squareImages[index].image = PieceType(rawValue: i)?.image.withRenderingMode(.alwaysOriginal)
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
}

