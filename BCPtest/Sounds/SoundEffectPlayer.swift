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
    
    // MARK: - Sounds
    
    func pieceMove() {
        playSound(forResource: "move_self")
        vibrateLight()
    }
    
    func capture() {
        playSound(forResource: "capture")
        vibrateLight()
    }
    
    func moveCheck() {
        playSound(forResource: "move_check")
        vibrateLight()
    }
    
    func moveSelf() {
        playSound(forResource: "move_self")
        vibrateLight()
    }
    
    func illegal() {
        playSound(forResource: "illegal")
    }
    
    func correct() {
        playSound(forResource: "resultGood")
    }
    
    func incorrect() {
        playSound(forResource: "resultBad")
    }
    
    func vibrateDevice() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Haptic Feedback
    
    func vibrateLight() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Helper
    
    func playSound(forResource: String, ofType: String="mp3") {
        let path = Bundle.main.path(forResource: forResource, ofType: ofType)!
        let url = URL(fileURLWithPath: path)
        do {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try? AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch { print(error) }
        
    }
}
