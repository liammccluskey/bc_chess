//
//  homepageVC.swift
//  BlindfoldChessPuzzles
//
//  Created by Marty McCluskey on 12/9/19.
//  Copyright © 2019 Marty McCluskey. All rights reserved.
//

import UIKit

import AVFoundation

class homepageVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pInfo = puzzleInfo()
        
        let utterance = AVSpeechUtterance(string: "e2, e4")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        //utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    var pInfo: puzzleInfo?
    
    
    
    @IBOutlet weak var numTurnsField: UITextField!
    @IBOutlet weak var genPuzzButton: UIButton!
    
    
    
    // get value for playerMove
    func getPlayerMove() -> String {
        if let pDir = self.pInfo!.folderPath {
            if let filepath = Bundle.main.path(forResource: "playerMove", ofType: ".txt", inDirectory: pDir) {
                do {
                    let contents = try String(contentsOfFile: filepath)
                    return contents
                } catch {
                    // contents could not be loaded
                }
            } else {
                // example.txt not found!
            }
        }
        return "test"
    }
    
    func setPFilePath () -> Bool{
        let fM = FileManager.default
        if let numTurns = numTurnsField.text {
            if let pAudioPath = Bundle.main.path(forResource:"PuzzleAudio/\(numTurns)", ofType: nil)  {
                do{
                    let files = try fM.contentsOfDirectory(atPath: pAudioPath)  as [String]
                    if let pFolder = files.randomElement() {
                        self.pInfo?.folderPath = "PuzzleAudio/\(numTurns)/\(pFolder)"
                    return true
                    }
                } catch {
                    // do something u stupid fool
                }
            }
            
        }
        return false
    }
    
    //make the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.setPFilePath()
        
        if let folderPath = self.pInfo!.folderPath {
            print(folderPath)
        }
        
        self.pInfo?.numTurns = numTurnsField.text
        self.pInfo?.playerMove = self.getPlayerMove()
        
        let pVC = segue.destination as! puzzleVC
        pVC.pInfo = self.pInfo
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if  let numTurns = numTurnsField.text, numTurns.count >= 1{
            // first condition is met
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enter puzzle length. Number must be in range (3 - 24).", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        if self.setPFilePath() == true {
            return true
        }else {
            let alertController = UIAlertController(title: "Error", message: "No available puzzles of this length", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
    }
    
    
}
