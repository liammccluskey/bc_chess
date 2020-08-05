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
    var puzzleUI = PuzzleUI(
        boardTheme: UserDataManager().getBoardColor()!,
        buttonTheme: UserDataManager().getButtonColor()!)
    
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
    var piecesShownSegment: UISegmentedControl!
    
    // stack 1
    var stack1: UIStackView!
    var chessBoardController: ChessBoardController!
    var solutionm4: UIView!
    var solutionm3: UIView!
    var solutionm2: UIView!
    var solutionm1: UIView!
    var solutionViews: [UIView] = []
    var header2Label: UILabel = CommonUI().configureHeaderLabel(title: "STARTING POSITION")
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!
    
    // bottom buttons
    var exitButton: UIButton!
    var themeButton: UIButton!
    var boardC: UIButton!
    var buttC: UIButton!
    var pieceS: UIButton!
    var colorButton: UIButton!
    var showSolutionButton: UIButton!
    var nextButton: UIButton!
    var buttonStack: UIStackView!
    
    // Theme Picker
    var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    var themeStack: UIStackView!
    
    
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
        configureNavigationBar()
        configureScrollView()
        piecesShownSegment = puzzleUI.configurePiecesShownSegCont()
        //piecesShownSegment = configureSegment(items: ["HIDE PIECES", "SHOW PIECES"])
        configurePageData(isReload: false)
        
        playerToMoveLabel = puzzleUI.configureToMoveLabel(playerToMove: currentPuzzle.player_to_move)
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
        stack1.setCustomSpacing(0, after: chessBoardController.view)
        containerView.addSubview(stack1)
        
        // buttons
        exitButton = puzzleUI.configureButton(title: "   EXIT   ", titleColor: .white, borderColor: .white)
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        themeButton = puzzleUI.configureButton(title: "BOARD THEME", titleColor: .white, borderColor: .white)
        themeButton.addTarget(self, action: #selector(themeAction), for: .touchUpInside)
        showSolutionButton = puzzleUI.configureButton(title: "SOLUTION", titleColor: .white, borderColor: .white)
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        nextButton = puzzleUI.configureButton(title: "   NEXT   ", titleColor: .white, borderColor: .white)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        buttonStack = puzzleUI.configureButtonHStack(arrangedSubViews: [
            exitButton,themeButton,
            showSolutionButton,nextButton
        ])
        view.addSubview(buttonStack)
        view.addSubview(retryButton)
      
        //view.backgroundColor = CommonUI().blackColor
        view.backgroundColor = .black
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
        
        stack1.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        stack1.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        stack1.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -0).isActive = true
        
        positionTableW.tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: -3).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 5).isActive = true
        positionTableW.tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        positionTableB.tableView.leftAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -3).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 5).isActive = true
        positionTableB.tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
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
            //playerToMoveLabel.textColor = currentPuzzle.player_to_move == "white" ? .white : .black
            //playerToMoveLabel.backgroundColor = UserDataManager().getButtonColor()!.darkSquareColor
            //piecesShownSegment.backgroundColor = UserDataManager().getButtonColor()!.darkSquareColor
            //piecesShownSegment.selectedSegmentTintColor = UserDataManager().getButtonColor()!.lightSquareColor
            positionTableW.setData(puzzle: currentPuzzle, isWhite: true)
            positionTableB.setData(puzzle: currentPuzzle, isWhite: false)
            positionTableW.tableView.reloadData()
            positionTableB.tableView.reloadData()
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
        
        // Done for reloads and initial loads
        let showPieces = piecesShownSegment.selectedSegmentIndex == 1 ? true : false
        chessBoardController = ChessBoardController(
            position: currentPuzzle.position,
            showPiecesInitially: showPieces,
            boardTheme: puzzleUI.boardTheme
        )
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
            stack1.setCustomSpacing(0, after: chessBoardController.view)
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
    
    @objc func themeAction() {
        let controller = ThemeTableController(style: .insetGrouped)
        controller.delegate = self
        present(controller, animated: true)
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

extension PuzzleController: ThemeTableDelegate {
    func didSubmitChangeAt(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let boardColor = ColorTheme(rawValue: indexPath.row)
            UserDataManager().setBoardColor(boardColor: boardColor!)
        case 1:
            UserDataManager().setPieceStyle(pieceStyle: indexPath.row)
            pieceStyle = indexPath.row
        case 2:
            let buttonColor = ColorTheme(rawValue: indexPath.row)
            UserDataManager().setButtonColor(buttonColor: buttonColor!)
        default: print()
        }
        DispatchQueue.main.async {
            self.puzzleUI = PuzzleUI(
                boardTheme: UserDataManager().getBoardColor()!,
                buttonTheme: UserDataManager().getButtonColor()!
            )
            self.restartPuzzle(isNewPuzzle: false)
            self.configurePageData(isReload: true)
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

extension PuzzleController {
    func configureSegment(items: [String]) -> UISegmentedControl {
     let sc = UISegmentedControl(items: items)
     let font = UIFont(name: fontString, size: 16)
     sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().csRed], for: .selected)
     sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.lightGray], for: .normal)
     sc.tintColor = .lightGray
     sc.selectedSegmentIndex = 0
     sc.backgroundColor = .clear
     sc.selectedSegmentTintColor = CommonUI().blackColor
     sc.layer.cornerRadius = 20
     sc.clipsToBounds = true
     return sc
    }
}




