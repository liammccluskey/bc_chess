//
//  DailyPuzzleController.swift
//  BCPtest
//
//  Created by Guest on 8/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class DailyPuzzleController: UIViewController {
    
    // MARK: - Properties
    let puzzles: [Puzzle]
    var currentPuzzle: Puzzle
    var onSolutionMoveIndex: Int = 0
    var stateIsIncorrect = false
    var pid: Int
    var puzzleUI = PuzzleUI(
        boardTheme: UserDataManager().getBoardColor()!,
        buttonTheme: UserDataManager().getButtonColor()!)
    
    lazy var retryButton: ButtonWithImage = {
        let button = ButtonWithImage(type: .system)
        button.setTitle("TRY AGAIN", for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 20)
        button.backgroundColor = CommonUI().redColor
        button.setTitleColor(.white, for: .normal)
        button.setImage(#imageLiteral(resourceName: "refresh").withRenderingMode(.alwaysOriginal), for: .normal)
        //button.imageView?.image = #imageLiteral(resourceName: "refresh")
        button.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var playerToMoveLabel: UILabel!
    //var piecesShownSegment: UISegmentedControl!
    
    // stack 1
    var stack1: UIStackView!
    var chessBoardController: ChessBoardController!
    var solutionm4: UIView!
    var solutionm3: UIView!
    var solutionm2: UIView!
    var solutionm1: UIView!
    var solutionViews: [UIView] = []
    //var positionTableW: PositionTableController!
    //var positionTableB: PositionTableController!

    // MARK: - Init
    
    init(puzzles: [Puzzle]) {
        self.pid = Int.random(in: 0..<puzzles.count)
        self.puzzles = puzzles
        self.currentPuzzle = puzzles[self.pid]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieceStyle = UserDataManager().getPieceStyle()
        
        configureUI()
        setUpAutoLayout(isInitLoad: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Config
    
    func configureUI() {
        //piecesShownSegment = puzzleUI.configurePiecesShownSegCont()
        configurePageData(isReload: false)
        
        playerToMoveLabel = puzzleUI.configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.insertSubview(playerToMoveLabel, at: 0)
        view.addSubview(retryButton)
        
        //piecesShownSegment.addTarget(self, action: #selector(piecesShownAction), for: .valueChanged)
        var stack1Views: [UIView] = [
            chessBoardController.view,
            //piecesShownSegment
            ]
        stack1Views.insert(contentsOf: solutionViews, at: 1)
        stack1 = CommonUI().configureStackView(arrangedSubViews: stack1Views)
        stack1.setCustomSpacing(20, after: chessBoardController.view)
        view.addSubview(stack1)
      
        view.backgroundColor = CommonUI().blackColor
    }
    
    func setUpAutoLayout(isInitLoad: Bool) {
        if isInitLoad {
            // global anchors
            retryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            retryButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            retryButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            retryButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            playerToMoveLabel.topAnchor.constraint(equalTo: retryButton.topAnchor).isActive = true
            playerToMoveLabel.leftAnchor.constraint(equalTo: retryButton.leftAnchor).isActive = true
            playerToMoveLabel.rightAnchor.constraint(equalTo: retryButton.rightAnchor).isActive = true
            playerToMoveLabel.bottomAnchor.constraint(equalTo: retryButton.bottomAnchor).isActive = true
            
        }
        
        stack1.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0).isActive = true
    }
 
    func configurePageData(isReload: Bool) {
        if isReload {
            playerToMoveLabel.text = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
            playerToMoveLabel.textColor = currentPuzzle.player_to_move == "white" ? .white : .black
            playerToMoveLabel.backgroundColor = UserDataManager().getButtonColor()!.darkSquareColor
        }
        
        if currentPuzzle.solution_moves.count == 4 {
            solutionm4 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[0], matePly: 3)
            solutionm3 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[1], matePly: 2)
            solutionm2 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[2], matePly: 1)
            solutionm1 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[3], matePly: 0)
            solutionViews = [solutionm4, solutionm3, solutionm2, solutionm1]
        } else if currentPuzzle.solution_moves.count == 3 {
            solutionm3 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[0], matePly: 2)
            solutionm2 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[1], matePly: 1)
            solutionm1 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[2], matePly: 0)
            solutionViews = [solutionm3, solutionm2, solutionm1]
        } else if currentPuzzle.solution_moves.count == 2 {
            solutionm2 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[0], matePly: 1)
            solutionm1 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[1], matePly: 0)
            solutionViews = [solutionm2, solutionm1]
        } else {
            solutionm1 = puzzleUI.configureAnswerView(move: currentPuzzle.solution_moves[0], matePly: 0)
            solutionViews = [solutionm1]
        }
        solutionViews.forEach{ (view) in
            view.isHidden = true
        }
        
        
        chessBoardController = ChessBoardController(
            position: currentPuzzle.position,
            showPiecesInitially: true,
            boardTheme: puzzleUI.boardTheme
        )
        chessBoardController.delegate = self
        
        // move this
        if isReload {
            stack1.removeFromSuperview()
            var stack1Views: [UIView] = [chessBoardController.view,
                ]
            stack1Views.insert(contentsOf: solutionViews, at: 1)
            stack1 = CommonUI().configureStackView(arrangedSubViews: stack1Views)
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
        DispatchQueue.main.async {
            if isNewPuzzle {
                self.retryButton.alpha = 0
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.retryButton.alpha = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    // MARK: - Selectors
    
   
    @objc func showSolutionAction() {
        configPageForSolutionState(
            isShowingSolution: true,
            stateIsIncorrect: stateIsIncorrect,
            stateIsPartialCorrect: true)
    }
    
    @objc func retryAction() {
        restartPuzzle(isNewPuzzle: false)
        configPageForSolutionState(isShowingSolution: false)
    }
    
    // MARK: - Selector Helper
    
    func configPageForSolutionState(isShowingSolution:Bool,stateIsIncorrect:Bool=false,stateIsPartialCorrect:Bool=false) {
        chessBoardController.setButtonInteraction(isEnabled: !isShowingSolution)
        //showSolutionButton.isEnabled = !isShowingSolution
        DispatchQueue.main.async {
            self.solutionViews.forEach{ (view) in
                UIView.animate(withDuration: 0.2, animations: {
                    if view.isHidden == isShowingSolution {
                        view.isHidden = !isShowingSolution
                        self.view.layoutIfNeeded()
                    }
                })
            }
            if isShowingSolution {
                self.retryButton.backgroundColor = CommonUI().greenColor
                UIView.animate(withDuration: 0.2, animations: {
                    self.retryButton.alpha = 1
                    self.view.layoutIfNeeded()
                })
            }
            if stateIsIncorrect {self.chessBoardController.configureStartingPosition()}
            if stateIsIncorrect || stateIsPartialCorrect {
                self.retryButton.isEnabled = false
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

extension DailyPuzzleController: ChessBoardDelegate {
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
                return
            }
            var didDisplaySubsolution = false
            solutionViews.forEach{ (view) in
                if view.isHidden && !didDisplaySubsolution {
                    UIView.animate(withDuration: 0.3, animations: {
                        view.isHidden = !view.isHidden
                        self.view.layoutIfNeeded()
                    })
                    didDisplaySubsolution = true
                }
            }
            
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



