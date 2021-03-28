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

class TestVC: UIViewController, BoardDelegate {
    
    var board: BoardController!
    override func viewDidLoad() {
        board = BoardController(sideLength: view.bounds.width, fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", showPiecesInitially: true)
        board.delegate = self
        board.view.center = view.center
        view.addSubview(board.view)
    }
    
    func didMakeMove(move: Move, animated: Bool) {
        board.pushMove(move: move, animated: animated)
    }
}

class BoardController: UIViewController {
    
    var stationaryPieceBaseWidth: CGFloat!
    var stationaryPieceSizeScale: CGFloat!
    var stationaryPieceOffsetY: CGFloat!
    var stationaryPieceOffsetX: CGFloat!
    
    let startFEN: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    var game: Game!
    var previousPositions: [LoadedPosition] = []
    var currentPosition: LoadedPosition?
    var nextPositions: [LoadedPosition] = []
    
    var sideLength: CGFloat!
    var isDragging = false
    
    var squareHover: UIImageView!
    var squareFromHighlight: UIImageView!
    var squareToHighlight: UIImageView!
    var highlightColor: UIColor!
    
    // MARK: - Properties
    var delegate: BoardDelegate?
    var showPiecesInitially: Bool!
    var layoutColor: Int! // 0-> black, 1-> white
    
    var dsColor: UIColor!
    var lsColor: UIColor!
    var boardImage: UIImage!
    
    var fromSquareIndex: Int?
    var toSquareIndex: Int?
    var promotionPiece: PieceKind?
    
    var squareIVs: [UIImageView] = []
    var pieceIVs: [UIImageView] = []
    
    var nameStackV: UIStackView!
    var nameStackH: UIStackView!
    
    let BCH = BoardControllerHelper()
    
    
    // MARK: - Init/Interface
    
    init(sideLength: CGFloat, fen: String, showPiecesInitially: Bool) {
        self.sideLength = sideLength
        self.showPiecesInitially = showPiecesInitially
        let theme = UserDataManager().getBoardColor()!
        self.dsColor = theme.darkSquareColor
        self.lsColor = theme.lightSquareColor
        self.boardImage = theme.image
        self.highlightColor = theme == .darkBlue ? .black : CommonUI().blueColorDark
        
        let position = FenSerialization.default.deserialize(fen: fen)
        self.game = Game(position: position)
        
        if game.position.state.turn == .black {
            self.layoutColor = 0
        } else {
            self.layoutColor = 1
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isExclusiveTouch = true
        updateFrame(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
        configureUI()
        
        if showPiecesInitially == false { hidePieces() }
    }
    
    func setNewPosition(fen: String) {
        let position = FenSerialization.default.deserialize(fen: fen)
        self.game = Game(position: position)
        if game.position.state.turn == .black {
            layoutColor = 0
        } else {
            layoutColor = 1
        }
        fromSquareIndex = nil
        toSquareIndex = nil
        promotionPiece = nil
    }
    
    func configStartPosition(piecesHidden: Bool = false) {
        DispatchQueue.main.async {
            self.view.subviews.forEach({$0.removeFromSuperview()})
            self.pieceIVs = []
            self.squareIVs = []
            self.configBoardImage()
            self.configSquareIVs()
            self.configSquareHighlights()
            self.configPieceIVs()
            if piecesHidden { self.hidePieces() }
        }
    }
    
    func updateFrame(frame: CGRect) {
        view.frame = frame
        sideLength = frame.width
        setPieceImageScaleFactors(forFrame: frame)
    }
    
    private func setPieceImageScaleFactors(forFrame frame: CGRect) {
        let pieceStyleTheme = PieceStyleTheme(rawValue: UserDataManager().getPieceStyle())!
        switch pieceStyleTheme {
        case .threeD:
            stationaryPieceOffsetX = 0
            stationaryPieceOffsetY = frame.width/8.0/6.5
            stationaryPieceSizeScale = 1.3
        case .realThreeD:
            stationaryPieceOffsetX = frame.width/8/4.7
            stationaryPieceOffsetY = frame.width/8/5
            stationaryPieceSizeScale = 1.7
        default:
            stationaryPieceOffsetX = 0
            stationaryPieceOffsetY = 0
            stationaryPieceSizeScale = 1
        }
        stationaryPieceBaseWidth = frame.width/8.0
    }
    
    // MARK: - Config
    
    func configureUI() {
        
        configBoardImage()
        configSquareIVs()
        configSquareHighlights()
        configPieceIVs()
        
        view.isUserInteractionEnabled = true
    }
    
    func configBoardImage() {
        let iv = UIImageView(frame: view.bounds)
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
            view.addSubview(iv)
            squareIVs.append(iv)
        }
        configCoordinateLabels()
    }
    
    func configCoordinateLabels() {
        let rankNames = layoutColor == 1 ? ["1","2","3","4","5","6","7","8"].reversed() : ["1","2","3","4","5","6","7","8"]
        let fileNames = layoutColor == 1 ? ["a","b","c","d","e","f","g","h"] : ["a","b","c","d","e","f","g","h"].reversed()
        let coordFont = UIDevice.current.userInterfaceIdiom == .pad ?
            UIFont(name: fontStringBold, size: 18) :
            UIFont(name: fontStringBold, size: 11)
        let smallPadding: CGFloat = 0
        let bigPadding: CGFloat = 1
        let labelW:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 19 : 12
        // fileNames
        for i in 0..<8 {
            let rankLabel = UILabel()
            rankLabel.textAlignment = .center
            rankLabel.text = rankNames[i]
            rankLabel.font = coordFont
            if lsColor == .clear { rankLabel.textColor = i%2 == 0 ? .darkGray : .lightGray }
            else { rankLabel.textColor = i%2 == 0 ? dsColor : lsColor}
            rankLabel.frame = CGRect(x: smallPadding, y: sideLength/8.0 * CGFloat(i) + smallPadding, width: labelW, height: labelW)
            view.addSubview(rankLabel)
            
            let fileLabel = UILabel()
            fileLabel.textAlignment = .center
            fileLabel.text = fileNames[i]
            fileLabel.font = coordFont
            if lsColor == .clear { fileLabel.textColor = i%2 == 0 ? .lightGray : .darkGray }
            else { fileLabel.textColor = i%2 == 0 ? lsColor : dsColor}
            fileLabel.frame = CGRect(
                x: sideLength/8.0 * (1.0 + CGFloat(i)) - labelW - smallPadding,
                y: sideLength - labelW - bigPadding,
                width: labelW, height: labelW)
            view.addSubview(fileLabel)
        }
    }
    
    func configPieceIVs() {
        game.position.board.enumeratedPieces().map {
            let pieceTag = nameToIndex(square: $0.0.coordinate)
            let pieceImage = PieceName(rawValue: $0.1.description)?.image
            let iv = UIImageView()
            iv.isUserInteractionEnabled = true
            iv.image = pieceImage ?? UIImage()
            iv.contentMode = .scaleAspectFit
            iv.tag = pieceTag
                        
            iv.backgroundColor = .clear
            pieceIVs.append(iv)
            view.addSubview(iv)
            setStationaryPieceFrame(forPieceAtTag: pieceTag, atSquareTag: pieceTag)
        }
        reorderPieceIVPositions()
    }
    
    private func setStationaryPieceFrame(forPieceAtTag pieceTag: Int, atSquareTag squareTag: Int) {
    /*
        Note: Assumes pieceIV is already in self.pieceIVs
        Note: Always updates pieceTag to squareTag
    */
        let width = stationaryPieceBaseWidth * stationaryPieceSizeScale
        if let pieceIV = pieceIVs.first(where: {$0.tag == pieceTag}) {
            pieceIV.frame = CGRect(x: 0, y: 0, width: width, height: width)
            pieceIV.center = squareIVs[squareTag].center
            pieceIV.frame.origin.y -= stationaryPieceOffsetY
            pieceIV.frame.origin.x += stationaryPieceOffsetX
            pieceIV.tag = squareTag
        }
    }
    
    private func reorderPieceIVPositions() {
        let arrangedPieceIVs = layoutColor == 1 ? pieceIVs.enumerated().sorted(by: {$0.element.tag > $1.element.tag}) :
            pieceIVs.enumerated().sorted(by: {$0.element.tag < $1.element.tag })
        let arrangedPieceIVIndeces = arrangedPieceIVs.map({$0.offset})
        arrangedPieceIVIndeces.forEach({
            view.bringSubviewToFront(pieceIVs[$0])
        })
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
    
    func askForPromotionPiece(completion: @escaping (PieceKind?) -> () ) {
        var actionSheet = UIAlertController()
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        } else {
            actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }
        let queenAction = UIAlertAction(title: "Queen", style: .default) { (action) in
            completion(.queen)
        }
        let rookAction = UIAlertAction(title: "Rook", style: .default) { (action) in
            completion(.rook)
        }
        let bishopAction = UIAlertAction(title: "Bishop", style: .default) { (action) in
            completion(.bishop)
        }
        let knightAction = UIAlertAction(title: "Knight", style: .default) { (action) in
            completion(.knight)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            completion(nil)
        }
        actionSheet.addAction(queenAction)
        actionSheet.addAction(rookAction)
        actionSheet.addAction(bishopAction)
        actionSheet.addAction(knightAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
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
    
    func removePieceAt(pieceTag: Int) {
        if let pieceIV = pieceIVs.first(where: {$0.tag == pieceTag}) { pieceIV.removeFromSuperview() }
        pieceIVs.removeAll(where: {$0.tag == pieceTag})
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
        let move = Move(from: fromSquare, to: toSquare, promotion: promotionPiece)
        return game.legalMoves.contains(move)
        
    }
    
    func isValidPromototion() -> Bool {
        guard let fromIndex = fromSquareIndex, let toIndex = toSquareIndex else {return false}
        let fromSquare = Square(coordinate: indexToName(index: fromIndex))
        let toSquare = Square(coordinate: indexToName(index: toIndex))
        let boardSquare = game.position.board.enumeratedPieces().first(where: {$0.0 == fromSquare})
        let isPawn = boardSquare!.1.kind == .pawn && boardSquare!.1.color == game.position.state.turn
        if isPawn == false {return false}
        let move = Move(from: fromSquare, to: toSquare, promotion: .queen)
        return game.legalMoves.contains(move)
    }
    
    func updatePiecesIfNeeded(promotionSquare: Square? = nil) {
        if let square = promotionSquare {
            let pieceTag = nameToIndex(square: square.coordinate)
            let boardSquare = game.position.board.enumeratedPieces().first(where: {$0.0 == square})
            if let pieceIndex = pieceIVs.firstIndex(where: {$0.tag == pieceTag}) {
                pieceIVs[pieceIndex].image = PieceName(rawValue: boardSquare!.1.description)!.image
            }
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
                let iv = UIImageView()
                iv.isUserInteractionEnabled = true
                iv.image = pieceImage
                iv.contentMode = .scaleAspectFit
                iv.tag = squareTag
                iv.backgroundColor = .clear
                pieceIVs.append(iv)
                view.addSubview(iv)
                setStationaryPieceFrame(forPieceAtTag: squareTag, atSquareTag: squareTag)
                reorderPieceIVPositions()
                return
            }
        }
    }
    
    // MARK: - Private Interface
    
    func constructCurrentMove() -> Move? {
        guard let fromIndex = fromSquareIndex, let toIndex = toSquareIndex else {return nil}
        let fromSquare = Square(coordinate: indexToName(index: fromIndex))
        let toSquare = Square(coordinate: indexToName(index: toIndex))
        return Move(from: fromSquare, to: toSquare, promotion: promotionPiece)
    }
    
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
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1, animations: {
            self.setStationaryPieceFrame(forPieceAtTag: fromIndex, atSquareTag: fromIndex)
        }) { (_) in
            self.reorderPieceIVPositions()
            self.view.isUserInteractionEnabled = true
        }
        squareToHighlight.frame = .zero
        toSquareIndex = nil
        squareHover.alpha = 0
    }
    
    private func highlightSquares(forPushedMove move: Move) {
        let fromSqrIndex = BCH.coordinateToIndex(coordinate: move.from.coordinate)
        let toSqrIndex = BCH.coordinateToIndex(coordinate: move.to.coordinate)
        squareFromHighlight.frame = squareIVs[fromSqrIndex].frame
        squareToHighlight.frame = squareIVs[toSqrIndex].frame
    }
    
    private func addLoadedPosition(pushedMove: Move, fen: String) {
    /*
         Note: Called after a move has been pushed
         Does: Adds var currentPosition to array of previous positions, and updates var currentPosition
         Does: Clears nextPositions if different moves are pushed
    */
        if let pos = currentPosition {
            previousPositions.append(pos)
        }
        currentPosition = LoadedPosition(
            fen: FenSerialization.default.serialize(position: game.position),
            pushedMove: pushedMove)
        if nextPositions.count == 0 {
            return
        } else if nextPositions.last! == currentPosition {
            nextPositions.removeLast()
        } else if nextPositions.last! != currentPosition {
            nextPositions = []
        }
    }
    
    // MARK: - Public Interface
    
    func showPieces() {
        pieceIVs.forEach({$0.alpha = 1})
        
    }
    
    func hidePieces() {
        pieceIVs.forEach({$0.alpha = 0})
    }
    
    func pushMove(move: Move, animated: Bool, completion: @escaping (()->()) = {}, shouldUpdatePositions: Bool = true) {
        let fromSqrIndex = BCH.coordinateToIndex(coordinate: move.from.coordinate)
        let toSqrIndex = BCH.coordinateToIndex(coordinate: move.to.coordinate)
        
        var capturedEnPasant = false
        if let capturedPawnTag = BCH.getTagOfPawnCapturedEnPasant(game: game, moveToPush: move) {
            capturedEnPasant = true
            removePieceAt(pieceTag: capturedPawnTag)
        }
        let isCapture = pieceIVs.contains(where: {$0.tag == toSqrIndex})
        if isCapture {
            removePieceAt(pieceTag: toSqrIndex)
        }
        game.make(move: move)
        let isCheck = game.isCheck
        let isMate = game.isMate
        
        self.squareFromHighlight.frame = self.squareIVs[fromSqrIndex].frame
        self.squareToHighlight.frame = self.squareIVs[toSqrIndex].frame
        let animationDuration = animated ? 0.2 : 0.00
        UIView.animate(withDuration: animationDuration, animations: {
            self.setStationaryPieceFrame(forPieceAtTag: fromSqrIndex, atSquareTag: toSqrIndex)
        }) { (_) in
            self.reorderPieceIVPositions()
            completion()
        }
        if isCheck || isMate {
            SoundEffectPlayer().moveCheck()
        } else if isCapture || capturedEnPasant {
            SoundEffectPlayer().capture()
        } else {
            SoundEffectPlayer().moveSelf()
        }
        fromSquareIndex = nil
        toSquareIndex = nil
        promotionPiece = nil
        if let _ = move.promotion {
            updatePiecesIfNeeded(promotionSquare: move.to)
        } else {
            updatePiecesIfNeeded()
        }
        if shouldUpdatePositions {
            addLoadedPosition(pushedMove: move, fen: FenSerialization.default.serialize(position: game.position))
        }
    }
    
    func overridePosition(withFEN fen: String, isStartPosition: Bool = false) {
    /*
         Sets the board position and clears from and to squares
    */
        if isStartPosition {
            currentPosition = nil
            previousPositions = []
            nextPositions = []
        }
        let position = FenSerialization.default.deserialize(fen: fen)
        self.game = Game(position: position)
        layoutColor = 1
        fromSquareIndex = nil
        toSquareIndex = nil
        promotionPiece = nil
        squareFromHighlight.frame = .zero
        squareToHighlight.frame = .zero
        pieceIVs.forEach({
            $0.removeFromSuperview()
        })
        pieceIVs = []
        configPieceIVs()
    }
    
    func loadPreviousPosition(completion: (Bool)->() ) {
        if currentPosition == nil {
            completion(false)
            return
        } else if previousPositions.count == 0 {
            nextPositions.append(currentPosition!)
            currentPosition = nil
            overridePosition(withFEN: startFEN)
        } else {
            nextPositions.append(currentPosition!)
            currentPosition = previousPositions.popLast()!
            overridePosition(withFEN: currentPosition!.fen)
            highlightSquares(forPushedMove: currentPosition!.pushedMove)
        }
        completion(true)
    }
    
    func loadNextPosition(completion: @escaping (Bool) -> ()) {
        if nextPositions.count == 0 { completion(false); return }
        if let pos = currentPosition {
            previousPositions.append(pos)
        }
        currentPosition = nextPositions.popLast()!
        pushMove(move: currentPosition!.pushedMove, animated: true, shouldUpdatePositions: false) {
            completion(true)
        }
    }
}

extension BoardController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        isDragging = true
        let location = touch.location(in: self.view)
        if view.bounds.contains(location) == false { return }
        
        var tappedSquareTag: Int = 0 // essentially a force unwrap
        squareIVs.forEach({
            if $0.frame.contains(location) {
                tappedSquareTag = $0.tag
            }
        })
        if isValidStartSquare(squareIndex: tappedSquareTag) {
            trySetFromSquare(squareIndex: tappedSquareTag)
        } else {
            toSquareIndex = tappedSquareTag
            isDragging = false
            if isValidPromototion() {
                askForPromotionPiece { (pieceKind) in
                    guard let piece = pieceKind else {return}
                    self.promotionPiece = piece
                    let move = self.constructCurrentMove()!
                    self.delegate?.didMakeMove(move: move, animated: true)
                }
            } else if isValidMove() {
                let move = constructCurrentMove()!
                delegate?.didMakeMove(move: move, animated: true)
            } else {
                SoundEffectPlayer().illegal()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let fromTag = fromSquareIndex, let touch = touches.first else {return}
        
        let location = touch.location(in: self.view)
        
        let newWidth = sideLength/4.25
        let newX = location.x - newWidth/2
        let newY = location.y - newWidth*0.9
        let draggingFrame = CGRect(x: newX, y: newY, width:  newWidth, height: newWidth)
        if let pieceIV = pieceIVs.first(where: {$0.tag == fromTag}) {
            pieceIV.frame = draggingFrame
            view.bringSubviewToFront(pieceIV)
        }
       
        for toSquare in squareIVs {
            if toSquare.frame.contains(location) {
                squareHover.center = toSquare.center
                squareToHighlight.frame = toSquare.frame
                if squareHover.alpha == 0.0 {
                    squareHover.alpha = 0.15
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let fromIndex = fromSquareIndex, let touch = touches.first else {return}
        
        let location = touch.location(in: self.view)
        if view.bounds.contains(location) == false {cancelDragAction(); return }

        isDragging = false
        squareHover.alpha = 0
        
        for toSquare in squareIVs {
            if toSquare.frame.contains(location) {
                if toSquare.tag == fromIndex { cancelDragAction(); return }
                toSquareIndex = toSquare.tag
                if isValidPromototion() {
                    askForPromotionPiece { (pieceKind) in
                        guard let piece = pieceKind else { self.cancelDragAction(); return }
                        self.promotionPiece = pieceKind
                        let move = self.constructCurrentMove()!
                        self.delegate?.didMakeMove(move: move, animated: false)
                    }
                    isDragging = false
                } else if isValidMove() {
                    let move = constructCurrentMove()!
                    delegate?.didMakeMove(move: move, animated: false)
                    isDragging = false
                } else {
                    cancelDragAction()
                    SoundEffectPlayer().illegal()
                }
            }
        }
 
    }
}

struct LoadedPosition: Equatable {
    let fen: String
    let pushedMove: Move
}
