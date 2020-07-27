//
//  PuzzleFromJson.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class PuzzlesFromJson {
    
    // MARK: - Properties
    
    var puzzles: Puzzles?
    
    // MARK: - Init
    
    init() {
        guard let path = Bundle.main.path(forResource: "puzzlesM1234", ofType: "json") else {return}
        do {
            let jsonData = try Data.init(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            self.puzzles = try decoder.decode(Puzzles.self, from: jsonData)
        } catch {print(error)}
    }
    
    // MARK: - Interface
    
    func getPuzzle(matePly: Int) -> Puzzle? {
        switch matePly {
        case 1:
            return puzzles!.m1.randomElement()
        case 2:
            return puzzles!.m2.randomElement()
        case 3:
            return puzzles!.m3.randomElement()
        case 4:
            return puzzles!.m4.randomElement()
        default:
            return nil
        }
    }
    
    
}
    
// tier 0
struct Puzzles: Codable {
    let m1: [Puzzle]
    let m2: [Puzzle]
    let m3: [Puzzle]
    let m4: [Puzzle]
}

// tier 1
struct Puzzle: Codable {
    let position: Position
    let solution_moves: [WBMove]
    let player_to_move: String
    let piece_count: Int
}

// tier 2
struct Position: Codable {
    let P: [String]
    let N: [String]
    let B: [String]
    let R: [String]
    let Q: [String]
    let K: [String]
    let p: [String]
    let n: [String]
    let b: [String]
    let r: [String]
    let q: [String]
    let k: [String]
    func getSquaresFor(isWhitePosition: Bool, pieceTag: Int) -> [String] {
        let piecesSquares = [P,p,N,n,B,b,R,r,Q,q,K,k]
        return piecesSquares[pieceTag]
    }
}

struct WBMove: Codable {
    let answer_uci: String
    let answer_san: String
    let response_san: String
    let response_uci: String
}

// data structures
enum PieceType: Int {
    case wp, bp, wn, bn, wb, bb, wr, br, wq, bq, wk, bk
    var image: UIImage {
        switch self {
        case .wp: // 0
            return UIImage(named: piece_image_extension + "wp")!
        case .bp: // 1
            return UIImage(named: piece_image_extension + "bp")!
        case .wn: // 2
            return UIImage(named: piece_image_extension + "wn")!
        case .bn: // 3
            return UIImage(named: piece_image_extension + "bn")!
        case .wb: // 4
            return UIImage(named: piece_image_extension + "wb")!
        case .bb: // 5
            return UIImage(named: piece_image_extension + "bb")!
        case .wr: // 6
            return UIImage(named: piece_image_extension + "wr")!
        case .br: // 7
            return UIImage(named: piece_image_extension + "br")!
        case .wq: // 8
            return UIImage(named: piece_image_extension + "wq")!
        case .bq: // 9
            return UIImage(named: piece_image_extension + "bq")!
        case .wk: // 10
            return UIImage(named: piece_image_extension + "wk")!
        case .bk: // 11
            return UIImage(named: piece_image_extension + "bk")!
        }
    }
}

enum PieceName: String {
    case P, p, N, n, B, b, R, r, Q, q, K, k
    var image: UIImage {
        switch self {
        case .P: // 0
            return UIImage(named: piece_image_extension + "wp")!
        case .p: // 1
            return UIImage(named: piece_image_extension + "bp")!
        case .N: // 2
            return UIImage(named: piece_image_extension + "wn")!
        case .n: // 3
            return UIImage(named: piece_image_extension + "bn")!
        case .B: // 4
            return UIImage(named: piece_image_extension + "wb")!
        case .b: // 5
            return UIImage(named: piece_image_extension + "bb")!
        case .R: // 6
            return UIImage(named: piece_image_extension + "R")!
        case .r: // 7
            return UIImage(named: piece_image_extension + "br")!
        case .Q: // 8
            return UIImage(named: piece_image_extension + "wq")!
        case .q: // 9
            return UIImage(named: piece_image_extension + "bq")!
        case .K: // 10
            return UIImage(named: piece_image_extension + "wk")!
        case .k: // 11
            return UIImage(named: piece_image_extension + "bk")!
        }
    }
}



