//
//  puzzleInfo.swift
//  BlindfoldChessPuzzles
//
//  Created by Marty McCluskey on 12/9/19.
//  Copyright © 2019 Marty McCluskey. All rights reserved.
//

import UIKit

class puzzleInfo: NSObject {
    
    var folderPath: String?// path to this specific puzzle's audio
    var numTurns: String?// contains # of turns in the game
    var playerMove: String? // contains 'black' or 'white': whoever is player to move
    
}
