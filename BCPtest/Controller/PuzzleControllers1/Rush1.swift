//
//  PuzzleRushController11.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 9/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import CoreData
import ChessKit


class PuzzleRushController1: UIViewController {
    
    // MARK: - Properties
    private var workItems: [DispatchWorkItem] = []
    var limitReachedController: LimitReachedController!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var puzzledUser: PuzzledUser!
    var piecesHidden: Bool!
    var pRef: PuzzleReference!
    var currentPuzzle: Puzzle!
    var onSolutionMoveIndex: Int = 0
    
    var incorrectButton: UIButton! // action: retry puzzle, color red
    var correctButton: UIButton! // action: next puzzle, color green
    var postSolutionButton: UIButton! // action: retry puzzle, color green
    
    var playerToMoveLabel: UILabel!
    var ratingLabel: UILabel!
    var deltaLabel: UILabel!
    var puzzleRatingLabel: UILabel!
    
    // stack 1
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
        setUpAutoLayout()
        
        if UserDataManager().hasReachedPuzzleLimit() {
            limitReachedController = LimitReachedController()
            limitReachedController.delegate = self
            view.addSubview(limitReachedController.view)
        }
    }
    
    override func viewDidLayoutSubviews() {
        correctButton.frame = playerToMoveLabel.frame
        incorrectButton.frame = playerToMoveLabel.frame
        postSolutionButton.frame = playerToMoveLabel.frame
        if piecesHidden {
            boardController.view.frame.origin.y = ratingLabel.frame.origin.y + 3 + ratingLabel.frame.height
        } else {
            boardController.view.frame.origin.y = view.frame.midY - boardController.view.frame.height/2
        }
        solutionLabel.frame.origin.y = boardController.view.frame.origin.y + boardController.view.frame.height + 0
        let tvY = solutionLabel.frame.origin.y + solutionLabel.frame.height + 0
        let tvX = view.frame.width/2
        let tvHeight = buttonStack.frame.origin.y - tvY
        positionTableB.tableView.frame = CGRect(x: 0, y: tvY, width: tvX, height: tvHeight)
        positionTableW.tableView.frame = CGRect(x: tvX, y: tvY, width: tvX, height: tvHeight)
        view.layoutIfNeeded()
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
        
        ratingLabel = PuzzleUI().configRatingLabel()
        ratingLabel.setRating(forPuzzledUser: puzzledUser, isBlindfold: piecesHidden)
        deltaLabel = PuzzleUI().configDeltaLabel()
        puzzleRatingLabel = PuzzleUI().configRatingLabel()
        puzzleRatingLabel.setPuzzleRating(forPuzzleReference: pRef, isBlindfold: piecesHidden)
        view.addSubview(ratingLabel)
        view.addSubview(deltaLabel)
        view.addSubview(puzzleRatingLabel)
        
        boardController = BoardController(sideLength: view.bounds.width, fen: currentPuzzle.fen, showPiecesInitially: !piecesHidden)
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
        showSolutionButton = PuzzleUI().configureButton(title: "  Solution", imageName: "lightbulb")
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        
        tryAgainButton = PuzzleUI().configureButton(title: "  Retry", imageName: "arrow.counterclockwise", weight: .bold)
        tryAgainButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "  Next", imageName: "arrow.right", weight: .bold)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        tryAgainButton.isHidden = true
        nextButton.isHidden = true
        
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton,showSolutionButton,tryAgainButton,nextButton])
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
        let upperPadding: CGFloat = piecesHidden ? 3 : 10
        
        tabBarFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tabBarFiller.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tabBarFiller.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tabBarFiller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        buttonStack.bottomAnchor.constraint(equalTo: tabBarFiller.topAnchor, constant: 0).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: tabBarHeight).isActive = true
        
        playerToMoveLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        playerToMoveLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerToMoveLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerToMoveLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        ratingLabel.topAnchor.constraint(equalTo: playerToMoveLabel.bottomAnchor, constant: upperPadding).isActive = true
        ratingLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        deltaLabel.leftAnchor.constraint(equalTo: ratingLabel.rightAnchor, constant: 10).isActive = true
        deltaLabel.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor).isActive = true
        puzzleRatingLabel.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor).isActive = true
        puzzleRatingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    
        solutionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        solutionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
    }
    
    func updatePageData(isNewPuzzle: Bool) {
        puzzledUser = UserDBMS().getPuzzledUser()
        ratingLabel.setRating(forPuzzledUser: puzzledUser, isBlindfold: piecesHidden)
        if isNewPuzzle == false {return}
        playerToMoveLabel.text = "\(currentPuzzle.player_to_move.capitalized) to Move"
        playerToMoveLabel.backgroundColor = currentPuzzle.player_to_move == "white" ? CommonUI().softWhite : .black //CommonUI().blackColorLight
        playerToMoveLabel.textColor = currentPuzzle.player_to_move == "white" ? CommonUI().blackColorLight : CommonUI().softWhite
        positionTableW.setData(puzzle: currentPuzzle, isWhite: true)
        positionTableB.setData(puzzle: currentPuzzle, isWhite: false)
        positionTableW.tableView.reloadData()
        positionTableB.tableView.reloadData()
        puzzleRatingLabel.setPuzzleRating(forPuzzleReference: pRef, isBlindfold: piecesHidden)
    }
    
    func restartPuzzle(withFEN fen: String) {
        solutionLabel.text = ""
        deltaLabel.text = ""
        onSolutionMoveIndex = 0
        boardController.setNewPosition(fen: fen)
        boardController.configStartPosition()
        if piecesHidden {boardController.hidePieces()}
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
        if UserDataManager().hasReachedPuzzleLimit() {
            limitReachedController = LimitReachedController()
            limitReachedController.delegate = self
            view.addSubview(limitReachedController.view)
            return
        }
        pRef = PFJ.getPuzzleReferenceInRange(plusOrMinus: Int32(200), isBlindfold: piecesHidden, forUser: self.puzzledUser)!
        currentPuzzle = PFJ.getPuzzle(fromPuzzleReference: self.pRef)
        restartPuzzle(withFEN: currentPuzzle.fen)
        updatePageData(isNewPuzzle: true)
        cancelWorkItems()
        
        showPrePuzzleButtons()
    }

    
    @objc func retryAction() {
        cancelWorkItems()
        restartPuzzle(withFEN: currentPuzzle.fen)
        updatePageData(isNewPuzzle: false)
        
        showPrePuzzleButtons()
    }
    
    // MARK: - IDK
    
    func showPostPuzzleButtons(didCompletePuzzle: Bool, wasCorrect: Bool=true) {
        let workItem = DispatchWorkItem {
            UIView.animate(withDuration: 0.2) {
                self.tryAgainButton.isHidden = false
                self.nextButton.isHidden = false
                if didCompletePuzzle && wasCorrect {
                    self.nextButton.setImage(self.nextButton.imageView?.image?.withTintColor(CommonUI().greenCorrect), for: .normal)
                    self.view.bringSubviewToFront(self.correctButton)
                } else if didCompletePuzzle && !wasCorrect {
                    self.tryAgainButton.setImage(self.tryAgainButton.imageView?.image?.withTintColor(CommonUI().redIncorrect), for: .normal)
                    self.view.bringSubviewToFront(self.incorrectButton)
                } else {
                    self.tryAgainButton.setImage(self.tryAgainButton.imageView?.image?.withTintColor(CommonUI().greenCorrect), for: .normal)
                    self.view.bringSubviewToFront(self.postSolutionButton)
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
            self.tryAgainButton.isHidden = true
            self.tryAgainButton.setImage(self.tryAgainButton.imageView?.image?.withTintColor(CommonUI().lightGray), for: .normal)
            self.nextButton.isHidden = true
            self.nextButton.setImage(self.nextButton.imageView?.image?.withTintColor(CommonUI().lightGray), for: .normal)
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
        if wasCorrect && piecesHidden { boardController.showPieces() }
        let ratingDelta = savePuzzleAttempt(wasCorrect: wasCorrect)
        deltaLabel.setDelta(delta: ratingDelta)
        
        showPostPuzzleButtons(didCompletePuzzle: true, wasCorrect: wasCorrect)
    }
    
    func cancelWorkItems() {
        workItems.forEach({$0.cancel()})
    }
}

extension PuzzleRushController1: BoardDelegate {
    func didMakeMove(move: Move, animated: Bool) {
        let workItem = DispatchWorkItem {
            self.boardController.pushMove(move: move, animated: animated)
        }
        workItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem)
        let solutionMoves = currentPuzzle.solution_moves[onSolutionMoveIndex]
        let answerMove = Move(string: solutionMoves.answer_uci)
        
        print("PuzzleController made move: " + move.description)
        print("Answer move is: " + answerMove.description)
        
        if move.description != answerMove.description {
            print("answer was incorrect")
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
                self.boardController.pushMove(move: responseMove, animated: true)
            }
            workItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: workItem)
        }
    }
}

extension PuzzleRushController1 {
    func savePuzzleAttempt(wasCorrect: Bool) -> Int32{
        let ratingDelta = updateUserRating(forPuzzleReference: pRef, wasCorrect: wasCorrect)
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
        puzzledUser.addToPuzzleAttempts(puzzleAttempt)
        do { try context.save() }
        catch { print("error saving puzzle attempt") }
        return ratingDelta
    }
    
    func updateUserRating(forPuzzleReference pRef: PuzzleReference, wasCorrect: Bool) -> Int32 {
        let pElo = piecesHidden ? pRef.eloBlindfold : pRef.eloRegular
        let oldRating = piecesHidden ? puzzledUser.puzzleB_Elo : puzzledUser.puzzle_Elo
        let updatedUser = UserDBMS().updateUserPuzzleElo(forUser: puzzledUser, puzzleRating: pElo, wasCorrect: wasCorrect, isBlindfold: piecesHidden)
        let newRating = piecesHidden ? updatedUser.puzzleB_Elo : updatedUser.puzzle_Elo
        return newRating - oldRating
    }
}

extension PuzzleRushController1: LimitReachedDelegate {
    func didSelectUpgrade() {
        navigationController?.pushViewController(UpgradeController(), animated: true)
    }
    
    func didDismiss() {
        navigationController?.popToRootViewController(animated: true)
    }
}

