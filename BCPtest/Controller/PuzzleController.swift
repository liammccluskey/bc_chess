//
//  PuzzleController.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class PuzzleController: UIViewController {
    
    // MARK: - Properties
    let puzzles: [Puzzle]
    var currentPuzzle: Puzzle
    var onSolutionMoveIndex: Int = 0
    var stateIsIncorrect = false
    var pid: Int
    
    var scrollView: UIScrollView!
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = CommonUI().blackColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
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
    var piecesShownSegment: UISegmentedControl = PuzzleUI().configurePiecesShownSegCont()
    
    // stack 1
    var stack1: UIStackView!
    var chessBoardController: ChessBoardController!
    var solutionm4: UIView!
    var solutionm3: UIView!
    var solutionm2: UIView!
    var solutionm1: UIView!
    var solutionViews: [UIView] = []
    let divider2a: UILabel = CommonUI().configureDividerLabel()
    var header2Label: UILabel = CommonUI().configureHeaderLabel(title: "STARTING POSITION")
    let divider2b: UILabel = CommonUI().configureDividerLabel()
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!
    
    // bottom buttons
    var exitButton: UIButton!
    var colorButton: UIButton!
    var showSolutionButton: UIButton!
    var nextButton: UIButton!
    var buttonStack: UIStackView!
    
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
        
        configureUI()
        setUpAutoLayout(isInitLoad: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Config
    
    func configureUI() {
        configureNavigationBar()
        configureScrollView()
        configurePageData(isReload: false)
        
        playerToMoveLabel = PuzzleUI().configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
        view.insertSubview(playerToMoveLabel, at: 0)
        
        piecesShownSegment.addTarget(self, action: #selector(piecesShownAction), for: .valueChanged)
        var stack1Views: [UIView] = [
            chessBoardController.view,
            piecesShownSegment
            // index: 2 -> put solution views here
            /*divider2a,header2Label,divider2b,*/
            ]
        stack1Views.insert(contentsOf: solutionViews, at: 2)
        stack1 = CommonUI().configureStackView(arrangedSubViews: stack1Views)
        containerView.addSubview(stack1)
        
        // buttons
        exitButton = PuzzleUI().configureButton(title: "EXIT", titleColor: .white, borderColor: .white)
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        showSolutionButton = PuzzleUI().configureButton(title: "SOLUTION", titleColor: .white, borderColor: .white)
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "NEXT", titleColor: .white, borderColor: .white)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        colorButton = PuzzleUI().configureButton(title: "BOARD COLOR", titleColor: .white, borderColor: .white)
        colorButton.addTarget(self, action: #selector(colorAction), for: .touchUpInside)
        
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton,colorButton,showSolutionButton,nextButton])
        view.addSubview(buttonStack)
        view.addSubview(retryButton)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func setUpAutoLayout(isInitLoad: Bool) {
        if isInitLoad {
            // global anchors
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 38).isActive = true
            
            retryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            retryButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            retryButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            retryButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            playerToMoveLabel.topAnchor.constraint(equalTo: retryButton.topAnchor).isActive = true
            playerToMoveLabel.leftAnchor.constraint(equalTo: retryButton.leftAnchor).isActive = true
            playerToMoveLabel.rightAnchor.constraint(equalTo: retryButton.rightAnchor).isActive = true
            playerToMoveLabel.bottomAnchor.constraint(equalTo: retryButton.bottomAnchor).isActive = true
            
            // scroll view
            scrollView.topAnchor.constraint(equalTo: retryButton.bottomAnchor).isActive = true
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
            containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            containerView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: view.frame.height*1.1).isActive = true
        }
        
        stack1.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4).isActive = true
        stack1.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        stack1.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -0).isActive = true
        
        positionTableW.tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 2).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 5).isActive = true
        //positionTableW.tableView.heightAnchor.constraint(equalToConstant: 340).isActive = true
        positionTableW.tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        positionTableB.tableView.leftAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -2).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 5).isActive = true
        //positionTableB.tableView.heightAnchor.constraint(equalToConstant: 340).isActive = true
        positionTableB.tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
    }
    
    func configureScrollView() {
        scrollView = UIScrollView(frame: .zero)
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
    }
    
    func configurePageData(isReload: Bool) {
        if !isReload {
            positionTableW = PositionTableController(puzzle: currentPuzzle, isWhite: true)
            positionTableB = PositionTableController(puzzle: currentPuzzle, isWhite: false)
            containerView.addSubview(positionTableW.tableView)
            containerView.addSubview(positionTableB.tableView)
        } else {
            playerToMoveLabel.text = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
            playerToMoveLabel.textColor = currentPuzzle.player_to_move == "white" ? .white : .black
            positionTableW.setData(puzzle: currentPuzzle, isWhite: true)
            positionTableB.setData(puzzle: currentPuzzle, isWhite: false)
            positionTableW.tableView.reloadData()
            positionTableB.tableView.reloadData()
        }
        
        if currentPuzzle.solution_moves.count == 4 {
            solutionm4 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[0], matePly: 3)
            solutionm3 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[1], matePly: 2)
            solutionm2 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[2], matePly: 1)
            solutionm1 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[3], matePly: 0)
            solutionViews = [solutionm4, solutionm3, solutionm2, solutionm1]
        } else if currentPuzzle.solution_moves.count == 3 {
            solutionm3 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[0], matePly: 2)
            solutionm2 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[1], matePly: 1)
            solutionm1 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[2], matePly: 0)
            solutionViews = [solutionm3, solutionm2, solutionm1]
        } else if currentPuzzle.solution_moves.count == 2 {
            solutionm2 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[0], matePly: 1)
            solutionm1 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[1], matePly: 0)
            solutionViews = [solutionm2, solutionm1]
        } else {
            solutionm1 = PuzzleUI().configureAnswerView(move: currentPuzzle.solution_moves[0], matePly: 0)
            solutionViews = [solutionm1]
        }
        solutionViews.forEach{ (view) in
            view.isHidden = true
        }
        
        // Done for reloads and initial loads
        let showPieces = piecesShownSegment.selectedSegmentIndex == 1 ? true : false
        chessBoardController = ChessBoardController(position: currentPuzzle.position, showPiecesInitially: showPieces)
        chessBoardController.delegate = self
        
        // move this
        if isReload {
            stack1.removeFromSuperview()
            var stack1Views: [UIView] = [
                chessBoardController.view,
                piecesShownSegment
                // index: 2 -> put solution views here
                /*divider2a,header2Label,divider2b,*/
                ]
            stack1Views.insert(contentsOf: solutionViews, at: 2)
            stack1 = CommonUI().configureStackView(arrangedSubViews: stack1Views)
            containerView.addSubview(stack1)
            
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
    
    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func colorAction() {
        boardColor = ["gray", "green", "darkBlue", "tan"].randomElement()!
        pieceStyle = ["lichess", "simple", "fancy"].randomElement()!
    }
    
    @objc func showSolutionAction() {
        configPageForSolutionState(
            isShowingSolution: true,
            stateIsIncorrect: stateIsIncorrect,
            stateIsPartialCorrect: true)
    }
    
    @objc func nextAction() {
        restartPuzzle(isNewPuzzle: true)
        pid = Int.random(in: 0..<puzzles.count)
        currentPuzzle = puzzles[self.pid]
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

extension PuzzleController: ChessBoardDelegate {
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

class ButtonWithImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 3, left: (bounds.width - 50), bottom: 3, right: 20)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!)
            imageView?.contentMode = .scaleAspectFit
        }
    }
}


