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
        label.text = "Select Piece Visibility and Puzzle Type"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 16)
        label.backgroundColor = .clear
        return label
    }()
    var piecesShownButton: UIButton!
    var piecesHiddenButton: UIButton!
    var trainingButton: UIButton!
    var rushButton: UIButton!
    var submodeSegment: UISegmentedControl!
    var playButton: UIButton!
    
    var dailyPuzzlesCollection: DailyPuzzlesCollectionController!
    
    let header2Label: UILabel = {
        let label = UILabel()
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        label.text = "Daily Puzzles - \(dateString)"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: fontString, size: 20)
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
        configureNavigationBar()

        piecesShownButton = configureModeButton(puzzleMode: 2)
        piecesHiddenButton = configureModeButton(puzzleMode: 3)
        trainingButton = configureModeButton(puzzleMode: 0)
        rushButton = configureModeButton(puzzleMode: 1)
        submodeSegment = configureSegment(items: ["Rated", "Learning"])
        
        stack1 = configureStackView(arrangedSubViews: [
            header1Label,
                CommonUI().configureHStackView(arrangedSubViews: [piecesShownButton, piecesHiddenButton]),
                CommonUI().configureHStackView(arrangedSubViews: [trainingButton, rushButton]),
                submodeSegment,
                configurePuzzleTypeButton(title: "Play", tag: 4),
            header2Label,
        ])
        view.addSubview(stack1)
        
        let flow = UICollectionViewFlowLayout()
        dailyPuzzlesCollection = DailyPuzzlesCollectionController(collectionViewLayout: flow)
        dailyPuzzlesCollection.delegate = self
        dailyPuzzlesCollection.puzzles = puzzles.m4
        dailyPuzzlesCollection.collectionView.reloadData()
        view.addSubview(dailyPuzzlesCollection.collectionView)

        view.backgroundColor = CommonUI().blackColor
    }
    
    func configureAutoLayout() {
        stack1.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        dailyPuzzlesCollection.collectionView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 10).isActive = true
        dailyPuzzlesCollection.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        dailyPuzzlesCollection.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        dailyPuzzlesCollection.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        let font = UIFont(name: fontString, size: 25)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.lightGray]
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
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func configurePuzzleTypeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 20)
        /*
        button.backgroundColor = CommonUI().csRed
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(mateAction), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
 */
        button.backgroundColor = CommonUI().blackColor
        button.layer.borderWidth = 3.5
        button.layer.borderColor = UIColor(red: 31/255, green: 32/255, blue: 35/255, alpha: 1).cgColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(mateAction), for: .touchUpInside)
        button.setTitleColor(CommonUI().csRed, for: .normal)
        
        return button
    }
    
    // MARK: - Selectors
    
    @objc func modeAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            trainingButton.tintColor = CommonUI().csRed
            trainingButton.setTitleColor(CommonUI().csRed, for: .normal)
            rushButton.tintColor = .lightGray
            rushButton.setTitleColor(.lightGray, for: .normal)
            submodeSegment.removeAllSegments()
            submodeSegment.insertSegment(withTitle: "Rated", at: 0, animated: false)
            submodeSegment.insertSegment(withTitle: "Learning", at: 1, animated: false)
            submodeSegment.selectedSegmentIndex = 0
        case 1:
            trainingButton.tintColor = .lightGray
            trainingButton.setTitleColor(.lightGray, for: .normal)
            rushButton.tintColor = CommonUI().csRed
            rushButton.setTitleColor(CommonUI().csRed, for: .normal)
            submodeSegment.removeAllSegments()
            submodeSegment.insertSegment(withTitle: "3 min", at: 0, animated: false)
            submodeSegment.insertSegment(withTitle: "5 min", at: 1, animated: false)
            submodeSegment.selectedSegmentIndex = 0
        case 2:
            piecesShownButton.tintColor = CommonUI().csRed
            piecesShownButton.setTitleColor(CommonUI().csRed, for: .normal)
            piecesHiddenButton.tintColor = .lightGray
            piecesHiddenButton.setTitleColor(.lightGray, for: .normal)
        case 3:
            piecesShownButton.tintColor = .lightGray
            piecesShownButton.setTitleColor(.lightGray, for: .normal)
            piecesHiddenButton.tintColor = CommonUI().csRed
            piecesHiddenButton.setTitleColor(CommonUI().csRed, for: .normal)
        default: return
        }
    }
    
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
    
    // MARK: - Test
    
    func configureModeButton(puzzleMode: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = puzzleMode
        button.backgroundColor = .clear
        button.setTitle(PuzzleMode(rawValue: puzzleMode)?.description, for: .normal)
        button.setImage(PuzzleMode(rawValue: puzzleMode)?.image, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(
            top: 0, left: (button.imageView?.frame.width)! + 10, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(modeAction), for: .touchUpInside)
        let tintColor = puzzleMode%2 == 0 ? CommonUI().csRed : .lightGray
        button.tintColor = tintColor
        button.setTitleColor(tintColor, for: .normal)
        return button
    }
    
    func configureSegment(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        let font = UIFont(name: fontString, size: 15)
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

enum PuzzleMode: Int, CustomStringConvertible {
    case training, rush, piecesShown, piecesHidden
    var description: String {
        switch self {
        case .training: return "Training"
        case .rush: return "Rush"
        case .piecesShown: return "Regular"
        case .piecesHidden: return "Blind"
        }
    }
    var image: UIImage {
        switch self {
        case .training: return #imageLiteral(resourceName: "training_mode").withRenderingMode(.alwaysTemplate)
        case .rush: return #imageLiteral(resourceName: "rush_mode").withRenderingMode(.alwaysTemplate)
        case .piecesShown: return #imageLiteral(resourceName: "pieces_shown_mode").withRenderingMode(.alwaysTemplate)
        case .piecesHidden: return #imageLiteral(resourceName: "pieces_hidden_mode").withRenderingMode(.alwaysTemplate)
        }
    }
}

extension HomeController: DailyPuzzlesCollectionDelegate {
    
    func didSelectPuzzle(puzzle: Puzzle) {
        let controller = DailyPuzzleController(puzzles: [puzzle])
        present(controller, animated: true)
    }
}


