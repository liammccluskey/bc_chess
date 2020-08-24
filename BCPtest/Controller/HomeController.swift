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
    
    var boardController: ChessBoardController!
    
    // MARK: - Properties
    
    var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.isScrollEnabled = true
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var upgradeButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .small)
        b.setImage(UIImage(systemName: "star", withConfiguration: config)!
            .withRenderingMode(.alwaysOriginal).withTintColor(CommonUI().csBlue), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = CommonUI().csBlueOpaque
        b.setTitle(" Upgrade ", for: .normal)
        b.titleLabel?.font = UIFont(name: fontString, size: 16)
        b.setTitleColor(CommonUI().csBlue, for: .normal)
        b.layer.cornerRadius = 10
        b.clipsToBounds = true
        return b
    }()
    
    let header1Label: UILabel = {
        let label = UILabel()
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        label.text = " Puzzle games"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Black", size: 24)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let modeInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Game Mode"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 15)
        label.backgroundColor = .clear
        return label
    }()
    
    let visInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Piece Visiblity"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 15)
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
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 3
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .white
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    let header2Label: UILabel = {
        let label = UILabel()
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        label.text = " Daily Puzzles - \(dateString)"
        label.text = " Daily puzzles"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Black", size: 24)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
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
        dailyPuzzlesCollection.fetchAndReloadData()
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Config
    
    func configureUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(header2Label)
        
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
        visStack.translatesAutoresizingMaskIntoConstraints = true
        let modeStack = CommonUI().configureHStackView(arrangedSubViews: [trainingButton, rushButton])
        modeStack.distribution = .fillEqually
        modeStack.translatesAutoresizingMaskIntoConstraints = true
        let submodeStack = CommonUI().configureHStackView(arrangedSubViews: [submodeSegment])
        
        stack1 = configureStackView(arrangedSubViews: [
            visInfoLabel,
            visStack,
            modeInfoLabel,
            modeStack,
            submodeStack
        ])
        stack1.spacing = 10
        stack1.distribution = .fillProportionally
        
        containerView.addSubview(header1Label)
        containerView.addSubview(stack1)
        containerView.addSubview(playButton)
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        dailyPuzzlesCollection = DailyPuzzlesCollectionController(collectionViewLayout: flow)
        dailyPuzzlesCollection.collectionView.isPagingEnabled = true
        dailyPuzzlesCollection.delegate = self
        
        dailyPuzzlesCollection.puzzles = PFJ.puzzles!.m4
        dailyPuzzlesCollection.collectionView.reloadData()
        containerView.addSubview(dailyPuzzlesCollection.collectionView)
        containerView.addSubview(pageControl)
        
       // upgradeButton.addTarget(self, action: #selector(upgradeAction), for: .touchUpInside)
       // view.addSubview(upgradeButton)

        view.backgroundColor = CommonUI().blackColor
    }
    
    func configureAutoLayout() {
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: view.frame.height*1.1).isActive = true
        
        header2Label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        header2Label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        
        dailyPuzzlesCollection.collectionView.topAnchor.constraint(equalTo: header2Label.bottomAnchor, constant: 10).isActive = true
        dailyPuzzlesCollection.collectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        dailyPuzzlesCollection.collectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        dailyPuzzlesCollection.collectionView.heightAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        pageControl.topAnchor.constraint(equalTo: dailyPuzzlesCollection.collectionView.bottomAnchor, constant: 5).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        header1Label.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 0).isActive = true
        header1Label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        
        stack1.topAnchor.constraint(equalTo: header1Label.bottomAnchor, constant: 5).isActive = true
        stack1.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        stack1.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        
        playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        playButton.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 60).isActive = true
  
    }
    
    func configureStackView(arrangedSubViews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.alignment = .fill
        //stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func configurePuzzleTypeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle("Play".uppercased(), for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 18)
        button.backgroundColor = CommonUI().greenCorrect
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    @objc func upgradeAction() {
        let controller = UpgradeController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Test
    
    func configureSegment(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        let font = UIFont(name: fontString, size: 17)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().softWhite], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.darkGray], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .black
        sc.selectedSegmentTintColor = .black
        return sc
    }
}

extension HomeController: DailyPuzzlesCollectionDelegate {
    func didSelectPuzzle(puzzle: Puzzle, puzzleReference: PuzzleReference, puzzleNumber: Int, piecesHidden: Bool, publicAttemptsInfo: DailyPuzzlesInfo?) {
        let controller = DailyPuzzleController(pRef: puzzleReference, puzzle: puzzle, piecesHidden: piecesHidden, puzzleNumber: puzzleNumber, publicAttemptsInfo: publicAttemptsInfo)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    func didMoveToPage(pageNumber: Int) {
        pageControl.currentPage = pageNumber
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

fileprivate var modeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin, scale: .medium)
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


class ModeButton: UIButton {
    
    var puzzleMode: Int!
    var wasSelected: Bool! {
        didSet {
            let tintColor = wasSelected ? CommonUI().softWhite : .darkGray
            let borderColor = wasSelected ? UIColor.black : CommonUI().blackColor
            let bgColor = wasSelected ? .black : CommonUI().blackColorLight
            layer.borderColor = borderColor.cgColor
            title.textColor = tintColor
            image.image = image.image?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
            backgroundColor = bgColor
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
        title.font = UIFont(name: fontString, size: 16)
        title.text = PuzzleMode(rawValue: puzzleMode)?.description
        title.textColor = .darkGray
        addSubview(title)
        
        image.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 0).isActive = true
        title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        tag = puzzleMode
        title.text = PuzzleMode(rawValue: puzzleMode)?.description
        image.image = PuzzleMode(rawValue: puzzleMode)?.image
        layer.cornerRadius = 10
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 6
    }
}



/*
class HomeController: UIViewController {
    
    var currentUser: User!
    
    var boardController: ChessBoardController!
    
    // MARK: - Properties
    
    var upgradeButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .small)
        b.setImage(UIImage(systemName: "star", withConfiguration: config)!
            .withRenderingMode(.alwaysOriginal).withTintColor(CommonUI().csBlue), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = CommonUI().csBlueOpaque
        b.setTitle(" Upgrade ", for: .normal)
        b.titleLabel?.font = UIFont(name: fontString, size: 16)
        b.setTitleColor(CommonUI().csBlue, for: .normal)
        b.layer.cornerRadius = 10
        b.clipsToBounds = true
        return b
    }()
    
    let header1Label: UILabel = {
        let label = UILabel()
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        label.text = " Puzzle games"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Black", size: 24)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let modeInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Game Mode"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 15)
        label.backgroundColor = .clear
        return label
    }()
    
    let visInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Piece Visiblity"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 15)
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
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 3
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .white
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    let header2Label: UILabel = {
        let label = UILabel()
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        label.text = " Daily Puzzles - \(dateString)"
        label.text = " Daily puzzles"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Black", size: 24)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
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
        dailyPuzzlesCollection.fetchAndReloadData()
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Config
    
    func configureUI() {
        view.addSubview(header2Label)
        
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
        visStack.translatesAutoresizingMaskIntoConstraints = true
        let modeStack = CommonUI().configureHStackView(arrangedSubViews: [trainingButton, rushButton])
        modeStack.distribution = .fillEqually
        modeStack.translatesAutoresizingMaskIntoConstraints = true
        let submodeStack = CommonUI().configureHStackView(arrangedSubViews: [submodeSegment])
        
        stack1 = configureStackView(arrangedSubViews: [
            visInfoLabel,
            visStack,
            modeInfoLabel,
            modeStack,
            submodeStack
        ])
        stack1.spacing = 10
        stack1.distribution = .fillProportionally
        
        view.addSubview(header1Label)
        view.addSubview(stack1)
        view.addSubview(playButton)
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        dailyPuzzlesCollection = DailyPuzzlesCollectionController(collectionViewLayout: flow)
        dailyPuzzlesCollection.collectionView.isPagingEnabled = true
        dailyPuzzlesCollection.delegate = self
        
        dailyPuzzlesCollection.puzzles = PFJ.puzzles!.m4
        dailyPuzzlesCollection.collectionView.reloadData()
        view.addSubview(dailyPuzzlesCollection.collectionView)
        view.addSubview(pageControl)
        
       // upgradeButton.addTarget(self, action: #selector(upgradeAction), for: .touchUpInside)
       // view.addSubview(upgradeButton)

        view.backgroundColor = CommonUI().blackColor
    }
    
    func configureAutoLayout() {
        header2Label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        header2Label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        
        /*
        upgradeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        upgradeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        upgradeButton.widthAnchor.constraint(equalToConstant: 130).isActive = true
        upgradeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        */
        dailyPuzzlesCollection.collectionView.topAnchor.constraint(equalTo: header2Label.bottomAnchor, constant: 10).isActive = true
        dailyPuzzlesCollection.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        dailyPuzzlesCollection.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        dailyPuzzlesCollection.collectionView.heightAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        pageControl.topAnchor.constraint(equalTo: dailyPuzzlesCollection.collectionView.bottomAnchor, constant: 5).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        header1Label.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 0).isActive = true
        header1Label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        //playButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        playButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -80).isActive = true
        playButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80).isActive = true
        //playButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        //playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stack1.topAnchor.constraint(equalTo: header1Label.bottomAnchor, constant: 5).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        //stack1.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -20).isActive = true
  
    }
    
    func configureStackView(arrangedSubViews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.alignment = .fill
        //stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func configurePuzzleTypeButton(title: String, tag: Int) -> UIButton {
        /*
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 24)
        button.backgroundColor = CommonUI().csBlue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        */
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle("Play".uppercased(), for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 18)
        button.backgroundColor = CommonUI().greenCorrect
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    @objc func upgradeAction() {
        let controller = UpgradeController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Test
    
    func configureSegment(items: [String]) -> UISegmentedControl {
        /*
        let sc = UISegmentedControl(items: items)
        let font = UIFont(name: fontString, size: 17)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.black], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().csBlue], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .black
        sc.selectedSegmentTintColor = CommonUI().csBlue
        return sc
        */
        let sc = UISegmentedControl(items: items)
        let font = UIFont(name: fontString, size: 17)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().softWhite], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.darkGray], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .black
        sc.selectedSegmentTintColor = .black
        return sc
    }
}

extension HomeController: DailyPuzzlesCollectionDelegate {
    func didSelectPuzzle(puzzle: Puzzle, puzzleReference: PuzzleReference, puzzleNumber: Int, piecesHidden: Bool, publicAttemptsInfo: DailyPuzzlesInfo?) {
        let controller = DailyPuzzleController(pRef: puzzleReference, puzzle: puzzle, piecesHidden: piecesHidden, puzzleNumber: puzzleNumber, publicAttemptsInfo: publicAttemptsInfo)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    func didMoveToPage(pageNumber: Int) {
        pageControl.currentPage = pageNumber
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

fileprivate var modeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .medium)
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


class ModeButton: UIButton {
    
    var puzzleMode: Int!
    var wasSelected: Bool! {
        didSet {
            /*
            let tintColor = wasSelected ? CommonUI().csBlue : CommonUI().blackColorLight
            let borderColor = wasSelected ? UIColor.black : CommonUI().blackColor
            let bgColor = wasSelected ? .black : UIColor().fromRGB("15,15,20")
            */
            let tintColor = wasSelected ? CommonUI().softWhite : CommonUI().blackColorLight
            let borderColor = wasSelected ? UIColor.black : CommonUI().blackColor
            let bgColor = wasSelected ? .black : UIColor().fromRGB("15,15,20")
            layer.borderColor = borderColor.cgColor
            title.textColor = tintColor
            image.image = image.image?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
            backgroundColor = bgColor
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
        title.font = UIFont(name: fontString, size: 16)
        title.text = PuzzleMode(rawValue: puzzleMode)?.description
        title.textColor = .darkGray
        addSubview(title)
        
        image.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 0).isActive = true
        title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        tag = puzzleMode
        title.text = PuzzleMode(rawValue: puzzleMode)?.description
        image.image = PuzzleMode(rawValue: puzzleMode)?.image
        layer.cornerRadius = 10
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 6
    }
}
*/
