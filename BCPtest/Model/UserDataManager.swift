//
//  UserDataManager.swift
//  BCPtest
//
//  Created by Guest on 7/27/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import Foundation
import UIKit

class UserDataManager {
    
    // MARK: - Properties
    
    let defaults = UserDefaults.standard
    struct themeKeys {
        static let boardColor = "boardColor"
        static let buttonColor = "buttonColor"
        static let pieceStyle = "pieceStyle"
    }
    
    struct membershipKeys {
        static let rushLimit = "rushLimit"
        static let puzzleLimit = "puzzleLimit"
        static let membershipType = "membershipType"
    }
    
    struct stateKeys {
        static let appHasLaunched = "appHasLaunched"
    }
    
    // MARK: - Init
    
    func isFirstLaunch() -> Bool {
        return !defaults.bool(forKey: stateKeys.appHasLaunched)
    }
    
    func setDidLaunch() {
        defaults.set(true, forKey: stateKeys.appHasLaunched)
    }
    
    // MARK: - Interface
    
    func setBoardColor(boardColor: ColorTheme) {
        defaults.set(boardColor.rawValue, forKey: themeKeys.boardColor)
    }
    
    func getBoardColor() -> ColorTheme? {
        let rawValue = defaults.integer(forKey: themeKeys.boardColor)
        return ColorTheme(rawValue: rawValue)
    }
    
    func setButtonColor(buttonColor: ColorTheme) {
    /*
         buttonColor in BoardColor.cases
    */
        defaults.set(buttonColor.rawValue, forKey: themeKeys.buttonColor)
    }
    
    func getButtonColor() -> ColorTheme? {
        let rawValue = defaults.integer(forKey: themeKeys.buttonColor)
        return ColorTheme(rawValue: rawValue)
    }
    
    func setPieceStyle(pieceStyle: Int) {
    /*
         pieceStyle in PieceStyle.allCases.count
    */
        defaults.set(pieceStyle, forKey: themeKeys.pieceStyle)
    }
    
    func getPieceStyle() -> Int {
        let style = defaults.integer(forKey: themeKeys.pieceStyle)
        return style
    }
    
    // MARK: - Membership
    
    func setMembershipType(type: Int) {
        let currentMembership = defaults.integer(forKey: membershipKeys.membershipType)
        if currentMembership > type { return }
        let membership = MembershipType(rawValue: type)!
        defaults.set(type, forKey: membershipKeys.membershipType)
        defaults.set(membership.rushLimit, forKey: membershipKeys.rushLimit)
        defaults.set(membership.puzzleLimit, forKey: membershipKeys.puzzleLimit)
    }
    
    func getMembershipName() -> String {
        let type = defaults.integer(forKey: membershipKeys.membershipType)
        return MembershipType(rawValue: type)!.displayName
    }
    
    func getMembershipColor() -> UIColor {
        let type = defaults.integer(forKey: membershipKeys.membershipType)
        switch type {
        case 0: return .white
        case 1: return CommonUI().silverColor
        case 2: return CommonUI().goldColor
        default: return .white
        }
    }
    
    func hasReachedRushLimit() -> Bool {
        let rushLimit = defaults.integer(forKey: membershipKeys.rushLimit)
        print("Rush Limit: \(rushLimit)")
        return UserDBMS().getDailyRushCount() >= rushLimit
    }
    
    func hasReachedPuzzleLimit() -> Bool {
        let puzzleLimit = defaults.integer(forKey: membershipKeys.puzzleLimit)
        print("Puzzle Limit: \(puzzleLimit)")
        return UserDBMS().getDailyRatedPuzzleCount() >= puzzleLimit
    }
    
    
}
