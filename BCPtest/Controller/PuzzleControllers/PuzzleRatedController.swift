//
//  PuzzleRatedController.swift
//  BCPtest
//
//  Created by Guest on 8/6/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//


import UIKit
import CoreData

class PuzzleRatedController: UIViewController {
    
    // MARK: - Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var puzzledUser: PuzzledUser!
    var piecesHidden: Bool!
    var pRef: PuzzleReference!
    var currentPuzzle: Puzzle!
    var onSolutionMoveIndex: Int = 0
    var stateIsIncorrect = false
    
    lazy var retryButton: ButtonWithImage = {
        let button = ButtonWithImage(type: .system)
        button.setTitle("TRY AGAIN", for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 20)
        button.backgroundColor = CommonUI().redColor
        button.setTitleColor(.white, for: .normal)
        button.setImage(#imageLiteral(resourceName: "refresh").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var playerToMoveLabel: UILabel!
    var ratingLabel: UILabel!
    var deltaLabel: UILabel!
    var puzzleRatingLabel: UILabel!
    
    // stack 1
    var stack1: UIStackView!
    var chessBoardController: ChessBoardController!
    var solutionLabel: UILabel!
    var header2Label: UILabel = CommonUI().configureHeaderLabel(title: "STARTING POSITION")
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!
    
    // bottom buttons
    var exitButton: UIButton!
    var showSolutionButton: UIButton!
    var nextButton: UIButton!
    var buttonStack: UIStackView!
    
    
    // MARK: - Init
    
    init(piecesHidden: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.piecesHidden = piecesHidden
        self.puzzledUser = UserDBMS().getPuzzledUser()
        self.pRef = PFJ.getPuzzleReferenceInRange(plusOrMinus: Int32(200), isBlindfold: piecesHidden, forUser: self.puzzledUser)!
        self.currentPuzzle = PFJ.getPuzzle(fromPuzzleReference: self.pRef)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setUpAutoLayout(isInitLoad: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Config
    
    func configureUI() {
        configureNavigationBar()
        solutionLabel = PuzzleUI().configSolutionLabel()
        configurePageData(isReload: false)
        
        // stack
        playerToMoveLabel = PuzzleUI().configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.insertSubview(playerToMoveLabel, at: 0)
        
        ratingLabel = PuzzleUI().configRatingLabel()
        ratingLabel.setRating(forPuzzledUser: puzzledUser, isBlindfold: piecesHidden)
        deltaLabel = PuzzleUI().configDeltaLabel()
        puzzleRatingLabel = PuzzleUI().configRatingLabel()
        puzzleRatingLabel.setPuzzleRating(forPuzzleReference: pRef, isBlindfold: piecesHidden)
        view.addSubview(ratingLabel)
        view.addSubview(deltaLabel)
        view.addSubview(puzzleRatingLabel)
        stack1 = CommonUI().configureStackView(arrangedSubViews: [ chessBoardController.view, solutionLabel ])
        stack1.setCustomSpacing(10, after: chessBoardController.view)
        view.addSubview(stack1)
        
        positionTableW = PositionTableController(puzzle: currentPuzzle, isWhite: true)
        positionTableB = PositionTableController(puzzle: currentPuzzle, isWhite: false)
        view.addSubview(positionTableW.tableView)
        view.addSubview(positionTableB.tableView)
        
        // buttons
        exitButton = PuzzleUI().configureButton(title: "  EXIT  ", imageName: "arrow.left.square")
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        showSolutionButton = PuzzleUI().configureButton(title: "  SOLUTION  ", imageName: "questionmark.square")
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "  NEXT  ", imageName: "chevron.right.square")
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton,showSolutionButton,nextButton])
        view.addSubview(buttonStack)
        view.addSubview(retryButton)
        
        if piecesHidden == false {
            positionTableB.tableView.isHidden = true
            positionTableW.tableView.isHidden = true
        }
      
        view.backgroundColor = CommonUI().blackColorLight
    }
    
    func setUpAutoLayout(isInitLoad: Bool) {
        let upperPadding: CGFloat = piecesHidden ? 10 : 50
        if isInitLoad {
            // global anchors
            buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 3).isActive = true
            buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -3).isActive = true
            buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 3).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 70).isActive = true
            
            retryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            retryButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            retryButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            retryButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            playerToMoveLabel.topAnchor.constraint(equalTo: retryButton.topAnchor).isActive = true
            playerToMoveLabel.leftAnchor.constraint(equalTo: retryButton.leftAnchor).isActive = true
            playerToMoveLabel.rightAnchor.constraint(equalTo: retryButton.rightAnchor).isActive = true
            playerToMoveLabel.bottomAnchor.constraint(equalTo: retryButton.bottomAnchor).isActive = true
            ratingLabel.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: upperPadding).isActive = true
            ratingLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
            deltaLabel.leftAnchor.constraint(equalTo: ratingLabel.rightAnchor, constant: 10).isActive = true
            deltaLabel.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor).isActive = true
            puzzleRatingLabel.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor).isActive = true
            puzzleRatingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        }
        
        let sidePadding: CGFloat = piecesHidden ? 20 : 0
        stack1.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: upperPadding).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: sidePadding).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -sidePadding).isActive = true
        
        positionTableW.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -3).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 0).isActive = true
        positionTableW.tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
        
        positionTableB.tableView.leftAnchor.constraint(equalTo:  view.centerXAnchor, constant: 0).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 3).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 0).isActive = true
        positionTableB.tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    func configurePageData(isReload: Bool) {
        if isReload {
            playerToMoveLabel.text = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
            playerToMoveLabel.backgroundColor = currentPuzzle.player_to_move == "white" ? .lightGray : .black //CommonUI().blackColorLight
            playerToMoveLabel.textColor = currentPuzzle.player_to_move == "white" ? .black : .lightGray
            positionTableW.setData(puzzle: currentPuzzle, isWhite: true)
            positionTableB.setData(puzzle: currentPuzzle, isWhite: false)
            positionTableW.tableView.reloadData()
            positionTableB.tableView.reloadData()
            ratingLabel.setRating(forPuzzledUser: puzzledUser, isBlindfold: piecesHidden)
            puzzleRatingLabel.setPuzzleRating(forPuzzleReference: pRef, isBlindfold: piecesHidden)
        }
        // Done for reloads and initial loads
        chessBoardController = ChessBoardController(
            position: currentPuzzle.position,
            showPiecesInitially: !piecesHidden,
            boardTheme: PuzzleUI().boardTheme
        )
        chessBoardController.delegate = self
        
        // move this
        if isReload {
            stack1.removeFromSuperview()
            stack1 = CommonUI().configureStackView(arrangedSubViews: [chessBoardController.view, solutionLabel])
            stack1.setCustomSpacing(15, after: chessBoardController.view)
            view.addSubview(stack1)
            setUpAutoLayout(isInitLoad: false)
        }
    }
    
    func restartPuzzle(isNewPuzzle: Bool) {
        solutionLabel.text = ""
        onSolutionMoveIndex = 0
        stateIsIncorrect = false
        if piecesHidden {chessBoardController.hidePieces()}
        chessBoardController.clearSelections()
        chessBoardController.setButtonInteraction(isEnabled: true)
        showSolutionButton.isEnabled = true
        DispatchQueue.main.async {
            if isNewPuzzle {
                self.retryButton.alpha = 0
                self.deltaLabel.text = ""
            }
            else {
                self.chessBoardController.configureStartingPosition()
                UIView.animate(withDuration: 0.2, animations: {
                    self.retryButton.alpha = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showSolutionAction() {
        configPageForSolutionState(
            isShowingSolution: true,
            stateIsIncorrect: stateIsIncorrect,
            stateIsPartialCorrect: true)
    }
    
    @objc func nextAction() {
        restartPuzzle(isNewPuzzle: true)
        pRef = PFJ.getPuzzleReferenceInRange(plusOrMinus: Int32(200), isBlindfold: piecesHidden, forUser: self.puzzledUser)!
        currentPuzzle = PFJ.getPuzzle(fromPuzzleReference: self.pRef)
        configurePageData(isReload: true)
    }

    
    @objc func retryAction() {
        restartPuzzle(isNewPuzzle: false)
        configPageForSolutionState(isShowingSolution: false)
    }
    
    // MARK: - Selector Helper
    
    func configPageForSolutionState(isShowingSolution:Bool,stateIsIncorrect:Bool=false,stateIsPartialCorrect:Bool=false) {
        chessBoardController.setButtonInteraction(isEnabled: !isShowingSolution)
        showSolutionButton.isEnabled = !isShowingSolution
        DispatchQueue.main.async {
            if isShowingSolution {
                self.retryButton.backgroundColor = CommonUI().greenColor
                UIView.animate(withDuration: 0.2, animations: {
                    self.solutionLabel.text =
                        PuzzleUI().configSolutionText(solutionMoves: self.currentPuzzle.solution_moves, onIndex: self.currentPuzzle.solution_moves.count)
                    self.retryButton.alpha = 1
                    self.view.layoutIfNeeded()
                })
            }
            if stateIsIncorrect {self.chessBoardController.configureStartingPosition()}
            if stateIsIncorrect || stateIsPartialCorrect {
                self.retryButton.isEnabled = false
                self.chessBoardController.showPieces()
            }
        }
        if isShowingSolution && stateIsIncorrect {
            chessBoardController.displaySolutionMoves(
                solutionMoves: currentPuzzle.solution_moves,
                playerToMove: currentPuzzle.player_to_move)
        } else if isShowingSolution && stateIsPartialCorrect {
            let movesRemaining = currentPuzzle.solution_moves.count - onSolutionMoveIndex
            let movesToPush = Array(currentPuzzle.solution_moves.suffix(movesRemaining))
            chessBoardController.displaySolutionMoves(
                solutionMoves: movesToPush,
                playerToMove: currentPuzzle.player_to_move)
        }
    }
}

extension PuzzleRatedController: ChessBoardDelegate {
    func didFinishShowingSolution() {
        retryButton.isEnabled = true
        print("did enable button")
    }
    
    func didMakeMove(moveUCI: String) {
        let solutionUCI = currentPuzzle.solution_moves[onSolutionMoveIndex].answer_uci
        if solutionUCI.contains(moveUCI) {
            let solutionMove: WBMove = currentPuzzle.solution_moves[onSolutionMoveIndex]
            chessBoardController.pushMove(wbMove: solutionMove, firstMovingPlayer: currentPuzzle.player_to_move)
            onSolutionMoveIndex = onSolutionMoveIndex + 1
            if onSolutionMoveIndex == currentPuzzle.solution_moves.count {
                configPageForSolutionState(isShowingSolution: true, stateIsPartialCorrect: false)
                let ratingDelta = updateUserRating(forPuzzleReference: pRef, wasCorrect: true)
                deltaLabel.setDelta(delta: ratingDelta)
                savePuzzleAttempt(wasCorrect: true, ratingDelta: ratingDelta, pRef: pRef)
                print("solved puzzle and saved solution")
                return
            }
            solutionLabel.text = PuzzleUI().configSolutionText(solutionMoves: currentPuzzle.solution_moves, onIndex: onSolutionMoveIndex)
            
        } else {
            let playerIsWhite = currentPuzzle.player_to_move == "white" ? true : false
            chessBoardController.displayMove(moveUCI: moveUCI, playerIsWhite: playerIsWhite)
            chessBoardController.setButtonInteraction(isEnabled: false)
            stateIsIncorrect = true
            let ratingDelta = updateUserRating(forPuzzleReference: pRef, wasCorrect: false)
            deltaLabel.setDelta(delta: ratingDelta)
            savePuzzleAttempt(wasCorrect: false, ratingDelta: ratingDelta, pRef: pRef)
            DispatchQueue.main.async {
                self.retryButton.backgroundColor = CommonUI().redColor
                UIView.animate(withDuration: 0.3, animations: {
                    self.retryButton.alpha = 1
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
}

extension PuzzleRatedController {
    func savePuzzleAttempt(wasCorrect: Bool, ratingDelta: Int32, pRef: PuzzleReference) {
        puzzledUser = UserDBMS().getPuzzledUser()
        let newRating = piecesHidden ? puzzledUser.puzzleB_Elo : puzzledUser.puzzle_Elo
        let puzzleAttempt = PuzzleAttempt(context: context)
        puzzleAttempt.wasCorrect = wasCorrect
        puzzleAttempt.timestamp = Date()
        puzzleAttempt.puzzleType = pRef.puzzleType
        puzzleAttempt.puzzleIndex = pRef.puzzleIndex
        puzzleAttempt.piecesHidden = piecesHidden
        puzzleAttempt.ratingDelta = ratingDelta
        puzzleAttempt.newRating = newRating
        puzzleAttempt.puzzledUser = puzzledUser
        do { try context.save() }
        catch { print("error saving puzzle attempt") }
    }
    
    func updateUserRating(forPuzzleReference pRef: PuzzleReference, wasCorrect: Bool) -> Int32 {
        let pElo = piecesHidden ? pRef.eloBlindfold : pRef.eloRegular
        let oldRating = piecesHidden ? puzzledUser.puzzleB_Elo : puzzledUser.puzzle_Elo
        let updatedUser = UserDBMS().updateUserPuzzleElo(forUser: puzzledUser, puzzleRating: pElo, wasCorrect: wasCorrect, isBlindfold: piecesHidden)
        let newRating = piecesHidden ? updatedUser.puzzleB_Elo : updatedUser.puzzle_Elo
        return newRating - oldRating
    }
}



