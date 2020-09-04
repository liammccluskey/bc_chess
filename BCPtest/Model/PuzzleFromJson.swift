//
//  PuzzleFromJson.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import CoreData
import ChessKit

class PuzzlesFromJson {
    
    // MARK: - Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var puzzles: Puzzles?
    
    // MARK: - Init
    
    init() {
        guard let path = Bundle.main.path(forResource: "GeneratedPuzzles-5", ofType: "json") else {return}
        do {
            let jsonData = try Data.init(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            self.puzzles = try decoder.decode(Puzzles.self, from: jsonData)
        } catch {print(error)}
    }
    
    // MARK: - Interface
    
    func getPuzzleReferenceInRange(plusOrMinus: Int32, isBlindfold: Bool, forUser user: PuzzledUser) -> PuzzleReference? {
        let lower = isBlindfold ? user.puzzleB_Elo - plusOrMinus : user.puzzle_Elo - plusOrMinus
        let upper = isBlindfold ? user.puzzleB_Elo + plusOrMinus : user.puzzle_Elo + plusOrMinus
        let request = PuzzleReference.fetchRequest() as NSFetchRequest<PuzzleReference>
        let predicateRegular = NSPredicate(format:"eloRegular BETWEEN { \(lower) , \(upper) }")
        let predicateBlindfold = NSPredicate(format:"eloBlindfold BETWEEN { \(lower), \(upper)}")
        request.predicate = isBlindfold ? predicateBlindfold : predicateRegular
        do {
            let puzzlesInRange = try context.fetch(request)
            return puzzlesInRange.randomElement()
        } catch { print("Error: no puzzles in range \(lower) - \(upper)")}
        return nil
    }
    
    func getPuzzleReferenceInRange(lowerBound: Int, upperBound: Int, isBlindfold: Bool) -> PuzzleReference? {
        let request = PuzzleReference.fetchRequest() as NSFetchRequest<PuzzleReference>
        do {
            var pRefs = try context.fetch(request)
            if isBlindfold {
                pRefs = pRefs.filter{$0.eloBlindfold > lowerBound && $0.eloBlindfold < upperBound}
                print("isRegular: \(!isBlindfold), \(lowerBound) - \(upperBound): \(pRefs.count)")
                return pRefs.randomElement()
            } else {
                pRefs = pRefs.filter{$0.eloRegular > lowerBound && $0.eloRegular < upperBound}
                print("isRegular: \(!isBlindfold), \(lowerBound) - \(upperBound): \(pRefs.count)")
                return pRefs.randomElement()
            }
            
        } catch { print("Error: no puzzles in range \(lowerBound) - \(upperBound)")}
        return nil
    }
    
    func getDailyPuzzleReferenceInRange(lowerBound: Int, upperBound: Int, isBlindfold: Bool) -> PuzzleReference? {
        let request = PuzzleReference.fetchRequest() as NSFetchRequest<PuzzleReference>
        do {
            var pRefs = try context.fetch(request)
            if isBlindfold {
                pRefs = pRefs.filter{$0.eloBlindfold > lowerBound && $0.eloBlindfold < upperBound}
                if pRefs.count == 0 {
                    return nil
                } else {
                    return pRefs.randomElementForToday() as? PuzzleReference
                }
            } else {
                pRefs = pRefs.filter{$0.eloRegular > lowerBound && $0.eloRegular < upperBound}
                if pRefs.count == 0 {
                    return nil
                } else {
                    return pRefs.randomElementForToday() as? PuzzleReference
                }
            }
        } catch { print("Error: no puzzles in range \(lowerBound) - \(upperBound)")}
        return nil
    }
    
    func getPuzzleReferenceWithFilters(playerToMove: String, finalAnswerSAN: String) -> PuzzleReference? {
        let request = PuzzleReference.fetchRequest() as NSFetchRequest<PuzzleReference>
        do {
            var pRefs = try context.fetch(request)
            let filteredPRefs = pRefs.filter{
                let puzzle = getPuzzle(fromPuzzleReference: $0)
                return puzzle!.solution_moves.last!.answer_san == finalAnswerSAN
                    && puzzle!.player_to_move == playerToMove
            }
            return filteredPRefs.randomElement()
            
        } catch { print("couldn't fetch prefs from core data")}
        return nil
    }
    
    func getPuzzle(fromPuzzleReference puzzleReference: PuzzleReference) -> Puzzle? {
        let type = Int(puzzleReference.puzzleType)
        let index = Int(puzzleReference.puzzleIndex)
        switch type {
        case 0:return puzzles!.m1[index]
        case 1: return puzzles!.m2[index]
        case 2: return puzzles!.m3[index]
        case 3: return puzzles!.m4[index]
        case 4: return puzzles!.m5[index]
        case 5: return puzzles!.m6[index]
        case 6: return puzzles!.m7[index]
        case 7: return puzzles!.m8[index]
        default: return nil
        }
    }
    
    func savePuzzlesToCoreData() {
        savePuzzleReferences(puzzleType: 0, puzzles: puzzles!.m1)
        savePuzzleReferences(puzzleType: 1, puzzles: puzzles!.m2)
        savePuzzleReferences(puzzleType: 2, puzzles: puzzles!.m3)
        savePuzzleReferences(puzzleType: 3, puzzles: puzzles!.m4)
        savePuzzleReferences(puzzleType: 4, puzzles: puzzles!.m5)
        savePuzzleReferences(puzzleType: 5, puzzles: puzzles!.m6)
        savePuzzleReferences(puzzleType: 6, puzzles: puzzles!.m7)
        savePuzzleReferences(puzzleType: 7, puzzles: puzzles!.m8)
    }
    
    fileprivate func savePuzzleReferences(puzzleType: Int, puzzles: [Puzzle]) {
        var puzzleRefs = [PuzzleReference]()
        print("Length \(puzzleType + 1):  \(puzzles.count)")
        for i in 0..<puzzles.count {
            let puzzle = puzzles[i]
            let puzzleRef = PuzzleReference(context: context)
            let m1buffer = puzzleType == 0 ? Int.random(in: 100...200)*(-1) : 0
            puzzleRef.eloRegular = Int32(450*(puzzleType + 1) + m1buffer + Int.random(in: 0...300)) // 250 - 
            puzzleRef.eloBlindfold = Int32(75*puzzle.piece_count + 250*(puzzleType + 1) + Int.random(in: 0...100))
            puzzleRef.puzzleType = Int32(puzzleType)
            puzzleRef.puzzleIndex = Int32(i)
            puzzleRefs.append(puzzleRef)
        }
        print("Puzzle count type (\(puzzleType)): \(puzzleRefs.count)")
        do { try context.save() }
        catch { print("Error saving puzzles references of type: \(puzzleType)")}
    }
    
    
}
    
// tier 0
struct Puzzles: Codable {
    let m1: [Puzzle]
    let m2: [Puzzle]
    let m3: [Puzzle]
    let m4: [Puzzle]
    let m5: [Puzzle]
    let m6: [Puzzle]
    let m7: [Puzzle]
    let m8: [Puzzle]
    
}

// tier 1
struct Puzzle: Codable {
    let position: Position
    let solution_moves: [WBMove]
    let player_to_move: String
    let piece_count: Int
    let fen: String
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
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wp")!
        case .bp: // 1
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bp")!
        case .wn: // 2
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wn")!
        case .bn: // 3
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bn")!
        case .wb: // 4
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wb")!
        case .bb: // 5
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bb")!
        case .wr: // 6
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wr")!
        case .br: // 7
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "br")!
        case .wq: // 8
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wq")!
        case .bq: // 9
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bq")!
        case .wk: // 10
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wk")!
        case .bk: // 11
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bk")!
        }
    }
}

enum PieceName: String {
    case P, p, N, n, B, b, R, r, Q, q, K, k
    var image: UIImage {
        switch self {
        case .P: // 0
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wp")!
        case .p: // 1
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bp")!
        case .N: // 2
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wn")!
        case .n: // 3
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bn")!
        case .B: // 4
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wb")!
        case .b: // 5
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bb")!
        case .R: // 6
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wr")!
        case .r: // 7
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "br")!
        case .Q: // 8
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wq")!
        case .q: // 9
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bq")!
        case .K: // 10
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "wk")!
        case .k: // 11
            return UIImage(named: PieceStyleTheme(rawValue: pieceStyle)!.fileExtension + "bk")!
        }
    }
    var unicode: String {
        switch self {
        case .P: return "\u{2659}"
        case .p: return "\u{265F}"
        case .N: return "\u{2658}"
        case .n: return "\u{265E}"
        case .B: return "\u{2657}"
        case .b: return "\u{265D}"
        case .R: return "\u{2656}"
        case .r: return "\u{265C}"
        case .Q: return "\u{2655}"
        case .q: return "\u{265B}"
        case .K: return "\u{2654}"
        case .k: return "\u{265A}"
        }
    }
}


extension Date {
    var dayOfYear: Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: self)!
    }
}

extension Array {
    func randomElementForToday() -> Any {
        let count = self.count
        let dayOfYear = Date().dayOfYear
        return self[dayOfYear % count]
    }
}



