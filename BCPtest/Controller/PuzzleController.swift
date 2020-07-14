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
    var solutionm3: UIView!
    var solutionm2: UIView!
    var solutionm1: UIView!
    var solutionViews: [UIView] = []
    
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
        configurePageData(isReload: false)
    
        stack1 = CommonUI().configureStackView(arrangedSubViews: [
            divider1Label,
            header1Label,
            divider2Label
            ])
        view.addSubview(stack1)
        
        // solution section
        var stack2Views: [UIView] = [divider2a,header2Label,divider2b,subheader2Label]
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
        positionTableW.tableView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        positionTableW.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        positionTableW.tableView.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -4).isActive = true
        positionTableW.tableView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        
        //positionTableB.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        positionTableB.tableView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
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
        
        // move this
        if isReload {
            stack2.removeFromSuperview()
            var stack2Views: [UIView] = [divider2a,header2Label,divider2b,subheader2Label]
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
        pid = Int.random(in: 1...puzzles.count)
        currentPuzzle = puzzles[self.pid]
        configurePageData(isReload: true)
    }
}
