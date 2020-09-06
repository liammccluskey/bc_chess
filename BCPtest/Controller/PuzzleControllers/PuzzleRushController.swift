//
//  PuzzleRushController.swift
//  BCPtest
//
//  Created by Guest on 8/6/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import CoreData
import ChessKit


class PuzzleRushController: UIViewController {
    
    // MARK: - Properties
    var startMinutes: Int!
    var piecesHidden: Bool!
    var timer: Timer!
    var pregameTimer: Timer!
    var pregameCountdown: Int!
    
    // dynamic data
    var puzzledUser: PuzzledUser!
    var onSolutionMoveIndex: Int = 0
    var numCorrect: Int = 0
    var numIncorrect: Int = 0
    var secondsRemaining: Int!
    var lowerBoundFetch: Int!
    var upperBoundFetch: Int!
    var pRef: PuzzleReference?
    var currentPuzzle: Puzzle!
    
    private var workItems: [DispatchWorkItem] = []
    var limitReachedController: LimitReachedController!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // view
    var playerToMoveLabel: UILabel!
    var incorrectButton: UIButton! //action: none
    var correctButton: UIButton! // action: none
    
    var numCorrectLabel: UILabel!
    var timeRemainingLabel: UILabel!
    var incorrectMarksView: IncorrectMarksView!
    
    var boardController: BoardController!
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!
    
    var solutionLabel: UILabel!
    
    var tabBarFiller: UIView!
    var exitButton: UIButton!
    var buttonStack: UIStackView!
    
    let pregameCountdownLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: fontString, size: 80)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = .black
        l.text = "3"
        l.alpha = 0.8
        return l
    }()
    
    // MARK: - Init
    
    init(piecesHidden: Bool, minutes: Int) {
        super.init(nibName: nil, bundle: nil)
        self.piecesHidden = piecesHidden
        self.startMinutes = minutes // either 3 or 5
        self.secondsRemaining = startMinutes*60
        self.puzzledUser = UserDBMS().getPuzzledUser()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentPuzzle = fetchNextPuzzle()
        
        configureUI()
        setUpAutoLayout()
        
        if UserDataManager().hasReachedPuzzleLimit() {
            limitReachedController = LimitReachedController()
            limitReachedController.delegate = self
            pregameCountdownLabel.removeFromSuperview()
            view.addSubview(limitReachedController.view)
            return
        }
        pregameCountdown = 3
        pregameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pregameTimerAction), userInfo: nil, repeats: true)
        view.isUserInteractionEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        setFrames()
    }
    
    // MARK: - Config
    
    func configureUI() {
        
        correctButton = PuzzleUI().configBannerButton(title: "  Correct", imageName: "checkmark", bgColor: CommonUI().greenCorrect)
        incorrectButton = PuzzleUI().configBannerButton(title: "  Incorrect", imageName: "xmark", bgColor: CommonUI().redIncorrect)
        correctButton.isEnabled = false
        incorrectButton.isEnabled = false
        view.addSubview(correctButton)
        view.addSubview(incorrectButton)
        
        playerToMoveLabel = PuzzleUI().configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.addSubview(playerToMoveLabel)
        
        numCorrectLabel = PuzzleUI().configRatingLabel()
        numCorrectLabel.setAttrText(text: "0", alignment: .left, fontName: fontStringBold)
        timeRemainingLabel = PuzzleRushUI().configTimeRemainingLabel()
        timeRemainingLabel.setTimeRemaining(secondsLeft: secondsRemaining)
        incorrectMarksView = IncorrectMarksView()
        incorrectMarksView.numIncorrect = 0
        view.addSubview(numCorrectLabel)
        view.addSubview(timeRemainingLabel)
        view.addSubview(incorrectMarksView)
        
        let screenW = view.bounds.width
        let sideLength = UIDevice.current.userInterfaceIdiom == .pad && piecesHidden ? screenW - 175 : screenW
        boardController = BoardController(sideLength: sideLength, fen: currentPuzzle.fen, showPiecesInitially: !piecesHidden)
        boardController.delegate = self
        view.addSubview(boardController.view)
        
        solutionLabel = PuzzleUI().configSolutionLabel()
        solutionLabel.translatesAutoresizingMaskIntoConstraints = false
        solutionLabel.attributedText = PuzzleUI().configSolutionText(solutionMoves: currentPuzzle.solution_moves, onIndex: 0)
        view.addSubview(solutionLabel)
        
        positionTableW = PositionTableController(puzzle: currentPuzzle, isWhite: true)
        positionTableB = PositionTableController(puzzle: currentPuzzle, isWhite: false)
        positionTableB.tableView.isHidden = !piecesHidden
        positionTableW.tableView.isHidden = !piecesHidden
        view.addSubview(positionTableW.tableView)
        view.addSubview(positionTableB.tableView)
        
        // buttons
        exitButton = PuzzleUI().configureButton(title: "  Exit", imageName: "arrow.left.square")
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton])
        tabBarFiller = CommonUI().configTabBarFiller()
        view.addSubview(tabBarFiller)
        view.addSubview(buttonStack)
        
        pregameCountdownLabel.text = "3"
        view.addSubview(pregameCountdownLabel)
        view.backgroundColor = CommonUI().blackColorLight
    }
    
    func setUpAutoLayout() {
        pregameCountdownLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        tabBarFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tabBarFiller.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tabBarFiller.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tabBarFiller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        buttonStack.bottomAnchor.constraint(equalTo: tabBarFiller.topAnchor, constant: 0).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: tabBarHeight).isActive = true
        
        let bannerH:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40
        playerToMoveLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        playerToMoveLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerToMoveLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerToMoveLabel.heightAnchor.constraint(equalToConstant: bannerH).isActive = true
        
        numCorrectLabel.topAnchor.constraint(equalTo: playerToMoveLabel.bottomAnchor, constant: 10).isActive = true
        numCorrectLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        timeRemainingLabel.centerYAnchor.constraint(equalTo: numCorrectLabel.centerYAnchor).isActive = true
        timeRemainingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        incorrectMarksView.centerYAnchor.constraint(equalTo: numCorrectLabel.centerYAnchor).isActive = true
        incorrectMarksView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        incorrectMarksView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        incorrectMarksView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        solutionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        solutionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
    }
    
    func setFrames() {
        correctButton.frame = playerToMoveLabel.frame
        incorrectButton.frame = playerToMoveLabel.frame

        if UIDevice.current.userInterfaceIdiom == .pad && piecesHidden {
            let tableW: CGFloat = 175
            let boardW = view.bounds.width - tableW
            let boardY = view.bounds.midY - boardW/2
            boardController.view.frame.origin.y = boardY
            solutionLabel.frame.origin.y = boardY + boardW + 10
            positionTableW.tableView.frame = CGRect(x: boardW, y: boardY, width: tableW, height: boardW/2)
            positionTableB.tableView.frame = CGRect(x: boardW, y: boardY + boardW/2, width: tableW, height: boardW/2)
            solutionLabel.frame.origin.y = boardY + boardW + 0
        } else {
            correctButton.frame = playerToMoveLabel.frame
            incorrectButton.frame = playerToMoveLabel.frame
            if piecesHidden {
                boardController.view.frame.origin.y = numCorrectLabel.frame.origin.y + 3 + numCorrectLabel.frame.height
            } else {
                let atMid = view.frame.midY - boardController.view.frame.height/2
                let withPadding = numCorrectLabel.frame.origin.y + 3 + numCorrectLabel.frame.height
                boardController.view.frame.origin.y = max(atMid, withPadding)
            }
            solutionLabel.frame.origin.y = boardController.view.frame.origin.y + boardController.view.frame.height + 0
            let tvY = solutionLabel.frame.origin.y + solutionLabel.frame.height + 0
            let tvX = view.frame.width/2
            let tvHeight = buttonStack.frame.origin.y - tvY
            positionTableB.tableView.frame = CGRect(x: 0, y: tvY, width: tvX, height: tvHeight)
            positionTableW.tableView.frame = CGRect(x: tvX, y: tvY, width: tvX, height: tvHeight)
        }
    }
    
    func configurePageForNewPuzzle(puzzle: Puzzle) {
        solutionLabel.text = ""
        onSolutionMoveIndex = 0
        boardController.setNewPosition(fen: puzzle.fen)
        boardController.configStartPosition(piecesHidden: piecesHidden)
        boardController.view.isUserInteractionEnabled = true
        
        playerToMoveLabel.setPlayerToMove(playerToMove: puzzle.player_to_move)
        positionTableW.setData(puzzle: puzzle, isWhite: true)
        positionTableB.setData(puzzle: puzzle, isWhite: false)
        positionTableW.tableView.reloadData()
        positionTableB.tableView.reloadData()
        showPrePuzzleButtons()
    }
    
    func fetchNextPuzzle() -> Puzzle {
        if numCorrect < 5 {
            lowerBoundFetch = 250 + numCorrect*100
            upperBoundFetch = lowerBoundFetch + 100
        } else {
            lowerBoundFetch = 650 + (numCorrect/2)*100
            upperBoundFetch = lowerBoundFetch + 100
        }
        var foundPuzzle = false
        while foundPuzzle == false {
            pRef = PFJ.getPuzzleReferenceInRange(lowerBound: lowerBoundFetch, upperBound: upperBoundFetch, isBlindfold: piecesHidden)
            if pRef != nil { foundPuzzle = true; break }
            else {
                upperBoundFetch += 100
                lowerBoundFetch -= 50
            }
        }
        return PFJ.getPuzzle(fromPuzzleReference: pRef!)!
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
            boardController.view.isUserInteractionEnabled = false
            saveRushAttempt(didTimeout: true, didStrikeout: false)
            showPostRustController()
        }
    }
    
    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
        cancelWorkItems()
    }
    
    // MARK: - IDK
    
    
    func showPostPuzzleButtons(wasCorrect: Bool) {
        if wasCorrect {
            view.bringSubviewToFront(correctButton)
        } else {
            view.bringSubviewToFront(incorrectButton)
        }
        view.bringSubviewToFront(boardController.view)
    }
    
    func showPrePuzzleButtons() {
        view.bringSubviewToFront(self.playerToMoveLabel)
        view.bringSubviewToFront(boardController.view)
    }
    
    func updateSolutionLabel() {
        if onSolutionMoveIndex > currentPuzzle.solution_moves.count { return }
        solutionLabel.attributedText = PuzzleUI().configSolutionText(solutionMoves: currentPuzzle.solution_moves, onIndex: onSolutionMoveIndex)
    }
    
    func didCompletePuzzle(wasCorrect: Bool) {
        boardController.view.isUserInteractionEnabled = false
        showPostPuzzleButtons(wasCorrect: wasCorrect)
        if wasCorrect {
            numCorrect += 1
            numCorrectLabel.setAttrText(text: String(numCorrect), alignment: .left, fontName: fontStringBold)
        } else {
            numIncorrect += 1
            incorrectMarksView.numIncorrect = numIncorrect
        }
        if numIncorrect == 3 {
            timer.invalidate()
            saveRushAttempt(didTimeout: false, didStrikeout: true)
            showPostRustController()
        } else {
            self.currentPuzzle = fetchNextPuzzle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.configurePageForNewPuzzle(puzzle: self.currentPuzzle)
            }
        }
    }
    
    func cancelWorkItems() {
        workItems.forEach({$0.cancel()})
    }
    
    func showPostRustController() {
        let controller = PostRushController(score: numCorrect, rushMinutes: startMinutes, isBlindfold: piecesHidden)
        controller.delegate = self
        self.present(controller, animated: true)
    }
}

extension PuzzleRushController: BoardDelegate {
    func didMakeMove(move: Move, animated: Bool) {
        self.boardController.view.isUserInteractionEnabled = false
        let workItem = DispatchWorkItem {
            self.boardController.pushMove(move: move, animated: animated)
        }
        workItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem)
        
        let solutionMoves = currentPuzzle.solution_moves[onSolutionMoveIndex]
        let answerMove = Move(string: solutionMoves.answer_uci)
        if move.description != answerMove.description {
            didCompletePuzzle(wasCorrect: false)
            return
        }
        onSolutionMoveIndex += 1
        updateSolutionLabel()
        if onSolutionMoveIndex == currentPuzzle.solution_moves.count {
            didCompletePuzzle(wasCorrect: true)
        } else {
            let responseMove = Move(string: solutionMoves.response_uci)
            self.boardController.view.isUserInteractionEnabled = false
            let workItem = DispatchWorkItem {
                self.boardController.pushMove(move: responseMove, animated: true) {
                    self.boardController.view.isUserInteractionEnabled = true
                }
            }
            workItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
        }
    }
}

extension PuzzleRushController {
    func saveRushAttempt(didTimeout: Bool, didStrikeout: Bool) {
        if startMinutes == 3 {
            let rushAttempt = Rush3Attempt(context: context)
            rushAttempt.timestamp = Date()
            rushAttempt.didStrikeout = didStrikeout
            rushAttempt.didTimeout = didTimeout
            rushAttempt.numCorrect = Int32(numCorrect)
            rushAttempt.piecesHidden = piecesHidden
            puzzledUser.addToRush3Attempts(rushAttempt)
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
            puzzledUser.addToRush5Attempts(rushAttempt)
            do { try context.save() }
            catch { print("Error: couldn't save rush5attempt")}
        } else {
            print("Error: startMinutes must be either 3 or 5")
        }
        UserDBMS().tryUpdateUserRushHS(forUser: puzzledUser, withScore: numCorrect, rushMinutes: startMinutes, piecesHidden: piecesHidden)
    }
}

extension PuzzleRushController: LimitReachedDelegate {
    func didSelectUpgrade() {
        navigationController?.pushViewController(UpgradeController(), animated: true)
    }
    
    func didDismiss() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension PuzzleRushController: PostRushDelegate {
    func didSelectExit() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func didSelectPlayAgain() {
        onSolutionMoveIndex = 0
        numCorrect = 0
        numIncorrect = 0
        self.secondsRemaining = startMinutes*60
        self.view.subviews.forEach({$0.removeFromSuperview()})
        self.viewDidLoad()
    }
}
