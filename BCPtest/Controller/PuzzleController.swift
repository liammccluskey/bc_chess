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
    
    var scrollView: UIScrollView!
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RETRY", for: .normal)
        button.titleLabel?.font = UIFont(name: CommonUI().fontString, size: 20)
        button.backgroundColor = CommonUI().redColor
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var playerToMoveLabel: UILabel!
    
    var piecesShownSegment: UISegmentedControl = PuzzleUI().configurePiecesShownSegCont()
    
    let puzzles: [Puzzle]
    var currentPuzzle: Puzzle
    var onSolutionMoveIndex: Int = 0
    var didCompletePuzzle = false
    var pid: Int
    
    // stack 1
    var stack1: UIStackView!
    var chessBoardController: ChessBoardController!
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
    var showSolutionButton: UIButton!
    var nextButton: UIButton!
    var buttonStack: UIStackView!
    
    // MARK: - Init
    
    init(puzzles: [Puzzle]) {
        self.pid = Int.random(in: 1...puzzles.count)
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
            piecesShownSegment,
            chessBoardController.view,
            // index: 2 -> put solution views here
            /*divider2a,header2Label,divider2b,*/
            ]
        stack1Views.insert(contentsOf: solutionViews, at: 2)
        stack1 = CommonUI().configureStackView(arrangedSubViews: stack1Views)
        containerView.addSubview(stack1)
        
        // buttons
        exitButton = PuzzleUI().configureButton(title: "EXIT", titleColor: .white, borderColor: .white)
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        showSolutionButton = PuzzleUI().configureButton(title: "SHOW SOLUTION", titleColor: .white, borderColor: .white)
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "NEXT", titleColor: .white, borderColor: .white)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [exitButton, showSolutionButton, nextButton])
        view.addSubview(buttonStack)
        view.addSubview(retryButton)
        
        view.backgroundColor = .black
    }
    
    func setUpAutoLayout(isInitLoad: Bool) {
        if isInitLoad {
            // global anchors
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            retryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            retryButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            retryButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            
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
        
        stack1.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        stack1.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        stack1.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -0).isActive = true
        
        positionTableW.tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -4).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        //positionTableW.tableView.heightAnchor.constraint(equalToConstant: 340).isActive = true
        positionTableW.tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        positionTableB.tableView.leftAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 4).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
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
            positionTableW.setData(puzzle: currentPuzzle, isWhite: true)
            positionTableB.setData(puzzle: currentPuzzle, isWhite: false)
            positionTableW.tableView.reloadData()
            positionTableB.tableView.reloadData()
        }
        
        if currentPuzzle.solution_moves.count == 3 {
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
        chessBoardController = ChessBoardController(position: currentPuzzle.position)
        chessBoardController.delegate = self
        
        // move this
        if isReload {
            stack1.removeFromSuperview()
            if piecesShownSegment.selectedSegmentIndex == 1 {chessBoardController.showPieces()}
            var stack1Views: [UIView] = [
                piecesShownSegment,
                chessBoardController.view,
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
        didCompletePuzzle = false
        onSolutionMoveIndex = 0
        chessBoardController.configureStartingPosition()
        chessBoardController.clearSelections()
        chessBoardController.setButtonInteraction(isEnabled: true)
        DispatchQueue.main.async {
            if isNewPuzzle {
                self.retryButton.alpha = 0
            } else {
                UIView.animate(withDuration: 0.3, animations: {
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
        DispatchQueue.main.async {
            self.solutionViews.forEach{ (view) in
                UIView.animate(withDuration: 0.3, animations: {
                    view.isHidden = !view.isHidden
                    self.view.layoutIfNeeded()
                })
            }
        }
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
    }
    
}

extension PuzzleController: ChessBoardDelegate {
    func didMakeMove(moveUCI: String) {
        if didCompletePuzzle {return}
        let solutionUCI = currentPuzzle.solution_moves[onSolutionMoveIndex].answer_uci
        if solutionUCI == moveUCI {
            // test portion below
            let solutionMove: WBMove = currentPuzzle.solution_moves[onSolutionMoveIndex]
            chessBoardController.pushMove(wbMove: solutionMove)
            
            // answer correct
            var didDisplaySolution = false
            solutionViews.forEach{ (view) in
                if view.isHidden && !didDisplaySolution {
                    UIView.animate(withDuration: 0.3, animations: {
                        view.isHidden = !view.isHidden
                        self.view.layoutIfNeeded()
                    })
                    didDisplaySolution = true
                }
            }
            onSolutionMoveIndex = onSolutionMoveIndex + 1
            if onSolutionMoveIndex == currentPuzzle.solution_moves.count {
                didCompletePuzzle = true
                chessBoardController.setButtonInteraction(isEnabled: false)
            }
        } else {
            chessBoardController.displayMove(moveUCI: moveUCI)
            chessBoardController.setButtonInteraction(isEnabled: false)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.retryButton.alpha = 1
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    }


