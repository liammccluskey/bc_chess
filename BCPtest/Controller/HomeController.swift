//
//  HomeController.swift
//  BCPtest
//
//  Created by Marty McCluskey on 4/30/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeController: UIViewController {
    
    var currentUser: User!
    
    let testL: UILabel = { // paging controller, like spotify -> should be buttons
        let label = UILabel()
        label.text = "Play  Create"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Heavy", size: 36)
        label.backgroundColor = .clear
        return label
    }()
    
    var boardController: ChessBoardController!
    
    // MARK: - Properties
    
    let header1Label: UILabel = {
        let label = UILabel()
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        label.text = " Puzzle games"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Black", size: 24)
        label.backgroundColor = .clear
        return label
    }()
    
    let subheader1Label: UILabel = {
        let label = UILabel()
        label.text = "Select Puzzle Type"
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 16)
        label.backgroundColor = .clear
        return label
    }()
    var piecesShownButton: ModeButton!
    var piecesHiddenButton: ModeButton!
    var trainingButton: ModeButton!
    var rushButton: ModeButton!
    var submodeSegment: UISegmentedControl!
    var playButton: UIButton!
    var isBlindfoldMode: Bool = false
    var isTrainingMode: Bool = true
    
    var dailyPuzzlesCollection: DailyPuzzlesCollectionController!
    
    let header2Label: UILabel = {
        let label = UILabel()
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        label.text = " Daily Puzzles - \(dateString)"
        label.text = " Daily puzzles"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Black", size: 24)
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
    
    override func viewWillAppear(_ animated: Bool) {
        dailyPuzzlesCollection.collectionView.reloadData()
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Config
    
    func configureUI() {
        //configureNavigationBar()

        piecesShownButton = ModeButton(puzzleMode: 2)
        piecesShownButton.wasSelected = true
        piecesHiddenButton = ModeButton(puzzleMode: 3)
        piecesHiddenButton.wasSelected = false
        trainingButton = ModeButton(puzzleMode: 0)
        trainingButton.wasSelected = true
        rushButton = ModeButton(puzzleMode: 1)
        rushButton.wasSelected = false
        piecesShownButton.addTarget(self, action: #selector(modeAction), for: .touchUpInside)
        piecesHiddenButton.addTarget(self, action: #selector(modeAction), for: .touchUpInside)
        trainingButton.addTarget(self, action: #selector(modeAction), for: .touchUpInside)
        rushButton.addTarget(self, action: #selector(modeAction), for: .touchUpInside)
        
        submodeSegment = configureSegment(items: ["Rated", "Learning"])
        playButton = configurePuzzleTypeButton(title: "Play", tag: 4)
        let visStack = CommonUI().configureHStackView(arrangedSubViews: [piecesShownButton, piecesHiddenButton])
        visStack.distribution = .fillEqually
        let modeStack = CommonUI().configureHStackView(arrangedSubViews: [trainingButton, rushButton])
        modeStack.distribution = .fillEqually
        let submodeStack = CommonUI().configureHStackView(arrangedSubViews: [CommonUI().configSpacer(),submodeSegment,CommonUI().configSpacer()])
        
        stack1 = configureStackView(arrangedSubViews: [
            //testL,
            header1Label,
                visStack,
                modeStack,
                submodeStack,
                //submodeSegment,
                playButton,
                header2Label
        ])
        stack1.spacing = 3
        stack1.setCustomSpacing(15, after: submodeStack)
        stack1.setCustomSpacing(30, after: playButton)
        view.addSubview(stack1)
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        dailyPuzzlesCollection = DailyPuzzlesCollectionController(collectionViewLayout: flow)
        dailyPuzzlesCollection.delegate = self
        dailyPuzzlesCollection.puzzles = PFJ.puzzles!.m4
        dailyPuzzlesCollection.collectionView.reloadData()
        view.addSubview(dailyPuzzlesCollection.collectionView)

        view.backgroundColor = CommonUI().blackColor
    }
    
    func configureAutoLayout() {
        stack1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        dailyPuzzlesCollection.collectionView.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 4).isActive = true
        dailyPuzzlesCollection.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        dailyPuzzlesCollection.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        dailyPuzzlesCollection.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        
    }
    
    func configureNavigationBar() {
        /*
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        let font = UIFont(name: fontString, size: 17)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.white]
        navigationItem.title = "Home".uppercased()
        
        let infoButton = UIButton(type: .infoDark)
        infoButton.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
        */
        navigationController?.navigationBar.isHidden = true
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
        button.backgroundColor =  CommonUI().csBlueOpaque //UIColor(red: 3/255, green: 127/255, blue: 68/255, alpha: 1)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        button.setTitleColor(CommonUI().csBlue, for: .normal)
        button.layer.borderColor = CommonUI().csBlue.cgColor
        button.layer.borderWidth = 2
        
        /*
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 20)
        button.backgroundColor = CommonUI().blackColor
        button.layer.borderWidth = 3.5
        button.layer.borderColor = UIColor(red: 33/255, green: 34/255, blue: 37/255, alpha: 1).cgColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        button.setTitleColor(CommonUI().csBlue, for: .normal)
        */
        return button
    }
    
    // MARK: - Selectors
    
    @objc func modeAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            trainingButton.wasSelected = true
            rushButton.wasSelected = false
            submodeSegment.removeAllSegments()
            submodeSegment.insertSegment(withTitle: "Rated", at: 0, animated: false)
            submodeSegment.insertSegment(withTitle: "Learning", at: 1, animated: false)
            submodeSegment.selectedSegmentIndex = 0
            isTrainingMode = true; break
        case 1:
            trainingButton.wasSelected = false
            rushButton.wasSelected = true
            submodeSegment.removeAllSegments()
            submodeSegment.insertSegment(withTitle: "3 min ", at: 0, animated: false)
            submodeSegment.insertSegment(withTitle: "5 min    ", at: 1, animated: false)
            submodeSegment.selectedSegmentIndex = 0
            isTrainingMode = false; break
        case 2:
            piecesShownButton.wasSelected = true
            piecesHiddenButton.wasSelected = false
            isBlindfoldMode = false; break
        case 3:
            piecesShownButton.wasSelected = false
            piecesHiddenButton.wasSelected = true
            isBlindfoldMode = true; break
        default: return
        }
    }
    
    @objc func playAction(_ sender: UIButton) {
        let submode = submodeSegment.selectedSegmentIndex
        var controller: UIViewController!
        if isTrainingMode && submode == 0 { // rated puzzles
            controller = PuzzleRatedController(piecesHidden: isBlindfoldMode)
        } else if isTrainingMode && submode == 1 { // learning puzzles
            controller = PuzzleLearningController(piecesHidden: isBlindfoldMode)
        } else if !isTrainingMode && submode == 0 { // 3 min rush
            controller = PuzzleRushController(piecesHidden: isBlindfoldMode, minutes: 3)
        } else if !isTrainingMode && submode == 1 { // 5 min rush
            controller = PuzzleRushController(piecesHidden: isBlindfoldMode, minutes: 5)
        }
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func infoAction() {
        let puzzle = PFJ.puzzles!.m4.randomElement()!
        let controller = DailyPuzzleController(puzzles: [puzzle])
        present(controller, animated: true)
    }
    
    // MARK: - Test
    
    func configureSegment(items: [String]) -> UISegmentedControl {
        
        let sc = UISegmentedControl(items: items)
        let font = UIFont(name: fontString, size: 17)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.black], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().csBlue], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .black
        sc.selectedSegmentTintColor = CommonUI().csBlue
        return sc

        
        /*
        let sc = UISegmentedControl(items: items)
        let font = UIFont(name: fontString, size: 17)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().csBlue], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.black], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .black
        sc.selectedSegmentTintColor = .black
        return sc
        */
       }
}

fileprivate var modeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
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
        case .training: return UIImage(systemName: "chart.bar", withConfiguration: modeConfig)!
        case .rush: return UIImage(systemName: "alarm", withConfiguration: modeConfig)!
        case .piecesShown: return UIImage(systemName: "eye", withConfiguration: modeConfig)!
        case .piecesHidden: return UIImage(systemName: "eye.slash", withConfiguration: modeConfig)!
        }
    }
}

extension HomeController: DailyPuzzlesCollectionDelegate {
    
    func didSelectPuzzle(puzzle: Puzzle) {
        let controller = DailyPuzzleController(puzzles: [puzzle])
        present(controller, animated: true)
    }
}

extension HomeController: UserDBMSDelegate {
    func sendUser(user: User?) {
        guard let user = user else {return}
        self.currentUser = user
        configureUI()
        configureAutoLayout()
    }
    
    
}


class ModeButton: UIButton {
    
    var puzzleMode: Int!
    var wasSelected: Bool! {
        didSet {
            let color = wasSelected ? CommonUI().csBlue : CommonUI().blackColorLight
            layer.borderColor = color.cgColor
            title.textColor = color
            image.image = image.image?.withTintColor(color, renderingMode: .alwaysOriginal)
        }
    }
    
    init(puzzleMode: Int) {
        super.init(frame: .zero)
        self.puzzleMode = puzzleMode
        
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title: UILabel!
    var image: UIImageView!
    
    func configUI() {
        backgroundColor = .clear
        
        image = UIImageView()
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        title.font = UIFont(name: fontStringLight, size: 16)
        title.text = PuzzleMode(rawValue: puzzleMode)?.description
        title.textColor = .darkGray
        addSubview(title)
        
        image.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        //image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 0).isActive = true
        title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        tag = puzzleMode
        title.text = PuzzleMode(rawValue: puzzleMode)?.description
        image.image = PuzzleMode(rawValue: puzzleMode)?.image
        layer.cornerRadius = 10
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 2
    }
}


