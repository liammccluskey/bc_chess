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
    var puzzleNumber: Int!
    var numTries: Int!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var piecesHidden: Bool!
    var pRef: PuzzleReference!
    var currentPuzzle: Puzzle!
    var onSolutionMoveIndex: Int = 0
    var stateIsIncorrect = false
    
    lazy var retryButton: ButtonWithImage = {
        let button = ButtonWithImage(type: .system)
        button.setTitle("TRY AGAIN", for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 20)
        button.backgroundColor = CommonUI().redIncorrect
        button.setTitleColor(.white, for: .normal)
        button.setImage(#imageLiteral(resourceName: "refresh").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var playerToMoveLabel: UILabel!
    var numTriesLabel: UILabel!
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
    var buttonStack: UIStackView!
    
    
    // MARK: - Init
    
    init(pRef: PuzzleReference, puzzle: Puzzle, piecesHidden: Bool, puzzleNumber: Int, publicAttemptsInfo: DailyPuzzlesInfo?) {
        super.init(nibName: nil, bundle: nil)
        self.piecesHidden = piecesHidden
        self.puzzleNumber = puzzleNumber
        self.pRef = pRef
        self.currentPuzzle = puzzle
        guard let info = publicAttemptsInfo else { self.numTries = 0 ; return }
        switch puzzleNumber {
        case 1: numTries = info.P1_ATTEMPTS ; break
        case 2: numTries = info.P2_ATTEMPTS ; break
        case 3: numTries = info.P3_ATTEMPTS ; break
        default: break
        }
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
        
        playerToMoveLabel = PuzzleUI().configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.insertSubview(playerToMoveLabel, at: 0)
        
        numTriesLabel = PuzzleUI().configRatingLabel()
        numTriesLabel.text = "ATTEMPTS:  \(numTries!)"
        puzzleRatingLabel = PuzzleUI().configRatingLabel()
        puzzleRatingLabel.setPuzzleRating(forPuzzleReference: pRef, isBlindfold: piecesHidden)
        view.addSubview(numTriesLabel)
        view.addSubview(puzzleRatingLabel)
        
        chessBoardController = ChessBoardController(
                   position: currentPuzzle.position,
                   showPiecesInitially: !piecesHidden
        )
        chessBoardController.delegate = self
        
        solutionLabel = PuzzleUI().configSolutionLabel()
        
        stack1 = CommonUI().configureStackView(arrangedSubViews: [ chessBoardController.view, solutionLabel ])
        stack1.setCustomSpacing(10, after: chessBoardController.view)
        view.addSubview(stack1)
        
        positionTableW = PositionTableController(puzzle: currentPuzzle, isWhite: true)
        positionTableB = PositionTableController(puzzle: currentPuzzle, isWhite: false)
        view.addSubview(positionTableW.tableView)
        view.addSubview(positionTableB.tableView)
        
        // buttons
        exitButton = PuzzleUI().configureButton(title: "  Exit  ", imageName: "arrow.left.square")
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton])
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
            numTriesLabel.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: upperPadding).isActive = true
            numTriesLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
            puzzleRatingLabel.centerYAnchor.constraint(equalTo: numTriesLabel.centerYAnchor).isActive = true
            puzzleRatingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        }
        
        let sidePadding: CGFloat = piecesHidden ? 20 : 0
        stack1.topAnchor.constraint(equalTo: numTriesLabel.bottomAnchor, constant: upperPadding).isActive = true
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
    }
    
    func restartPuzzle() {
        solutionLabel.text = ""
        onSolutionMoveIndex = 0
        stateIsIncorrect = false
        if piecesHidden {chessBoardController.hidePieces()}
        chessBoardController.clearSelections()
        chessBoardController.setButtonInteraction(isEnabled: true)
        DispatchQueue.main.async {
            self.chessBoardController.configureStartingPosition()
            UIView.animate(withDuration: 0.2, animations: {
                self.retryButton.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Selectors
    
    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc func retryAction() {
        restartPuzzle()
    }
    
    // MARK: - Selector Helper
    
    func configPageForAttemptSubmit(wasCorrect: Bool) {
        chessBoardController.setButtonInteraction(isEnabled: false)
        DispatchQueue.main.async {
            if wasCorrect {
                self.retryButton.backgroundColor = CommonUI().greenCorrect
            } else {
                self.retryButton.backgroundColor = CommonUI().redIncorrect
            }
                
            UIView.animate(withDuration: 0.2, animations: {
                self.retryButton.alpha = 1
                if wasCorrect && self.piecesHidden {
                    self.chessBoardController.showPieces()
                }
            })
        }
    }
}

extension DailyPuzzleController: ChessBoardDelegate {
    func didFinishShowingSolution() {
        retryButton.isEnabled = true
    }
    
    func didMakeMove(moveUCI: String) {
        let solutionUCI = currentPuzzle.solution_moves[onSolutionMoveIndex].answer_uci
        if solutionUCI.contains(moveUCI) {
            let solutionMove: WBMove = currentPuzzle.solution_moves[onSolutionMoveIndex]
            chessBoardController.pushMove(wbMove: solutionMove, firstMovingPlayer: currentPuzzle.player_to_move)
            onSolutionMoveIndex = onSolutionMoveIndex + 1
            if onSolutionMoveIndex == currentPuzzle.solution_moves.count {
                SoundEffectPlayer().correct()
                configPageForAttemptSubmit(wasCorrect: true)
                PublicDBMS().updateDailyPuzzlesInfo(puzzleNumber: puzzleNumber, attemptWasCorrect: true)
            }
            solutionLabel.text = PuzzleUI().configSolutionText(solutionMoves: currentPuzzle.solution_moves, onIndex: onSolutionMoveIndex)
        } else {
            PublicDBMS().updateDailyPuzzlesInfo(puzzleNumber: puzzleNumber, attemptWasCorrect: false)
            let playerIsWhite = currentPuzzle.player_to_move == "white" ? true : false
            chessBoardController.displayMove(moveUCI: moveUCI, playerIsWhite: playerIsWhite)
            SoundEffectPlayer().incorrect()
            chessBoardController.setButtonInteraction(isEnabled: false)
            stateIsIncorrect = true
            configPageForAttemptSubmit(wasCorrect: false)
        }
    }
}


