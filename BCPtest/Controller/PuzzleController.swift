//
//  PuzzleController.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//



// put board on top
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
    
    let puzzles: [Puzzle]
    var currentPuzzle: Puzzle
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
        setUpAutoLayout()
        
    }
    
    // MARK: - Config
    
    func configureUI() {
        configureNavigationBar()
        configureScrollView()
        configurePageData(isReload: false)
        
        var stack1Views: [UIView] = [
            chessBoardController.view,
            // index: 1 -> put solution views here
            divider2a,header2Label,divider2b,
            ]
        stack1Views.insert(contentsOf: solutionViews, at: 1)
        stack1 = CommonUI().configureStackView(arrangedSubViews: stack1Views)
        containerView.addSubview(stack1)
        
        // bottom buttons
        showSolutionButton = PuzzleUI().configureButton(title: "SHOW SOLUTION")
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "NEXT PUZZLE")
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        buttonStack = CommonUI().configureHStackView(arrangedSubViews: [showSolutionButton, nextButton])
        view.addSubview(buttonStack)
        
        view.backgroundColor = .black
    }
    
    func setUpAutoLayout() {
        // global anchors
        buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        // scroll view
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
        
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: view.frame.height*1).isActive = true
        
        stack1.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 1).isActive = true
        stack1.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        stack1.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        
        positionTableW.tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -4).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        positionTableW.tableView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        positionTableB.tableView.leftAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 4).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        positionTableB.tableView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
        navigationController?.navigationBar.prefersLargeTitles = true
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
        
        // move this
        if isReload {
            stack1.removeFromSuperview()
            var stack1Views: [UIView] = [
            chessBoardController.view,
            // index: 1 -> put solution views here
            divider2a,header2Label,divider2b,
            ]
            stack1Views.insert(contentsOf: solutionViews, at: 1)
            stack1 = CommonUI().configureStackView(arrangedSubViews: stack1Views)
            containerView.addSubview(stack1)
            
            setUpAutoLayout()
            
            navigationItem.title = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
        }
    }
    
    // MARK: - Selectors
    
    @objc func showSolutionAction() {
        solutionViews.forEach{ (view) in
            UIView.animate(withDuration: 0.3, animations: {
                view.isHidden = !view.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @objc func nextAction() {
        pid = Int.random(in: 0..<puzzles.count)
        currentPuzzle = puzzles[self.pid]
        configurePageData(isReload: true)
    }
    
    @objc func showBoardAction() {
        let controller = ChessBoardController(position: self.currentPuzzle.position)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

/*

// with scroll view
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
    
    let puzzles: [Puzzle]
    var currentPuzzle: Puzzle
    var pid: Int
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!
    
    // stack 1
    var stack1: UIStackView!
    let divider1Label: UILabel = CommonUI().configureDividerLabel()
    var header1Label: UILabel!
    let divider2Label: UILabel = CommonUI().configureDividerLabel()
    
    // stack 2
    var stack2: UIStackView!
    let divider2a: UILabel = CommonUI().configureDividerLabel()
    var header2Label: UILabel = CommonUI().configureHeaderLabel(title: "SOLUTION")
    let divider2b: UILabel = CommonUI().configureDividerLabel()
    let subheader2Label: UILabel = CommonUI().configureSubheaderLabel(title: "CLICK BELOW FOR SOLUTION")
    var showBoardButton: UIButton!
    var solutionm3: UIView!
    var solutionm2: UIView!
    var solutionm1: UIView!
    var solutionViews: [UIView] = []
    
    var showSolutionButton: UIButton!
    var chessBoardController: ChessBoardController!
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
        setUpAutoLayout()
        
    }
    
    // MARK: - Config
    
    func configureUI() {
        configureNavigationBar()
        configureScrollView()
        configurePageData(isReload: false)
        
        stack1 = CommonUI().configureStackView(arrangedSubViews: [
            divider1Label,
            header1Label,
            divider2Label
            ])
        containerView.addSubview(stack1)
        
        // solution section
        var stack2Views: [UIView] = [divider2a,header2Label,divider2b,chessBoardController.view]
        stack2Views.append(contentsOf: solutionViews)
        stack2 = CommonUI().configureStackView(arrangedSubViews: stack2Views)
        containerView.addSubview(stack2)
        
        // bottom buttons
        showSolutionButton = PuzzleUI().configureButton(title: "SHOW SOLUTION")
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "NEXT PUZZLE")
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        buttonStack = CommonUI().configureHStackView(arrangedSubViews: [showSolutionButton, nextButton])
        view.addSubview(buttonStack)
        
        view.backgroundColor = .black
    }
    
    func setUpAutoLayout() {
        // global anchors
        buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        // scroll view
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
        
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: view.frame.height*1.1).isActive = true
        
        stack1.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 1).isActive = true
        stack1.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        stack1.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        
        //positionTableW.tableView.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        positionTableW.tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -4).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        positionTableW.tableView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        //positionTableB.tableView.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        positionTableB.tableView.leftAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 4).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        positionTableB.tableView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        stack2.topAnchor.constraint(equalTo: positionTableB.tableView.bottomAnchor, constant: 5).isActive = true
        stack2.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        stack2.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "CHESS PUZZLE #\(pid)"
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
            let playerToMove = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
            header1Label = CommonUI().configureHeaderLabel(title: playerToMove)
            positionTableW = PositionTableController(puzzle: currentPuzzle, isWhite: true)
            positionTableB = PositionTableController(puzzle: currentPuzzle, isWhite: false)
            containerView.addSubview(positionTableW.tableView)
            containerView.addSubview(positionTableB.tableView)
        } else {
            header1Label.text = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
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
        
        // move this
        if isReload {
            stack2.removeFromSuperview()
            //var stack2Views: [UIView] = [divider2a,header2Label,divider2b,subheader2Label]
            //var stack2Views: [UIView] = [divider2a,header2Label,divider2b,showBoardButton]
            var stack2Views: [UIView] = [divider2a,header2Label,divider2b,chessBoardController.view]
            stack2Views.append(contentsOf: solutionViews)
            stack2 = CommonUI().configureStackView(arrangedSubViews: stack2Views)
            containerView.addSubview(stack2)
            stack2.topAnchor.constraint(equalTo: positionTableB.tableView.bottomAnchor, constant: 5).isActive = true
            stack2.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
            stack2.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
            
            navigationItem.title = "CHESS PUZZLE #\(pid)"
        }
    }
    
    // MARK: - Selectors
    
    @objc func showSolutionAction() {
        solutionViews.forEach{ (view) in
            UIView.animate(withDuration: 0.3, animations: {
                view.isHidden = !view.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @objc func nextAction() {
        pid = Int.random(in: 0..<puzzles.count)
        currentPuzzle = puzzles[self.pid]
        configurePageData(isReload: true)
    }
    
    @objc func showBoardAction() {
        let controller = ChessBoardController(position: self.currentPuzzle.position)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
 
*/

/*
import UIKit

class PuzzleController: UIViewController {
    
    // MARK: - Properties
    
    let puzzles: [Puzzle]
    var currentPuzzle: Puzzle
    var pid: Int
    var positionTableW: PositionTableController!
    var positionTableB: PositionTableController!

    // stack 1
    var stack1: UIStackView!
    let divider1Label: UILabel = CommonUI().configureDividerLabel()
    var header1Label: UILabel!
    let divider2Label: UILabel = CommonUI().configureDividerLabel()
    
    // stack 2
    var stack2: UIStackView!
    let divider2a: UILabel = CommonUI().configureDividerLabel()
    var header2Label: UILabel = CommonUI().configureHeaderLabel(title: "SOLUTION")
    let divider2b: UILabel = CommonUI().configureDividerLabel()
    let subheader2Label: UILabel = CommonUI().configureSubheaderLabel(title: "CLICK BELOW FOR SOLUTION")
    var showBoardButton: UIButton!
    var solutionm3: UIView!
    var solutionm2: UIView!
    var solutionm1: UIView!
    var solutionViews: [UIView] = []
    
    var showSolutionButton: UIButton!
    var chessBoardController: ChessBoardController!
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
        setUpAutoLayout()
        
    }
    
    // MARK: - Config
    
    func configureUI() {
        configureNavigationBar()
        configurePageData(isReload: false)
    
        stack1 = CommonUI().configureStackView(arrangedSubViews: [
            divider1Label,
            header1Label,
            divider2Label
            ])
        view.addSubview(stack1)
        
        // solution section
        showBoardButton = PuzzleUI().configureButton(title: "SHOW BOARD")
        showBoardButton.addTarget(self, action: #selector(showBoardAction), for: .touchUpInside)
        //var stack2Views: [UIView] = [divider2a,header2Label,divider2b,subheader2Label]
        //var stack2Views: [UIView] = [divider2a,header2Label,divider2b,showBoardButton]
        var stack2Views: [UIView] = [divider2a,header2Label,divider2b,chessBoardController.view]
        stack2Views.append(contentsOf: solutionViews)
        stack2 = CommonUI().configureStackView(arrangedSubViews: stack2Views)
        view.addSubview(stack2)
        
        // bottom buttons
        showSolutionButton = PuzzleUI().configureButton(title: "SHOW SOLUTION")
        showSolutionButton.addTarget(self, action: #selector(showSolutionAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "NEXT PUZZLE")
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        buttonStack = CommonUI().configureHStackView(arrangedSubViews: [showSolutionButton, nextButton])
        view.addSubview(buttonStack)
        
        view.backgroundColor = .black
    }
    
    func setUpAutoLayout() {
        stack1.topAnchor.constraint(equalTo: view.topAnchor, constant: 1).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true

        //positionTableW.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        positionTableW.tableView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        positionTableW.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -4).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        
        //positionTableB.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        positionTableB.tableView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        positionTableB.tableView.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 4).isActive = true
        positionTableB.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        positionTableB.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        
        stack2.topAnchor.constraint(equalTo: positionTableB.tableView.bottomAnchor, constant: 5).isActive = true
        stack2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        stack2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        //buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "CHESS PUZZLE #\(pid)"
    }
    
    func configurePageData(isReload: Bool) {
        
        if !isReload {
            let playerToMove = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
            header1Label = CommonUI().configureHeaderLabel(title: playerToMove)
            positionTableW = PositionTableController(puzzle: currentPuzzle, isWhite: true)
            positionTableB = PositionTableController(puzzle: currentPuzzle, isWhite: false)
            view.addSubview(positionTableW.tableView)
            view.addSubview(positionTableB.tableView)
        } else {
            header1Label.text = "\(currentPuzzle.player_to_move.uppercased()) TO MOVE"
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
        
        // move this
        if isReload {
            stack2.removeFromSuperview()
            //var stack2Views: [UIView] = [divider2a,header2Label,divider2b,subheader2Label]
            //var stack2Views: [UIView] = [divider2a,header2Label,divider2b,showBoardButton]
            var stack2Views: [UIView] = [divider2a,header2Label,divider2b,chessBoardController.view]
            stack2Views.append(contentsOf: solutionViews)
            stack2 = CommonUI().configureStackView(arrangedSubViews: stack2Views)
            view.addSubview(stack2)
            stack2.topAnchor.constraint(equalTo: positionTableB.tableView.bottomAnchor, constant: 5).isActive = true
            stack2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
            stack2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
            
            navigationItem.title = "CHESS PUZZLE #\(pid)"
        }
    }
    
    // MARK: - Selectors
    
    @objc func showSolutionAction() {
        solutionViews.forEach{ (view) in
            UIView.animate(withDuration: 0.3, animations: {
                view.isHidden = !view.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @objc func nextAction() {
        pid = Int.random(in: 0..<puzzles.count)
        currentPuzzle = puzzles[self.pid]
        configurePageData(isReload: true)
    }
    
    @objc func showBoardAction() {
        let controller = ChessBoardController(position: self.currentPuzzle.position)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
 
 */
