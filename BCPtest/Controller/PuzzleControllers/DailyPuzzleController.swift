//
//  DailyPuzzleController.swift
//  BCPtest
//
//  Created by Guest on 8/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import CoreData
import ChessKit


class DailyPuzzleController: UIViewController {
    
    // MARK: - Properties
    private var workItems: [DispatchWorkItem] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var piecesHidden: Bool!
    var pRef: PuzzleReference!
    var currentPuzzle: Puzzle!
    var onSolutionMoveIndex: Int = 0
    
    var incorrectButton: UIButton! // action: retry puzzle, color red
    var correctButton: UIButton! // action: none, color green
    var postSolutionButton: UIButton! // action: retry puzzle, color green
    
    var playerToMoveLabel: UILabel!
    var numTriesLabel: UILabel!
    var puzzleRatingLabel: UILabel!
    
    var boardController: BoardController!
    var solutionLabel: UILabel!
    var header2Label: UILabel = CommonUI().configureHeaderLabel(title: "STARTING POSITION")
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!
    
    // bottom buttons
    var tabBarFiller: UIView!
    var exitButton: UIButton!
    var showSolutionButton: UIButton!
    var tryAgainButton: UIButton!
    var buttonStack: UIStackView!
    
    var puzzleNumber: Int!
    var numTries: Int!
    
    
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
        setUpAutoLayout()
    }
    
    override func viewDidLayoutSubviews() {
        setFrames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Config
    
    func configureUI() {
        correctButton = PuzzleUI().configBannerButton(title: "  Correct", imageName: "checkmark", bgColor: CommonUI().greenCorrect)
        correctButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        incorrectButton = PuzzleUI().configBannerButton(title: "  Incorrect", imageName: "xmark", bgColor: CommonUI().redIncorrect)
        incorrectButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        postSolutionButton = PuzzleUI().configBannerButton(title: "  Try Again", imageName: "arrow.counterclockwise", bgColor: CommonUI().greenCorrect)
        postSolutionButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        view.addSubview(correctButton)
        view.addSubview(incorrectButton)
        view.addSubview(postSolutionButton)
        
        playerToMoveLabel = PuzzleUI().configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.addSubview(playerToMoveLabel)
        
        numTriesLabel = PuzzleUI().configRatingLabel()
        numTriesLabel.setText(title: "Attempts Today", value: String(numTries), alignment: .left)
        puzzleRatingLabel = PuzzleUI().configRatingLabel()
        puzzleRatingLabel.setPuzzleRating(forPuzzleReference: pRef, isBlindfold: piecesHidden)
        view.addSubview(numTriesLabel)
        view.addSubview(puzzleRatingLabel)
        numTriesLabel.isHidden = true
        puzzleRatingLabel.isHidden = true
        
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
        view.addSubview(positionTableW.tableView)
        view.addSubview(positionTableB.tableView)
        
        // buttons
        exitButton = PuzzleUI().configureButton(title: "  Exit", imageName: "arrow.left.square")
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        
        tryAgainButton = PuzzleUI().configureButton(title: "  Retry", imageName: "arrow.counterclockwise", weight: .bold)
        tryAgainButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        tryAgainButton.isHidden = true
        
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton,tryAgainButton])
        tabBarFiller = CommonUI().configTabBarFiller()
        view.addSubview(tabBarFiller)
        view.addSubview(buttonStack)
        
        if piecesHidden == false {
            positionTableB.tableView.isHidden = true
            positionTableW.tableView.isHidden = true
        }
      
        view.backgroundColor = CommonUI().blackColorLight
    }
    
    func setUpAutoLayout() {
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
        
        numTriesLabel.topAnchor.constraint(equalTo: playerToMoveLabel.bottomAnchor, constant: 10).isActive = true
        numTriesLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        puzzleRatingLabel.centerYAnchor.constraint(equalTo: numTriesLabel.centerYAnchor).isActive = true
        puzzleRatingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    
        solutionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        solutionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
    }
    
    func setFrames() {
        correctButton.frame = playerToMoveLabel.frame
        incorrectButton.frame = playerToMoveLabel.frame
        postSolutionButton.frame = playerToMoveLabel.frame

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
            postSolutionButton.frame = playerToMoveLabel.frame
            if piecesHidden {
                boardController.view.frame.origin.y = numTriesLabel.isHidden ?
                    numTriesLabel.frame.origin.y : numTriesLabel.frame.origin.y + 3 + numTriesLabel.frame.height
                print("Rating label is hidden: \(numTriesLabel.isHidden)")
                print("rating label y origin is: \(numTriesLabel.frame.origin.y)")
                print("rating label height is: \(numTriesLabel.frame.height)")
            } else {
                let atMid = view.frame.midY - boardController.view.frame.height/2
                let withPadding = numTriesLabel.frame.origin.y + 3 + numTriesLabel.frame.height
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
    
    func restartPuzzle(withFEN fen: String, isNewPuzzle: Bool=false) {
        solutionLabel.text = ""
        onSolutionMoveIndex = 0
        boardController.setNewPosition(fen: fen)
        boardController.configStartPosition(piecesHidden: piecesHidden)
        setRatingLabelVisiblity(isHidden: true, animated: !isNewPuzzle)
        boardController.view.isUserInteractionEnabled = true
    }
    
    // MARK: - Selectors
    
    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
        cancelWorkItems()
    }
    
    @objc func retryAction() {
        cancelWorkItems()
        restartPuzzle(withFEN: currentPuzzle.fen)
        
        showPrePuzzleButtons()
    }
    
    // MARK: - IDK
    
    func setRatingLabelVisiblity(isHidden: Bool, animated: Bool=true) {
        let duration = animated ? 0.5 : 0
        let delay = animated ? 0.5 : 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            print("did cahnge rating visiblity isHidden to \(isHidden)")
            UIView.animate(withDuration: duration) {
                self.numTriesLabel.isHidden = isHidden
                self.puzzleRatingLabel.isHidden = isHidden
                self.setFrames()
            }
        })
    }
    
    func showPostPuzzleButtons(didCompletePuzzle: Bool, wasCorrect: Bool=true) {
        let workItem = DispatchWorkItem {
            UIView.animate(withDuration: 0.2) {
                self.tryAgainButton.isHidden = false
                if didCompletePuzzle && wasCorrect {
                    self.view.bringSubviewToFront(self.correctButton)
                    self.view.bringSubviewToFront(self.boardController.view)
                } else if didCompletePuzzle && !wasCorrect {
                    self.tryAgainButton.setImage(self.tryAgainButton.imageView?.image?.withTintColor(CommonUI().redIncorrect), for: .normal)
                    self.view.bringSubviewToFront(self.incorrectButton)
                    self.view.bringSubviewToFront(self.boardController.view)
                } else {
                    self.tryAgainButton.setImage(self.tryAgainButton.imageView?.image?.withTintColor(CommonUI().greenCorrect), for: .normal)
                    self.view.bringSubviewToFront(self.postSolutionButton)
                    self.view.bringSubviewToFront(self.boardController.view)
                }
                self.view.layoutIfNeeded()
            }
        }
        workItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem)
    }
    
    func showPrePuzzleButtons() {
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.playerToMoveLabel)
            self.view.bringSubviewToFront(self.boardController.view)
            self.tryAgainButton.isHidden = true
            self.tryAgainButton.setImage(self.tryAgainButton.imageView?.image?.withTintColor(CommonUI().lightGray), for: .normal)
            self.view.layoutIfNeeded()
        }
    }
    
    func updateSolutionLabel(showFullSolution: Bool = false) {
        if showFullSolution {
            solutionLabel.attributedText = PuzzleUI().configSolutionText(
                solutionMoves: currentPuzzle.solution_moves,
                onIndex: currentPuzzle.solution_moves.count,
                firstMovingPlayer: currentPuzzle.player_to_move)
            return
        }
        if onSolutionMoveIndex > currentPuzzle.solution_moves.count { return }
        solutionLabel.attributedText = PuzzleUI().configSolutionText(solutionMoves: currentPuzzle.solution_moves, onIndex: onSolutionMoveIndex)
    }
    
    func didCompletePuzzle(wasCorrect: Bool) {
        if wasCorrect { SoundEffectPlayer().correct() }
        else { SoundEffectPlayer().incorrect() }
        boardController.view.isUserInteractionEnabled = false
        if wasCorrect && piecesHidden { boardController.showPieces() }
        showPostPuzzleButtons(didCompletePuzzle: true, wasCorrect: wasCorrect)
        numTries += 1
        numTriesLabel.setText(title: "Attempts Today", value: String(numTries), alignment: .left)
        setRatingLabelVisiblity(isHidden: false)
        PublicDBMS().updateDailyPuzzlesInfo(puzzleNumber: puzzleNumber, attemptWasCorrect: wasCorrect)
    }
    
    func cancelWorkItems() {
        workItems.forEach({$0.cancel()})
    }
}

extension DailyPuzzleController: BoardDelegate {
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
