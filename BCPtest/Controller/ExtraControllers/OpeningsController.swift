//
//  OpeningsController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 9/11/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import ChessKit

class OpeningsController: UIViewController {
    
    // MARK: - Properties
    
    private var workItems: [DispatchWorkItem] = []
    var boardController: BoardController!
    var commonMovesTable: CommonMovesTableController!
    var limitReachedController: ExplorerLimitReachedController!
    
    let startFEN: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
    let topLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = true
        return l
    }()
    
    var restartButton: UIButton!
    var nextButton: UIButton!
    var backButton: UIButton!
    var buttonStack: UIStackView!
    var tabBarFiller: UIView!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        configAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.commonMovesTable.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        setFrames()
    }
    
    // MARK: - Config
    
    func configUI() {
        configNavBar()
        view.addSubview(topLabel)
        
        let boardW = UIDevice.current.userInterfaceIdiom == .pad ? view.bounds.width*0.75 : view.bounds.width
        boardController = BoardController(sideLength: boardW, fen: startFEN, showPiecesInitially: true)
        boardController.delegate = self
        view.addSubview(boardController.view)
        
        commonMovesTable = CommonMovesTableController(style: .grouped)
        commonMovesTable.delegate = self
        view.addSubview(commonMovesTable.tableView)
        
        restartButton = PuzzleUI().configureButton(title: "", imageName: "arrow.counterclockwise")
        restartButton.addTarget(self, action: #selector(restartAction), for: .touchUpInside)
        backButton = PuzzleUI().configureButton(title: "", imageName: "arrow.left")
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        nextButton = PuzzleUI().configureButton(title: "", imageName: "arrow.right")
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        buttonStack = PuzzleUI().configureButtonHStack(arrangedSubViews: [restartButton, backButton, nextButton])
        tabBarFiller = CommonUI().configTabBarFiller()
        view.addSubview(tabBarFiller)
        view.addSubview(buttonStack)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        topLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        tabBarFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tabBarFiller.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tabBarFiller.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tabBarFiller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        buttonStack.bottomAnchor.constraint(equalTo: tabBarFiller.topAnchor, constant: 0).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: tabBarHeight).isActive = true
    }
    
    func setFrames() {
        let boardW = UIDevice.current.userInterfaceIdiom == .pad ? view.bounds.width*0.75 : view.bounds.width
        let boardX = UIDevice.current.userInterfaceIdiom == .pad ? view.frame.midX - boardW/2.0 : 0
        let boardY = topLabel.frame.origin.y + topLabel.frame.height
        boardController.view.frame = CGRect(x: boardX, y: boardY, width: boardW, height: boardW)
        
        let tableY = boardController.view.frame.maxY
        let tableW = view.bounds.width
        let tableH:CGFloat = buttonStack.frame.minY - tableY
        commonMovesTable.tableView.frame = CGRect(x: 0, y: tableY, width: tableW, height: tableH)
    }
    
    func configNavBar() {
           navigationController?.navigationBar.isTranslucent = false
           navigationController?.navigationBar.barTintColor = CommonUI().navBarColor
           navigationController?.navigationBar.tintColor = .lightGray
           navigationController?.navigationBar.tintColor = .white
           navigationController?.navigationBar.shadowImage = UIImage()
           let font = UIFont(name: fontStringBold, size: 17)
           navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.white]
           navigationItem.title = "Opening Explorer"
       }
    
    // MARK: - Selectors
    
    @objc func restartAction() {
        DispatchQueue.main.async {
            self.boardController.overridePosition(withFEN: self.startFEN, isStartPosition: true)
            self.commonMovesTable.currentMoveNumber = 1
            self.commonMovesTable.displayPositionData(forFEN: self.startFEN)
        }
    }
    
    @objc func backAction() {
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.boardController.loadPreviousPosition { (didLoadPrevious) in
                if didLoadPrevious {
                    let currentFEN = FenSerialization.default.serialize(position: self.boardController.game.position)
                    self.commonMovesTable.currentMoveNumber -= 1
                    self.commonMovesTable.displayPositionData(forFEN: currentFEN)
                }
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc func nextAction() {
        if UserDataManager().hasReachedExplorerLimit(moveCount: self.commonMovesTable.currentMoveNumber / 2) {
            pushLimitReachedController()
            return
        }
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.boardController.loadNextPosition { (didLoadNext) in
                if didLoadNext {
                    let currentFEN = FenSerialization.default.serialize(position: self.boardController.game.position)
                    self.commonMovesTable.currentMoveNumber += 1
                    self.commonMovesTable.displayPositionData(forFEN: currentFEN)
                }
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func pushLimitReachedController() {
        limitReachedController = ExplorerLimitReachedController()
        limitReachedController.delegate = self
        view.addSubview(limitReachedController.view)
    }
}

extension OpeningsController: BoardDelegate {
    func didMakeMove(move: Move, animated: Bool) {
        if UserDataManager().hasReachedExplorerLimit(moveCount: self.commonMovesTable.currentMoveNumber / 2) {
            pushLimitReachedController()
            return
        }
        view.isUserInteractionEnabled = false
        let workItem = DispatchWorkItem {
            self.boardController.pushMove(move: move, animated: animated) {
                let currentFEN = FenSerialization.default.serialize(position: self.boardController.game.position)
                self.commonMovesTable.currentMoveNumber += 1
                self.commonMovesTable.displayPositionData(forFEN: currentFEN)
                self.view.isUserInteractionEnabled = true
            }
        }
        workItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem)
    }
}

extension OpeningsController: CommonMovesTableDelegate {
    func didSelectMove(move: CommonMove) {
        if UserDataManager().hasReachedExplorerLimit(moveCount: self.commonMovesTable.currentMoveNumber / 2) {
            pushLimitReachedController()
            return
        }
        var moveUCI = move.uci
        if move.san == "O-O" || move.san == "O-O-O" {
            moveUCI = moveUCI.replacingOccurrences(of: "a", with: "c")
                .replacingOccurrences(of: "h", with: "g")
        }
        let moveToPush = Move(string: moveUCI)
        view.isUserInteractionEnabled = false
        let workItem = DispatchWorkItem {
            self.boardController.pushMove(move: moveToPush, animated: true) {
                self.view.isUserInteractionEnabled = true
                let currentFEN = FenSerialization.default.serialize(position: self.boardController.game.position)
                self.commonMovesTable.currentMoveNumber += 1
                self.commonMovesTable.displayPositionData(forFEN: currentFEN)
            }
        }
        workItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem)
        
    }
    
    func didSelectGame(game: TopGame) {
        // push game review controller
    }
    
    func didReachExplorerLimit() {
        boardController.view.isUserInteractionEnabled = false
        commonMovesTable.view.isUserInteractionEnabled = false
        pushLimitReachedController()
        return
    }
    
    func didNotReachExplorerLimit() {
        boardController.view.isUserInteractionEnabled = true
        commonMovesTable.view.isUserInteractionEnabled = true
    }
}

extension OpeningsController: LimitReachedDelegate {
    func didSelectUpgrade() {
        navigationController?.pushViewController(UpgradeController(), animated: true)
    }
    
    func didDismiss() {
        limitReachedController.view.removeFromSuperview()
    }
}
