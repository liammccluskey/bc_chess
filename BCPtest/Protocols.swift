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

protocol ProgressTableDelegate {
    func didSelectPuzzle(type: Int, index: Int)
}

protocol DailyPuzzlesCollectionDelegate {
    func didSelectPuzzle(puzzle: Puzzle)
}

protocol SignInDelegate {
    func notifyOfSignIn()
}

protocol SignOutDelegate {
    func notifyOfSignOut()
}

// Database
protocol UserDBMSDelegate {
    func sendUser(user: User?)
}



