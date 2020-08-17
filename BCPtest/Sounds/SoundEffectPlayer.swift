//
//  SoundEffectPlayer.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/16/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import AVFoundation
import UIKit

var audioPlayer: AVAudioPlayer?
class SoundEffectPlayer {
    
    func  pieceMove() {
        playSound(forResource: "clicksound")
    }
    
    func correct() {
        playSound(forResource: "correct")
    }
    
    func incorrect() {
        playSound(forResource: "incorrect")
    }
    
    func vibrateDevice() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // MARK: - Helper
    
    func playSound(forResource: String, ofType: String="mp3") {
        let path = Bundle.main.path(forResource: forResource, ofType: ofType)!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch { print(error) }
    }
}
