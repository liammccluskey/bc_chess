//
//  PuzzleRatedController1.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 9/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import CoreData
import ChessKit


class PuzzleLearningController: UIViewController {
    
    // MARK: - Properties
    private var workItems: [DispatchWorkItem] = []
    var limitReachedController: LimitReachedController!
    
    var senderIsProgressController: Bool!
    var isShowingPieces: Bool!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var puzzledUser = UserDBMS().getPuzzledUser()!
    var piecesHidden: Bool!
    var pRef: PuzzleReference!
    var currentPuzzle: Puzzle!
    var onSolutionMoveIndex: Int = 0
    
    var incorrectButton: UIButton! // action: retry puzzle, color red
    var correctButton: UIButton! // action: next puzzle, color green
    var postSolutionButton: UIButton! // action: retry puzzle, color green
    
    var playerToMoveLabel: UILabel!
    
    // stack 1
    var boardController: BoardController!
    var solutionLabel: UILabel!
    var header2Label: UILabel = CommonUI().configureHeaderLabel(title: "STARTING POSITION")
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!
    
    // bottom buttons
    var tabBarFiller: UIView!
    var exitButton: UIButton!
    var showPiecesButton: UIButton!
    var hidePiecesButton: UIButton!
    var showSolutionButton: UIButton!
    var tryAgainButton: UIButton!
    var nextButton: UIButton!
    var buttonStack: UIStackView!
    
    
    // MARK: - Init
    
    init(piecesHidden: Bool, puzzleReference: PuzzleReference? = nil, senderIsProgressController: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        if senderIsProgressController { // pick random puzzle otherwise
            self.currentPuzzle = PFJ.getPuzzle(fromPuzzleReference: puzzleReference!)
        } else {
            let pRef = PFJ.getPuzzleReferenceInRange(plusOrMinus: Int32(200), isBlindfold: piecesHidden , forUser: puzzledUser)
            self.currentPuzzle = PFJ.getPuzzle(fromPuzzleReference: pRef!)
        }
        self.senderIsProgressController = senderIsProgressController
        self.piecesHidden = piecesHidden
        self.isShowingPieces = !piecesHidden
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
        correctButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        incorrectButton = PuzzleUI().configBannerButton(title: "  Incorrect", imageName: "xmark", bgColor: CommonUI().redIncorrect)
        incorrectButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        postSolutionButton = PuzzleUI().configBannerButton(title: "  Try Again", imageName: "arrow.counterclockwise", bgColor: CommonUI().greenCorrect)
        postSolutionButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        view.addSubview(correctButton)
        view.addSubview(incorrectButton)
        view.addSubview(postSolutionButton)
        
        playerToMoveLabel = PuzzleUI().configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.addSubview(playerToMoveLabel)
        
        let screenW = view.bounds.width
        let sideLength = UIDevice.current.userInterfaceIdiom == .pad ? screenW - 175 : screenW
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
        showPiecesButton = PuzzleUI().configureButton(title: "", imageName: "eye")
        showPiecesButton.addTarget(self, action: #selector(showPiecesAction), for: .touchUpInside)
        hidePiecesButton = PuzzleUI().configureButton(title: "", imageName: "eye.slash")
        hidePiecesButton.addTarget(self, action: #selector(hidePiecesAction), for: .touchUpInside)
        showSolutionButton = PuzzleUI().configureButton(title: "  Solution", imageName: "lightbulb")
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        showPiecesButton.isHidden = !piecesHidden
        hidePiecesButton.isHidden = piecesHidden
        
        tryAgainButton = PuzzleUI().configureButton(title: "  Retry", imageName: "arrow.counterclockwise", weight: .bold)
        tryAgainButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "  Next", imageName: "arrow.right", weight: .bold)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        tryAgainButton.isHidden = true
        nextButton.isHidden = true
        
        if !senderIsProgressController {
            buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton,showPiecesButton,hidePiecesButton,showSolutionButton,tryAgainButton,nextButton])
        } else {
            buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton,showPiecesButton,hidePiecesButton,showSolutionButton,tryAgainButton])
        }
        tabBarFiller = CommonUI().configTabBarFiller()
        view.addSubview(tabBarFiller)
        view.addSubview(buttonStack)
      
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
        
        solutionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        solutionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
    }
    
    func setFrames() {
        correctButton.frame = playerToMoveLabel.frame
        incorrectButton.frame = playerToMoveLabel.frame
        postSolutionButton.frame = playerToMoveLabel.frame

        if UIDevice.current.userInterfaceIdiom == .pad {
            let tableW: CGFloat = 175
            let boardW = view.bounds.width - tableW
            let boardY = view.bounds.midY - boardW/2
            boardController.view.frame.origin.y = boardY
            solutionLabel.frame.origin.y = boardY + boardW + 10
            positionTableW.tableView.frame = CGRect(x: boardW, y: boardY, width: tableW, height: boardW/2)
            positionTableB.tableView.frame = CGRect(x: boardW, y: boardY + boardW/2, width: tableW, height: boardW/2)
            solutionLabel.frame.origin.y = boardY + boardW + 0
        } else {
            let boardW = view.bounds.width
            boardController.view.frame.origin.y = playerToMoveLabel.frame.origin.y + 10 + playerToMoveLabel.frame.height
            solutionLabel.frame.origin.y = boardController.view.frame.origin.y + boardW
            let tvY = solutionLabel.frame.origin.y + solutionLabel.frame.height + 5
            let tvX = view.frame.width/2
            let tvHeight = buttonStack.frame.origin.y - tvY
            positionTableB.tableView.frame = CGRect(x: 0, y: tvY, width: tvX, height: tvHeight)
            positionTableW.tableView.frame = CGRect(x: tvX, y: tvY, width: tvX, height: tvHeight)
        }
    }
    
    func updatePageData(isNewPuzzle: Bool) {
        puzzledUser = UserDBMS().getPuzzledUser()!
        if isNewPuzzle == false {return}
        playerToMoveLabel.text = "\(currentPuzzle.player_to_move.capitalized) to Move"
        playerToMoveLabel.backgroundColor = currentPuzzle.player_to_move == "white" ? CommonUI().softWhite : .black //CommonUI().blackColorLight
        playerToMoveLabel.textColor = currentPuzzle.player_to_move == "white" ? CommonUI().blackColorLight : CommonUI().softWhite
        positionTableW.setData(puzzle: currentPuzzle, isWhite: true)
        positionTableB.setData(puzzle: currentPuzzle, isWhite: false)
        positionTableW.tableView.reloadData()
        positionTableB.tableView.reloadData()
    }
    
    func restartPuzzle(withFEN fen: String) {
        solutionLabel.text = ""
        onSolutionMoveIndex = 0
        boardController.setNewPosition(fen: fen)
        boardController.configStartPosition(piecesHidden: !isShowingPieces)
        showSolutionButton.isEnabled = true
        boardController.view.isUserInteractionEnabled = true
    }
    
    // MARK: - Selectors
    
    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
        cancelWorkItems()
    }
    
    @objc func showSolutionAction() {
        cancelWorkItems()
        boardController.view.isUserInteractionEnabled = false
        updateSolutionLabel(showFullSolution: true)
        boardController.setNewPosition(fen: currentPuzzle.fen)
        boardController.configStartPosition()
        isShowingPieces = true
        var delay = 0.25
        currentPuzzle.solution_moves.forEach({
            [$0.answer_uci, $0.response_uci].forEach { (moveDescription) in
                if moveDescription == "complete" { return }
                let workItem = DispatchWorkItem {
                    self.boardController.pushMove(move: Move(string: moveDescription), animated: true)
                }
                workItems.append(workItem)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
                delay += 0.8
            }
        })
        showPostPuzzleButtons(didCompletePuzzle: false)
    }
    
    @objc func nextAction() {
        cancelWorkItems()
        pRef = PFJ.getPuzzleReferenceInRange(plusOrMinus: Int32(200), isBlindfold: piecesHidden, forUser: self.puzzledUser)!
        currentPuzzle = PFJ.getPuzzle(fromPuzzleReference: self.pRef)
        restartPuzzle(withFEN: currentPuzzle.fen)
        updatePageData(isNewPuzzle: true)
        
        showPrePuzzleButtons()
    }

    @objc func retryAction() {
        cancelWorkItems()
        restartPuzzle(withFEN: currentPuzzle.fen)
        updatePageData(isNewPuzzle: false)
        
        showPrePuzzleButtons()
    }
    
    @objc func showPiecesAction() {
        DispatchQueue.main.async {
            self.isShowingPieces = true
            self.boardController.showPieces()
            self.showPiecesButton.isHidden = true
            self.hidePiecesButton.isHidden = false
        }
    }
    
    @objc func hidePiecesAction() {
        DispatchQueue.main.async {
            self.isShowingPieces = false
            self.boardController.hidePieces()
            self.showPiecesButton.isHidden = false
            self.hidePiecesButton.isHidden = true
        }
    }

    
    // MARK: - IDK
    
    func showPostPuzzleButtons(didCompletePuzzle: Bool, wasCorrect: Bool=true) {
        let workItem = DispatchWorkItem {
            UIView.animate(withDuration: 0.2) {
                self.tryAgainButton.isHidden = false
                self.nextButton.isHidden = false
                self.showPiecesButton.isHidden = true
                self.hidePiecesButton.isHidden = true
                if didCompletePuzzle && wasCorrect {
                    self.nextButton.setImage(self.nextButton.imageView?.image?.withTintColor(CommonUI().greenCorrect), for: .normal)
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
            self.nextButton.isHidden = true
            self.nextButton.setImage(self.nextButton.imageView?.image?.withTintColor(CommonUI().lightGray), for: .normal)
            self.showPiecesButton.isHidden = !self.piecesHidden
            self.hidePiecesButton.isHidden = self.piecesHidden
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
        boardController.view.isUserInteractionEnabled = false
        if wasCorrect && !isShowingPieces {
            boardController.showPieces()
            isShowingPieces = true
        }
        
        showPostPuzzleButtons(didCompletePuzzle: true, wasCorrect: wasCorrect)
    }
    
    func cancelWorkItems() {
        workItems.forEach({$0.cancel()})
    }
}

extension PuzzleLearningController: BoardDelegate {
    func didMakeMove(move: Move, animated: Bool) {
        let workItem = DispatchWorkItem {
            self.boardController.pushMove(move: move, animated: animated)
        }
        workItems.append(workItem)
        self.boardController.view.isUserInteractionEnabled = false
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
            let workItem = DispatchWorkItem {
                self.boardController.pushMove(move: responseMove, animated: true) {
                    self.boardController.view.isUserInteractionEnabled = true
                }
            }
            workItems.append(workItem)
            self.boardController.view.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
        }
    }
}

