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
        guard let path = Bundle.main.path(forResource: "puzzles", ofType: "json") else {return}
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
        default:
            return nil
        }
    }
    
    
}
 /*
        let jsonData = """
{"position": {"N": [], "B": [], "R": [], "P": ["b3", "a2"], "Q": [], "K": ["c1"], "n": ["f6", "a6"], "b": [], "r": ["g7", "e2"], "p": ["f7", "c7", "a7", "h6", "a5"], "q": [], "k": ["b7"]}, "solution_moves": [{"answer_uci": "g7g1", "answer_san": "Rg1#", "response": "complete"}], "player_to_move": "black", "piece_count": 13}
""".data(using: .utf8)!
        
        do {
            let decoder = JSONDecoder()
            let puzzle = try decoder.decode(Puzzle.self, from: jsonData)
            print(puzzle.position)
            
        } catch {print(error)}
    }
*/
    
// tier 0
struct Puzzles: Codable {
    let m1: [Puzzle]
    let m2: [Puzzle]
    let m3: [Puzzle]
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
}

struct WBMove: Codable {
    let answer_uci: String
    let answer_san: String
    let response_san: String
}



