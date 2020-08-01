//
//  HomeController.swift
//  BCPtest
//
//  Created by Marty McCluskey on 4/30/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    var boardController: ChessBoardController!
    
    // MARK: - Properties
    
    var puzzles: Puzzles! = PuzzlesFromJson().puzzles
    
    let header1Label: UILabel = {
        let label = UILabel()
        label.text = "Blindfold Chess Puzzles"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 24)
        label.backgroundColor = .clear
        return label
    }()
    var mate1Button: UIButton!
    var mate2Button: UIButton!
    var mate3Button: UIButton!
    var mate4Button: UIButton!
    
    let header2Label: UILabel = {
        let label = UILabel()
        label.text = "Daily Puzzles"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 24)
        label.backgroundColor = .clear
        return label
    }()
    
    var stack1: UIStackView!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureAutoLayout()
    }
    
    // MARK: - Config
    
    func configureUI() {
        // test
        let puzzle = puzzles.m4.randomElement()!
        boardController = ChessBoardController(position: puzzle.position, showPiecesInitially: true, boardTheme: .tan)
        let puzzle1 = puzzles.m4.randomElement()!
        let boardController1 = ChessBoardController(position: puzzle1.position, showPiecesInitially: true, boardTheme: .tan)
        
        // end test
        configureNavigationBar()
        mate1Button = configurePuzzleTypeButton(title: "MATE   in   1", tag: 1)
        mate2Button = configurePuzzleTypeButton(title: "MATE   in   2", tag: 2)
        mate3Button = configurePuzzleTypeButton(title: "MATE   in   3", tag: 3)
        mate4Button = configurePuzzleTypeButton(title: "MATE   in   4", tag: 4)
        
        stack1 = configureStackView(arrangedSubViews: [
            header1Label,
                mate1Button,
                mate2Button,
                mate3Button,
                mate4Button,
            header2Label,
            CommonUI().configureHStackView(arrangedSubViews: [boardController.view, boardController1.view])
        ])
        stack1.setCustomSpacing(20, after: mate4Button)
               
        view.addSubview(stack1)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configureAutoLayout() {
        stack1.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 25)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.white]
        navigationItem.title = "Puzzles"
        
        let infoButton = UIButton(type: .infoDark)
        infoButton.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    func configureStackView(arrangedSubViews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.alignment = .fill
        //stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func configurePuzzleTypeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontStringLight, size: 20)
        button.backgroundColor = .clear
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(mateAction), for: .touchUpInside)
        button.layer.borderColor = CommonUI().blueColor.cgColor
        button.setTitleColor(.white, for: .normal)
        return button
    }
    
    // MARK: - Selectors
    
    @objc func mateAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let controller = PuzzleController(puzzles: puzzles.m1)
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true); break
        case 2:
            let controller = PuzzleController(puzzles: puzzles.m2)
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true); break
        case 3:
            let controller = PuzzleController(puzzles: puzzles.m3)
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true); break
        case 4:
            let controller = PuzzleController(puzzles: puzzles.m4)
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true); break
        default:
            break
        }
    }
    
    @objc func infoAction() {
        let puzzle = puzzles.m4.randomElement()!
        let controller = DailyPuzzleController(puzzles: [puzzle])
        present(controller, animated: true)
    }
}
