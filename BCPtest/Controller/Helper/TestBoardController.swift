//
//  File.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/30/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import ChessKit
import AVFoundation

/*
 case tan               0
 case darkBlue          1
 case gray              2
 case green             3
 case purple            4
 case lightBlue         5
 
 case darkWood          6
 case walnut            7
 case newspaper         8
 case lightPurple       9
 
 
 case classic //chesscom        0
 case modern
 case lichess                   1
 case newspaper                 2
 case fancy                     3
 case minimal                   4
 }
 */

class TestVC: UIViewController {
    
    private var isDragging = false
    
    var tbc: TestBoardController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDataManager().setBoardColor(boardColor: ColorTheme(rawValue: 6)!)
        UserDataManager().setPieceStyle(pieceStyle: 1)
        pieceStyle = UserDataManager().getPieceStyle()
        
        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        tbc = TestBoardController(sideLength: view.bounds.width, fen: fen, showPiecesInitially: true)
        UIView.appearance().isExclusiveTouch = true
        tbc.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tbc.view)
        
        tbc.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tbc.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tbc.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tbc.view.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        tbc.view.heightAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
    }
}

class TestBoardController: UIViewController {
    
    var game: Game!
    
    var sideLength: CGFloat!
    var isDragging = false
    
    var squareHover: UIImageView!
    var squareFromHighlight: UIImageView!
    var squareToHighlight: UIImageView!
    var highlightColor: UIColor!
    
    // MARK: - Properties
    var delegate: ChessBoardDelegate?
    var showPiecesInitially: Bool!
    var layoutColor: Int! // 0-> black, 1-> white
    
    var dsColor: UIColor!
    var lsColor: UIColor!
    var boardImage: UIImage!
    
    var fromSquareIndex: Int?
    var fromSquareUCI: String?
    var toSquareIndex: Int?
    var toSquareUCI: String?
    
    var squareIVs: [UIImageView] = []
    var pieceIVs: [UIImageView] = []
    
    var nameStackV: UIStackView!
    var nameStackH: UIStackView!
    
    
    // MARK: - Init/Interface
    
    init(sideLength: CGFloat, fen: String, showPiecesInitially: Bool) {
        self.sideLength = sideLength
        self.layoutColor = 1
        self.showPiecesInitially = true
        let theme = UserDataManager().getBoardColor()
        self.dsColor = theme!.darkSquareColor
        self.lsColor = theme!.lightSquareColor
        self.boardImage = theme!.image
        self.highlightColor = theme!.rawValue == 1 ? CommonUI().greenColor : CommonUI().blueColorDark
        
        let position = FenSerialization.default.deserialize(fen: fen)
        self.game = Game(position: position)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
        configureUI()
        
        if showPiecesInitially == false { hidePieces() }
    }
    
    // MARK: - Config
    
    func configureUI() {
        
        configBoardImage()
        configSquareIVs()
        configSquareHighlights()
        configPieceIVs()
        
        view.isUserInteractionEnabled = true
        view.backgroundColor = .black
    }
    
    func configBoardImage() {
        let iv = UIImageView(frame: view.frame)
        iv.contentMode = .scaleToFill
        iv.image = boardImage
        view.addSubview(iv)
    }
    
    func configSquareIVs() {
        let xOffset: CGFloat = layoutColor == 0 ? 7 : 0
        let yOffset: CGFloat = layoutColor == 0 ? 0 : 7
        for i in 0..<64 {
            
            let x = sideLength/8.0 * abs(xOffset - CGFloat(i % 8))
            let y = sideLength/8.0 * abs(yOffset - CGFloat(i/8))
            let iv = UIImageView(frame: CGRect(x: x, y: y, width: sideLength/8.0, height: sideLength/8.0))
            iv.backgroundColor = getSquareColor(squareIndex: i)
            iv.tag = i
            iv.isUserInteractionEnabled = true
            //let tapG = UITapGestureRecognizer(target: self, action: #selector(squareTapped))
            //iv.addGestureRecognizer(tapG)
            view.addSubview(iv)
            squareIVs.append(iv)
        }
    }
    
    func configPieceIVs() {
        let xOffset: CGFloat = layoutColor == 0 ? 7 : 0
        let yOffset: CGFloat = layoutColor == 0 ? 0 : 7
        game.position.board.enumeratedPieces().map {
            let index = nameToIndex(square: $0.0.coordinate)
            let pieceImage = PieceName(rawValue: $0.1.description)?.image
            
            let x = sideLength/8.0 * abs(xOffset - CGFloat(index % 8))
            let y = sideLength/8.0 * abs(yOffset - CGFloat(index/8))
            let iv = UIImageView(frame: CGRect(x: x, y: y, width: sideLength/8.0, height: sideLength/8.0))
            iv.isUserInteractionEnabled = true
            iv.image = pieceImage ?? UIImage()
            iv.contentMode = .scaleAspectFit
            iv.tag = index
            
            iv.backgroundColor = .clear
            pieceIVs.append(iv)
            view.addSubview(iv)
        }
    }
    
    func configSquareHighlights() {
        squareHover = UIImageView(frame: CGRect(x: 0, y: 0, width: sideLength/3.3, height: sideLength/3.3))
        squareHover.layer.cornerRadius = squareHover.frame.width/2
        squareHover.backgroundColor = .black
        squareHover.alpha = 0
        view.addSubview(squareHover)
        
        squareFromHighlight = UIImageView()
        squareFromHighlight.backgroundColor = highlightColor
        squareFromHighlight.alpha = 0.5
        view.addSubview(squareFromHighlight)
        
        squareToHighlight = UIImageView()
        squareToHighlight.backgroundColor = highlightColor
        squareToHighlight.alpha = 0.5
        view.addSubview(squareToHighlight)
    }
    
    // MARK: - Helper
        
    func getSquareColor(squareIndex: Int) -> UIColor {
        if (squareIndex / 8)  % 2 == 0 {
            return squareIndex % 2 == 0 ? dsColor : lsColor
        } else {
            return squareIndex % 2 != 0 ? dsColor : lsColor
        }
    }
    
    func nameToIndex(square: String) -> Int {
        let file = square.first!
        let rank = Int(String(square.last!))!
        let files: [Character: Int] = ["a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7]
        return (rank-1)*8 + files[file]!
    }
    
    func indexToName(index: Int) -> String {
        let rank = index/8 + 1
        let fileIndex = index % 8
        let files = ["a","b","c","d","e","f","g","h"]
        let file = files[fileIndex]
        return "\(file)\(rank)"
    }
    
    // MARK: - Move Validation and Classification
    
    func isValidStartSquare(squareIndex: Int) -> Bool {
        let square = Square(coordinate: indexToName(index: squareIndex))
        if let boardSquare = game.position.board.enumeratedPieces().first(where: {$0.0 == square}) {
            print("trying to move color: \(boardSquare.1.color) while turn is \(game.position.state.turn)")
            return boardSquare.1.color == game.position.state.turn
        } else {
            return false
        }
    }
    
    func isValidMove() -> Bool {
        guard let fromIndex = fromSquareIndex, let toIndex = toSquareIndex else {return false}
        let fromSquare = Square(coordinate: indexToName(index: fromIndex))
        let toSquare = Square(coordinate: indexToName(index: toIndex))
        let move = Move(from: fromSquare, to: toSquare)
        let isValidMove = game.legalMoves.contains(move)
        if isValidMove == false {
            SoundEffectPlayer().illegal()
        }
        return isValidMove
    }
    
    func updatePiecesIfNeeded(promotionSquare: Square? = nil) {
        if let square = promotionSquare {
            let pieceTag = nameToIndex(square: square.coordinate)
            let boardSquare = game.position.board.enumeratedPieces().first(where: {$0.0 == square})
            pieceIVs[pieceTag].image = PieceName(rawValue: boardSquare!.1.description)!.image
            return
        }
        // Check castle: remove rooks and update rook image position
        pieceIVs.forEach { (pieceIV) in
            if game.position.board.enumeratedPieces().contains(where: {$0.0.coordinate == indexToName(index: pieceIV.tag)}) == false{
                pieceIV.removeFromSuperview()
                pieceIVs.removeAll(where: {$0.tag == pieceIV.tag})
            }
        }
        game.position.board.enumeratedPieces().forEach { (boardSquare) in
            let squareTag = nameToIndex(square: boardSquare.0.coordinate)
            if pieceIVs.contains(where: {$0.tag == squareTag }) == false {
                let pieceImage = PieceName(rawValue: boardSquare.1.description)!.image
                let iv = UIImageView(frame: squareIVs[squareTag].frame)
                iv.isUserInteractionEnabled = true
                iv.image = pieceImage
                iv.contentMode = .scaleAspectFit
                iv.tag = squareTag
                iv.backgroundColor = .clear
                pieceIVs.append(iv)
                view.addSubview(iv)
                return
            }
        }
    }
    
    // MARK: - Interface
    
    func trySetFromSquare(squareIndex: Int) -> Bool {
        if isValidStartSquare(squareIndex: squareIndex) == false {return false}
        fromSquareIndex = squareIndex
        squareFromHighlight.frame = squareIVs[squareIndex].frame
        return true
    }
    
    func deselectFromSquare() {
        squareFromHighlight.frame = .zero
        fromSquareIndex = nil
    }
    
    func cancelDragAction() {
        guard let fromIndex = fromSquareIndex else {return}
        if let pieceIV = pieceIVs.first(where: {$0.tag == fromIndex}) {
            if let squareIV = squareIVs.first(where: {$0.tag == fromIndex}) {
                pieceIV.frame = squareIV.frame
            }
        }
        squareToHighlight.frame = .zero
        toSquareIndex = nil
        squareHover.alpha = 0
    }
    
    func tryPushMove(animated: Bool, location: CGPoint = .zero) -> Bool {
        let isLegal = isValidMove()
        if !isLegal && animated == false {
            cancelDragAction(); deselectFromSquare(); return false
        }
        else if !isLegal {
            toSquareIndex = nil; deselectFromSquare(); return false
        }
        var capturedEnPasant = false
        if let enPasant = game.position.state.enPasant {
            if enPasant.coordinate == indexToName(index: toSquareIndex!) {
                capturedEnPasant = true
                let capturedPawnIndex = toSquareIndex!/8 == 2 ? toSquareIndex! + 8 : toSquareIndex! - 8
                if let pieceIV = pieceIVs.first(where: {$0.tag == capturedPawnIndex}) { pieceIV.removeFromSuperview() }
                pieceIVs.removeAll(where: {$0.tag == capturedPawnIndex})
                
            }
        }
        let isCapture = pieceIVs.contains(where: {$0.tag == toSquareIndex!})
        if isCapture {
            if let pieceIV = pieceIVs.first(where: {$0.tag == toSquareIndex!}) { pieceIV.removeFromSuperview() }
            pieceIVs.removeAll(where: {$0.tag == toSquareIndex!})
        }
        
        let fromSquare = Square(coordinate: indexToName(index: fromSquareIndex!))
        let toSquare = Square(coordinate: indexToName(index: toSquareIndex!))
        let move = Move(from: fromSquare, to: toSquare)
        print(move.description)
        game.make(move: move)
        
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                if let pieceIV = self.pieceIVs.first(where: {$0.tag == self.fromSquareIndex!}) {
                    pieceIV.frame = self.squareIVs[self.toSquareIndex!].frame
                    pieceIV.tag = self.toSquareIndex!
                }
                if self.game.isCheck || self.game.isMate { SoundEffectPlayer().moveCheck() }
                else if isCapture || capturedEnPasant { SoundEffectPlayer().capture() }
                else { SoundEffectPlayer().moveSelf()
                }
            }
            self.squareToHighlight.frame = self.squareIVs[self.toSquareIndex!].frame
        } else {
            for toSquare in squareIVs {
                if toSquare.frame.contains(location) {
                    squareToHighlight.frame = toSquare.frame
                    if let pieceIV = pieceIVs.first(where: {$0.tag == fromSquareIndex!}) {
                        pieceIV.frame = toSquare.frame
                        pieceIV.tag = toSquare.tag
                    }
                }
            }
            if self.game.isCheck || self.game.isMate { SoundEffectPlayer().moveCheck() }
            else if isCapture || capturedEnPasant { SoundEffectPlayer().capture() }
            else { SoundEffectPlayer().moveSelf()
            }
        }
        fromSquareIndex = nil
        toSquareIndex = nil
        if let _ = move.promotion {
            updatePiecesIfNeeded(promotionSquare: move.to)
        } else {
            updatePiecesIfNeeded()
        }
        return true
    }
    
    // MARK: - Public Interface
    
    func showPieces() {
        pieceIVs.forEach({$0.alpha = 1})
    }
    
    func hidePieces() {
        pieceIVs.forEach({$0.alpha = 0})
    }
}

extension TestVC {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        tbc.isDragging = true
        let location = touch.location(in: self.tbc.view)
        if tbc.view.bounds.contains(location) == false { return }
        let tappedSquare = touch.view as! UIImageView
        if tbc.isValidStartSquare(squareIndex: tappedSquare.tag) {
            tbc.trySetFromSquare(squareIndex: tappedSquare.tag)
        } else {
            tbc.toSquareIndex = tappedSquare.tag
            tbc.tryPushMove(animated: true)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard tbc.isDragging, let fromTag = tbc.fromSquareIndex, let touch = touches.first else {return}
        
        let location = touch.location(in: self.tbc.view)
        
        let newWidth = tbc.sideLength/4.25
        let newX = location.x - newWidth/2
        let newY = location.y - newWidth*0.9
        let draggingFrame = CGRect(x: newX, y: newY, width:  newWidth, height: newWidth)
        if let pieceIV = tbc.pieceIVs.first(where: {$0.tag == fromTag}) {
            pieceIV.frame = draggingFrame
            tbc.view.bringSubviewToFront(pieceIV)
        }
       
        for toSquare in tbc.squareIVs {
            if toSquare.frame.contains(location) {
                tbc.squareHover.center = toSquare.center
                tbc.squareToHighlight.frame = toSquare.frame
                if tbc.squareHover.alpha == 0.0 {
                    tbc.squareHover.alpha = 0.15
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        
        let location = touch.location(in: self.tbc.view)
        if tbc.view.bounds.contains(location) == false {tbc.cancelDragAction(); return }

        tbc.isDragging = false
        tbc.squareHover.alpha = 0
        
        guard let fromIndex = tbc.fromSquareIndex else {return}
        for toSquare in tbc.squareIVs {
            if toSquare.frame.contains(location) {
                if toSquare.tag == fromIndex { tbc.cancelDragAction(); return }
                tbc.toSquareIndex = toSquare.tag
                print("did try and drop move on touches ended")
                tbc.tryPushMove(animated: false, location: location)
            }
        }
 
    }
}


   



   
