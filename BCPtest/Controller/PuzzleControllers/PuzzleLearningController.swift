//
//  PuzzleLearningController.swift
//  BCPtest
//
//  Created by Guest on 8/6/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import CoreData

class PuzzleLearningController: UIViewController {
    
    // MARK: - Properties
    var piecesHidden: Bool!
    var puzzleType: Int!
    var puzzleIndex: Int!
    var senderIsProgressController: Bool!
    
    var currentPuzzle: Puzzle!
    var onSolutionMoveIndex: Int = 0
    var stateIsIncorrect = false
    var pid: Int!
    
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
    var piecesShownSegment: UISegmentedControl!
    
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
    
    init(piecesHidden: Bool, puzzleType: Int = 0, puzzleIndex: Int = 0, senderIsProgressController: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        if senderIsProgressController { // pick random puzzle otherwise
            switch puzzleType {
            case 0: self.currentPuzzle = puzzlesFromJSON.m1[puzzleIndex]; break
            case 1: self.currentPuzzle = puzzlesFromJSON.m2[puzzleIndex]; break
            case 2: self.currentPuzzle = puzzlesFromJSON.m3[puzzleIndex]; break
            case 3: self.currentPuzzle = puzzlesFromJSON.m4[puzzleIndex]; break
            default: break
            }
        }
        self.senderIsProgressController = senderIsProgressController
        self.piecesHidden = piecesHidden
        self.puzzleIndex = puzzleIndex
        self.puzzleType = puzzleType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieceStyle = UserDataManager().getPieceStyle()
        if !senderIsProgressController {
            puzzleType = Int.random(in: 0..<4)
            switch puzzleType {
            case 0: currentPuzzle = puzzlesFromJSON.m1[puzzleIndex]; break
            case 1: currentPuzzle = puzzlesFromJSON.m2[puzzleIndex]; break
            case 2: currentPuzzle = puzzlesFromJSON.m3[puzzleIndex]; break
            case 3: currentPuzzle = puzzlesFromJSON.m4[puzzleIndex]; break
            default: break
            }
        }
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
        let selectedIndex = piecesHidden ? 0 : 1
        piecesShownSegment = PuzzleUI().configurePiecesShownSegment(selectedSegmentIndex: selectedIndex)
        configurePageData(isReload: false)
        
        // stack
        playerToMoveLabel = PuzzleUI().configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.insertSubview(playerToMoveLabel, at: 0)
        
        piecesShownSegment.addTarget(self, action: #selector(piecesShownAction), for: .valueChanged)
        
        stack1 = CommonUI().configureStackView(arrangedSubViews: [
            chessBoardController.view, piecesShownSegment, solutionLabel
        ])
        stack1.setCustomSpacing(0, after: chessBoardController.view)
        view.addSubview(stack1)
        
        positionTableW = PositionTableController(puzzle: currentPuzzle, isWhite: true)
        positionTableB = PositionTableController(puzzle: currentPuzzle, isWhite: false)
        view.addSubview(positionTableW.tableView)
        view.addSubview(positionTableB.tableView)
        
        // buttons
        exitButton = PuzzleUI().configureButton(title: "   EXIT   ", titleColor: .white, borderColor: .white)
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        showSolutionButton = PuzzleUI().configureButton(title: "SOLUTION", titleColor: .white, borderColor: .white)
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "   NEXT   ", titleColor: .white, borderColor: .white)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton,showSolutionButton,nextButton])
        view.addSubview(buttonStack)
        view.addSubview(retryButton)
      
        view.backgroundColor = CommonUI().blackColor
    }
    
    func setUpAutoLayout(isInitLoad: Bool) {
        if isInitLoad {
            // global anchors
            buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 3).isActive = true
            buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -3).isActive = true
            buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 3).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 68).isActive = true
            
            retryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            retryButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            retryButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            retryButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            playerToMoveLabel.topAnchor.constraint(equalTo: retryButton.topAnchor).isActive = true
            playerToMoveLabel.leftAnchor.constraint(equalTo: retryButton.leftAnchor).isActive = true
            playerToMoveLabel.rightAnchor.constraint(equalTo: retryButton.rightAnchor).isActive = true
            playerToMoveLabel.bottomAnchor.constraint(equalTo: retryButton.bottomAnchor).isActive = true
        }
        
        stack1.topAnchor.constraint(equalTo: playerToMoveLabel.bottomAnchor, constant: 0).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0).isActive = true
        
        positionTableW.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -3).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 5).isActive = true
        positionTableW.tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
        
        positionTableB.tableView.leftAnchor.constraint(equalTo:  view.centerXAnchor, constant: 0).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -3).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 5).isActive = true
        positionTableB.tableView.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    func configurePageData(isReload: Bool) {
        if isReload {
            playerToMoveLabel.text = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
            positionTableW.setData(puzzle: currentPuzzle, isWhite: true)
            positionTableB.setData(puzzle: currentPuzzle, isWhite: false)
            positionTableW.tableView.reloadData()
            positionTableB.tableView.reloadData()
        }
        
        // Done for reloads and initial loads
        solutionLabel.text = ""
        let showPieces = piecesShownSegment.selectedSegmentIndex == 1 ? true : false
        chessBoardController = ChessBoardController(
            position: currentPuzzle.position,
            showPiecesInitially: showPieces,
            boardTheme: PuzzleUI().boardTheme
        )
        chessBoardController.delegate = self
        
        // move this
        if isReload {
            stack1.removeFromSuperview()
            stack1 = CommonUI().configureStackView(arrangedSubViews: [chessBoardController.view, piecesShownSegment, solutionLabel])
            stack1.setCustomSpacing(0, after: chessBoardController.view)
            view.addSubview(stack1)
            setUpAutoLayout(isInitLoad: false)
        }
    }
    
    func restartPuzzle(isNewPuzzle: Bool) {
        onSolutionMoveIndex = 0
        stateIsIncorrect = false
        chessBoardController.configureStartingPosition()
        chessBoardController.clearSelections()
        chessBoardController.setButtonInteraction(isEnabled: true)
        showSolutionButton.isEnabled = true
        DispatchQueue.main.async {
            if isNewPuzzle { self.retryButton.alpha = 0 }
            else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.solutionLabel.text = ""
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
        pid = Int.random(in: 0..<puzzlesFromJSON.m2.count)
        currentPuzzle = puzzlesFromJSON.m2[pid]
        configurePageData(isReload: true)
    }
    
    @objc func piecesShownAction() {
        let selectedIndex = piecesShownSegment.selectedSegmentIndex
        if selectedIndex == 1 {
            chessBoardController.showPieces()
        } else {
            chessBoardController.hidePieces()
        }
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
                self.piecesShownSegment.selectedSegmentIndex = 1
                self.piecesShownSegment.sendActions(for: .valueChanged)
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

extension PuzzleLearningController: ChessBoardDelegate {
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
                print("solved puzzle and saved solution")
                return
            }
            solutionLabel.text = PuzzleUI().configSolutionText(solutionMoves: currentPuzzle.solution_moves, onIndex: onSolutionMoveIndex)
            
        } else {
            let playerIsWhite = currentPuzzle.player_to_move == "white" ? true : false
            chessBoardController.displayMove(moveUCI: moveUCI, playerIsWhite: playerIsWhite)
            chessBoardController.setButtonInteraction(isEnabled: false)
            stateIsIncorrect = true
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

