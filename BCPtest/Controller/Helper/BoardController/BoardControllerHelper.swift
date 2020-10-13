//
//  BoardControllerHelper.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 9/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import ChessKit

class BoardControllerHelper {
    
    // MARK: - Interface
    
    func getTagOfPawnCapturedEnPasant(game: Game, moveToPush: Move) -> Int? {
        let toSquareCoordinate = moveToPush.to.coordinate
        let toSquareIndex = coordinateToIndex(coordinate: toSquareCoordinate)
        if let enPasantSquare = game.position.state.enPasant {
            if enPasantSquare.coordinate == toSquareCoordinate {
                let capturedPawnIndex = toSquareIndex/8 == 2 ? toSquareIndex + 8 : toSquareIndex - 8
                return capturedPawnIndex
            }
        }
        return nil
    }
    
    // MARK: - Helper
    
    func coordinateToIndex(coordinate: String) -> Int {
        let file = coordinate.first!
        let rank = Int(String(coordinate.last!))!
        let files: [Character: Int] = ["a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7]
        return (rank-1)*8 + files[file]!
    }
    
    func indexToCoordinate(index: Int) -> String {
        let rank = index/8 + 1
        let fileIndex = index % 8
        let files = ["a","b","c","d","e","f","g","h"]
        let file = files[fileIndex]
        return "\(file)\(rank)"
    }
    
}
