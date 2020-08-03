//
//  Protocols.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/18/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

protocol ChessBoardDelegate {
    func didMakeMove(moveUCI: String)
    func didFinishShowingSolution()
}

protocol ThemeTableDelegate {
    func didSubmitChangeAt(indexPath: IndexPath)
}

protocol DailyPuzzlesCollectionDelegate {
    func didSelectPuzzle(puzzle: Puzzle)
}

// Database
protocol UserDBMSDelegate {
    func sendUser(user: User)
}
