//
//  ChessBoardImageController.swift
//  BCPtest
//
//  Created by Guest on 8/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

import UIKit
import ChessKit
import AVFoundation

class ChessBoardImageController: UIViewController {
    
    var stationaryPieceBaseWidth: CGFloat!
    var stationaryPieceSizeScale: CGFloat!
    var stationaryPieceOffsetY: CGFloat!
    var stationaryPieceOffsetX: CGFloat!
   
    var game: Game!
    
    var sideLength: CGFloat!
    var frame: CGRect?
    
    // MARK: - Properties
    var shouldHidePieces: Bool!
    var layoutColor: Int! // 0-> black, 1-> white
    
    var colorTheme: ColorTheme!
    
    var squareIVs: [UIImageView] = []
    var pieceIVs: [UIImageView] = []
    
    var eyeView: UIImageView! = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        let modeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .heavy, scale: .large)
        iv.image = UIImage(systemName: "eye.slash", withConfiguration: modeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(CommonUI().blackColor)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // MARK: - Init/Interface
    
    init(frame: CGRect?=nil, sideLength: CGFloat, fen: String?, shouldHidePieces: Bool, boardTheme: ColorTheme? = nil) {
        self.frame = frame
        self.sideLength = sideLength
        self.layoutColor = 1
        self.shouldHidePieces = shouldHidePieces
        if let theme = boardTheme {
            self.colorTheme = theme
        } else {
            self.colorTheme = UserDataManager().getBoardColor()!
        }
        if let fen = fen {
            let position = FenSerialization.default.deserialize(fen: fen)
            self.game = Game(position: position)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let frame = frame {
            self.view.frame = frame
        } else {
            self.view.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
        }
        setPieceImageScaleFactors(forFrame: view.frame)
        configureUI()
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
        if shouldHidePieces == false {
            configPieceIVs()
        }
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
    }
    
    func configBoardImage() {
        let iv = UIImageView()
        iv.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = colorTheme.image.withRenderingMode(.alwaysOriginal)
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
            view.addSubview(iv)
            squareIVs.append(iv)
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
    
    // MARK: - Helper
        
    func getSquareColor(squareIndex: Int) -> UIColor {
        if (squareIndex / 8)  % 2 == 0 {
            return squareIndex % 2 == 0 ? colorTheme.darkSquareColor : colorTheme.lightSquareColor
        } else {
            return squareIndex % 2 != 0 ? colorTheme.darkSquareColor : colorTheme.lightSquareColor
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
    
    // MARK: - Interface
    
    func redrawBlankBoard() {
        view.subviews.forEach({$0.removeFromSuperview()})
        configBoardImage()
        configSquareIVs()
    }
}



