//
//  PuzzleRushController.swift
//  BCPtest
//
//  Created by Guest on 8/6/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import CoreData

class PuzzleRushController: UIViewController {
    
    // MARK: - Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var startMinutes: Int!
    var piecesHidden: Bool!
    var onSolutionMoveIndex: Int = 0
    var stateIsIncorrect = false
    var timer: Timer!
    var pregameTimer: Timer!
    var pregameCountdown: Int!
    var puzzledUser: PuzzledUser!
    
    var numCorrect: Int = 0
    var numIncorrect: Int = 0
    var secondsRemaining: Int!
    var lowerBoundFetch: Int!
    var upperBoundFetch: Int!
    var pRef: PuzzleReference?
    var currentPuzzle: Puzzle!
    
    let pregameCountdownLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: fontString, size: 80)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = .black
        l.text = "3"
        l.alpha = 0.8
        return l
    }()
    
    var solutionLabel: UILabel!
    var playerToMoveLabel: UILabel!
    var correctnessLabel: UILabel!
    var numCorrectLabel: UILabel!
    var timeRemainingLabel: UILabel!
    var incorrectMarksView: IncorrectMarksView!
    var puzzleRatingLabel: UILabel!
    
    // stack 1
    var chessBoardController: ChessBoardController!
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!
    
    // bottom buttons
    var exitButton: UIButton!
    var buttonStack: UIStackView! // quit
    
    
    // MARK: - Init
    
    init(piecesHidden: Bool, minutes: Int) {
        super.init(nibName: nil, bundle: nil)
        self.piecesHidden = piecesHidden
        self.startMinutes = minutes // either 3 or 5
        self.fetchNextPuzzle()
        self.secondsRemaining = startMinutes*60
        self.puzzledUser = UserDBMS().getPuzzledUser()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
        
        configureUI()
        setUpAutoLayout()
        
        pregameCountdown = 3
        pregameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pregameTimerAction), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Config
    
    func configureUI() {
        configureNavigationBar()
        
        let prUI = PuzzleRushUI()
        let pUI = PuzzleUI()
        // stack
        playerToMoveLabel = PuzzleUI().configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.addSubview(playerToMoveLabel)
        
        numCorrectLabel = prUI.configNumCorrectLabel()
        numCorrectLabel.setNumCorrect(numCorrect: 0)
        correctnessLabel = prUI.configCorrectnessLabel()
        correctnessLabel.alpha = 0
        timeRemainingLabel = prUI.configTimeRemainingLabel()
        timeRemainingLabel.setTimeRemaining(secondsLeft: secondsRemaining)
        incorrectMarksView = IncorrectMarksView()
        incorrectMarksView.numIncorrect = 0
        solutionLabel = pUI.configSolutionLabel()
        solutionLabel.text = " "
        solutionLabel.translatesAutoresizingMaskIntoConstraints = false
        //puzzleRatingLabel = pUI.configRatingLabel()
        //puzzleRatingLabel.setPuzzleRating(forPuzzleReference: pRef!, isBlindfold: piecesHidden)
        
        view.addSubview(numCorrectLabel)
        view.addSubview(correctnessLabel)
        view.addSubview(timeRemainingLabel)
        view.addSubview(incorrectMarksView)
        view.addSubview(solutionLabel)
        //view.addSubview(puzzleRatingLabel)
        
        chessBoardController = ChessBoardController(position: currentPuzzle.position, showPiecesInitially: !piecesHidden)
        chessBoardController.delegate = self
        chessBoardController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chessBoardController.view)
        
        positionTableW = PositionTableController(puzzle: currentPuzzle, isWhite: true)
        positionTableB = PositionTableController(puzzle: currentPuzzle, isWhite: false)
        view.addSubview(positionTableW.tableView)
        view.addSubview(positionTableB.tableView)
        
        // buttons
        exitButton = PuzzleUI().configureButton(title: "  QUIT  ", imageName: "arrow.left.square")
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton])
        view.addSubview(buttonStack)
        
        if piecesHidden == false {
            positionTableB.tableView.isHidden = true
            positionTableW.tableView.isHidden = true
        }
        view.backgroundColor = CommonUI().blackColorLight
        pregameCountdownLabel.text = "3"
        view.addSubview(pregameCountdownLabel)
    }
    
    func setUpAutoLayout() {
        pregameCountdownLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pregameCountdownLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pregameCountdownLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pregameCountdownLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        let upperPadding: CGFloat = piecesHidden ? 8 : 40
        buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 3).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -3).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 3).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        playerToMoveLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        playerToMoveLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerToMoveLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerToMoveLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        correctnessLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        correctnessLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        correctnessLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        correctnessLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        numCorrectLabel.topAnchor.constraint(equalTo: playerToMoveLabel.bottomAnchor, constant: upperPadding).isActive = true
        numCorrectLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        timeRemainingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        timeRemainingLabel.centerYAnchor.constraint(equalTo: numCorrectLabel.centerYAnchor).isActive = true
        
        if piecesHidden {
            incorrectMarksView.topAnchor.constraint(equalTo: playerToMoveLabel.bottomAnchor, constant: 12).isActive = true
            //incorrectMarksView.leftAnchor.constraint(equalTo: numCorrectLabel.rightAnchor, constant: 10).isActive = true
            incorrectMarksView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            incorrectMarksView.widthAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
            //incorrectMarksView.centerYAnchor.constraint(equalTo: numCorrectLabel.centerYAnchor).isActive = true
            //incorrectMarksView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            incorrectMarksView.topAnchor.constraint(equalTo: numCorrectLabel.bottomAnchor, constant: 10).isActive = true
            incorrectMarksView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
            //incorrectMarksView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            incorrectMarksView.widthAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
            //incorrectMarksView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        
        //puzzleRatingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
       // puzzleRatingLabel.topAnchor.constraint(equalTo: timeRemainingLabel.bottomAnchor, constant: 10).isActive = true
        
        let sidePadding:CGFloat = piecesHidden ? 20 : 0
        chessBoardController.view.topAnchor.constraint(equalTo: timeRemainingLabel.bottomAnchor, constant: upperPadding).isActive = true
        chessBoardController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: sidePadding).isActive = true
        chessBoardController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -sidePadding).isActive = true
        
        solutionLabel.topAnchor.constraint(equalTo: chessBoardController.view.bottomAnchor, constant: 5).isActive = true
        solutionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        solutionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        
        positionTableW.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -3).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: solutionLabel.bottomAnchor, constant: 5).isActive = true
        positionTableW.tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
        
        positionTableB.tableView.leftAnchor.constraint(equalTo:  view.centerXAnchor, constant: 0).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 3).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: solutionLabel.bottomAnchor, constant: 5).isActive = true
        positionTableB.tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    func configurePageForNewPuzzle() {
        playerToMoveLabel.text = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
        playerToMoveLabel.backgroundColor = currentPuzzle.player_to_move == "white" ? .lightGray : .black //CommonUI().blackColorLight
        playerToMoveLabel.textColor = currentPuzzle.player_to_move == "white" ? .black : .lightGray
        positionTableW.setData(puzzle: currentPuzzle, isWhite: true)
        positionTableB.setData(puzzle: currentPuzzle, isWhite: false)
        positionTableW.tableView.reloadData()
        positionTableB.tableView.reloadData()
        //puzzleRatingLabel.setPuzzleRating(forPuzzleReference: pRef!, isBlindfold: piecesHidden)
        chessBoardController.setNewPosition(position: currentPuzzle.position, piecesHidden: piecesHidden)
        solutionLabel.text = " "
    }
    
    func restartPuzzleAttempt() {
        onSolutionMoveIndex = 0
        stateIsIncorrect = false
        chessBoardController.setButtonInteraction(isEnabled: true)
    }
    
    func fetchNextPuzzle() {
        lowerBoundFetch = 500 + (numCorrect/3)*100 - 50
        upperBoundFetch = 500 + (numCorrect/3)*100 + 50
        var foundPuzzle = false
        while foundPuzzle == false {
            pRef = PFJ.getPuzzleReferenceInRange(lowerBound: lowerBoundFetch, upperBound: upperBoundFetch, isBlindfold: piecesHidden)
            if pRef != nil { foundPuzzle = true; break }
            else { upperBoundFetch += 100 }
        }
        currentPuzzle = PFJ.getPuzzle(fromPuzzleReference: pRef!)
    }
    
    // MARK: - Selectors
    
    @objc func pregameTimerAction() {
        pregameCountdown-=1
        if pregameCountdown > 0 {
            pregameCountdownLabel.text = String(pregameCountdown)
        } else if pregameCountdown == 0 {
            pregameCountdownLabel.text = "GO!"
        } else if pregameCountdown == -1 {
            pregameTimer.invalidate()
            pregameCountdownLabel.removeFromSuperview()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeRemaining), userInfo: nil, repeats: true)
            view.isUserInteractionEnabled = true
        }
    }
    
    @objc func updateTimeRemaining() {
        secondsRemaining-=1
        timeRemainingLabel.setTimeRemaining(secondsLeft: secondsRemaining)
        if secondsRemaining == 0 {
            // puzzle is timedout do something
            timer.invalidate()
            chessBoardController.setButtonInteraction(isEnabled: false)
            saveRushAttempt(didTimeout: true, didStrikeout: false)
            let controller = PostRushController()
            controller.delegate = self
            self.present(controller, animated: true)
        }
    }
    
    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Selector Helper
    
    
}

extension PuzzleRushController: ChessBoardDelegate {
    func didFinishShowingSolution() {
    }
    
    func didMakeMove(moveUCI: String) {
        let solutionUCI = currentPuzzle.solution_moves[onSolutionMoveIndex].answer_uci
        if solutionUCI.contains(moveUCI) {
            let solutionMove: WBMove = currentPuzzle.solution_moves[onSolutionMoveIndex]
            chessBoardController.pushMove(wbMove: solutionMove, firstMovingPlayer: currentPuzzle.player_to_move)
            onSolutionMoveIndex = onSolutionMoveIndex + 1
            solutionLabel.text = PuzzleUI().configSolutionText(solutionMoves: currentPuzzle.solution_moves, onIndex: onSolutionMoveIndex)
            if onSolutionMoveIndex == currentPuzzle.solution_moves.count {
                didCompletePuzzle(wasCorrect: true)
            }
        } else {
            let playerIsWhite = currentPuzzle.player_to_move == "white" ? true : false
            chessBoardController.displayMove(moveUCI: moveUCI, playerIsWhite: playerIsWhite)
            chessBoardController.setButtonInteraction(isEnabled: false)
            stateIsIncorrect = true
            didCompletePuzzle(wasCorrect: false)
        }
    }
}

extension PuzzleRushController {
    func didCompletePuzzle(wasCorrect: Bool) {
        correctnessLabel.setCorrectness(isCorrect: wasCorrect)
        UIView.animate(withDuration: 0.2, animations: {
            self.correctnessLabel.alpha = 1
            if wasCorrect {
                self.numCorrect+=1
                self.numCorrectLabel.setNumCorrect(numCorrect: self.numCorrect)
            } else {
                self.numIncorrect+=1
                self.incorrectMarksView.numIncorrect = self.numIncorrect
            }
        }) { (_) in
            if self.numIncorrect == 3 {
                self.timer.invalidate()
                self.saveRushAttempt(didTimeout: false, didStrikeout: true)
                let controller = PostRushController()
                controller.delegate = self
                self.present(controller, animated: true)
                
            } else {
                self.restartPuzzleAttempt()
                self.fetchNextPuzzle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                    self.correctnessLabel.alpha = 0
                    self.configurePageForNewPuzzle()
                }
            }

        }
    }
    
    func saveRushAttempt(didTimeout: Bool, didStrikeout: Bool) {
        if startMinutes == 3 {
            let rushAttempt = Rush3Attempt(context: context)
            rushAttempt.timestamp = Date()
            rushAttempt.didStrikeout = didStrikeout
            rushAttempt.didTimeout = didTimeout
            rushAttempt.numCorrect = Int32(numCorrect)
            rushAttempt.piecesHidden = piecesHidden
            rushAttempt.puzzledUser = puzzledUser
            do { try context.save() }
            catch { print("Error: couldn't save rush3attempt")}
        } else if startMinutes == 5 {
            let rushAttempt = Rush5Attempt(context: context)
            rushAttempt.timestamp = Date()
            rushAttempt.didStrikeout = didStrikeout
            rushAttempt.didTimeout = didTimeout
            rushAttempt.numCorrect = Int32(numCorrect)
            rushAttempt.piecesHidden = piecesHidden
            rushAttempt.puzzledUser = puzzledUser
            do { try context.save() }
            catch { print("Error: couldn't save rush5attempt")}
        } else {
            print("Error: startMinutes must be either 3 or 5")
        }
        UserDBMS().tryUpdateUserRushHS(forUser: puzzledUser, withScore: numCorrect, rushMinutes: startMinutes, piecesHidden: piecesHidden)
    }
}

extension PuzzleRushController: PostRushDelegate {
    func didSelectPlayAgain() {
        onSolutionMoveIndex = 0
        stateIsIncorrect = false
        numCorrect = 0
        numIncorrect = 0
        fetchNextPuzzle()
        secondsRemaining = startMinutes*60
        puzzledUser = UserDBMS().getPuzzledUser()
        DispatchQueue.main.async {
            self.view.subviews.forEach{ (view) in
                view.removeFromSuperview()
            }
            self.viewDidLoad()
        }
    }
    
    func didSelectExit() {
        navigationController?.popViewController(animated: true)
    }
    
}
