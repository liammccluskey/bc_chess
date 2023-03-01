//
//  Protocols.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/18/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import ChessKit

protocol ChessBoardDelegate {
    func didMakeMove(moveUCI: String)
    func didFinishShowingSolution()
}

protocol BoardDelegate {
    func didMakeMove(move: Move, animated: Bool)
}

protocol ThemeTableDelegate {
    func didSubmitChangeAt(indexPath: IndexPath)
}

protocol ProgressTableDelegate {
    func didSelectPuzzle(type: Int, index: Int)
}

protocol SettingsTableDelegate {
    func didSelectRow(rowIndex: Int)
}

protocol DailyPuzzlesCollectionDelegate {
    func didSelectPuzzle(puzzle: Puzzle, puzzleReference: PuzzleReference, puzzleNumber: Int, piecesHidden: Bool, publicAttemptsInfo: DailyPuzzlesInfo?)
    func didMoveToPage(pageNumber: Int)
}

protocol SignInDelegate {
    func notifyOfSignIn()
}

protocol SignOutDelegate {
    func notifyOfSignOut()
}

protocol PostRushDelegate {
    func didSelectPlayAgain()
    func didSelectExit()
}

protocol LimitReachedDelegate {
    func didDismiss()
    func didSelectUpgrade()
}

protocol CommonMovesTableDelegate {
    func didSelectMove(move: CommonMove)
    func didSelectGame(game: TopGame)
    func didReachExplorerLimit()
    func didNotReachExplorerLimit()
}

protocol SlideMenuTableDelegate {
    func didSelectController(controllerIndex: Int)
}

protocol MainViewDelegate {
    func didSelectMenu() 
}
// Database
protocol UserDBMSDelegate {
    func sendUser(user: User?)
}

protocol PublicDBMSDelegate {
    func sendRankedUsers(rankedUsers: RankedUsers?)
    func sendDailyPuzzlesInfo(info: DailyPuzzlesInfo?)
}



