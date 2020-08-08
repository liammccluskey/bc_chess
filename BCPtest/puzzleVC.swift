//
//  puzzleVC.swift
//  BlindfoldChessPuzzles
//
//  Created by Marty McCluskey on 12/9/19.
//  Copyright © 2019 Marty McCluskey. All rights reserved.
//

import UIKit
import AVFoundation

class puzzleVC: UIViewController {
    
    var audioFileSound: AVAudioPlayer?
    var pInfo: puzzleInfo?
    
    @IBOutlet weak var numTurnsLabel: UILabel!
    @IBOutlet weak var playerMoveLabel: UILabel!
    @IBOutlet weak var boardImage: UIImageView!
    
    @IBOutlet weak var showPuzzleButton: UIButton!
    @IBOutlet weak var showSolutionButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numTurnsLabel.text = pInfo!.numTurns!
        self.playerMoveLabel.text = pInfo!.playerMove!
        
        print(self.pInfo!.folderPath!)
        
    }
    
    //plays the moves audio file
    @IBAction func playMovesPress(_ sender: Any) {
        if let pDir = self.pInfo!.folderPath {
            let pMovesPath = Bundle.main.path(forResource: "puzzleMoves", ofType: ".mp3", inDirectory: pDir )
            let url = URL(fileURLWithPath: pMovesPath!)
            
            do {
                audioFileSound = try AVAudioPlayer(contentsOf: url)
                audioFileSound?.play()
            } catch {
                print("couldn't play sound")
            }
        }
        
    }
    
    //plays the puzzle solution audio file
    @IBAction func playSolutionPress(_ sender: Any) {
        if let pDir = self.pInfo!.folderPath {
            let pSolPath = Bundle.main.path(forResource: "puzzleSolution", ofType: ".mp3", inDirectory: pDir )
            let url = URL(fileURLWithPath: pSolPath!)
            
            do {
                audioFileSound = try AVAudioPlayer(contentsOf: url)
                audioFileSound?.play()
            } catch {
                print("couldn't play sound")
            }
        }
    }
    
    // set boardLabel background as puzzle.pdf
    @IBAction func showPuzzlePress(_ sender: Any) {
        let buttonTitle = showPuzzleButton.currentTitle!
        if buttonTitle == "Show Puzzle" {
            if let pDir = self.pInfo!.folderPath {
                if let imagePath = Bundle.main.path(forResource: "puzzle", ofType: ".pdf", inDirectory: pDir ){
                    let imageURL = URL(fileURLWithPath: imagePath)
                    let img = self.drawPDFfromURL(url: imageURL)
                    //self.boardLabel.backgroundColor = UIColor(patternImage: img!)
                    self.boardImage.image = img
                }
            }
            self.showPuzzleButton.setTitle("Hide Puzzle", for: .normal)
        } else if buttonTitle == "Hide Puzzle" {
            self.boardImage.image = nil
            self.showPuzzleButton.setTitle("Show Puzzle", for: .normal)
        }
    }
    
    // set boardLabel background as solution.pdf
    @IBAction func showSolutionPress(_ sender: Any) {
        let buttonTitle = showSolutionButton.currentTitle!
        if buttonTitle == "Show Solution" {
            if let pDir = self.pInfo!.folderPath {
                if let imagePath = Bundle.main.path(forResource: "solution", ofType: ".pdf", inDirectory: pDir ){
                    let imageURL = URL(fileURLWithPath: imagePath)
                    let img = self.drawPDFfromURL(url: imageURL)
                    //self.boardLabel.backgroundColor = UIColor(patternImage: img!)
                    self.boardImage.image = img
                }
            }
            self.showSolutionButton.setTitle("Hide Solution", for: .normal)
        } else if buttonTitle == "Hide Solution" {
            self.boardImage.image = nil
            self.showSolutionButton.setTitle("Show Solution", for: .normal)
        }
    }
    
    
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img
    }
}


