//
//  UserDataManager.swift
//  BCPtest
//
//  Created by Guest on 7/27/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import Foundation

class UserDataManager {
    
    // MARK: - Properties
    
    let defaults = UserDefaults.standard
    struct themeKeys {
        static let boardColor = "boardColor"
        static let buttonColor = "buttonColor"
        static let pieceStyle = "pieceStyle"
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
    /*
         boardColor in BoardColor.cases
    */
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
}
