//
//  DailyPuzzlesCollectionController.swift
//  BCPtest
//
//  Created by Guest on 8/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import Charts

class DailyPuzzlesCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    let cellID = "cell"
    var puzzles: [Puzzle]?
    var pRefs: [PuzzleReference]?
    var piecesHidden: [Bool]!
    var delegate: DailyPuzzlesCollectionDelegate?
    var dailyPuzzlesInfo: DailyPuzzlesInfo?
    var publicDB: PublicDBMS!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        setPuzzles()
        
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        title = " Daily Puzzles - \(dateString)".uppercased()
        
        collectionView.register(PuzzleCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.backgroundColor = .clear
        
        publicDB = PublicDBMS()
        publicDB.delegate = self
        publicDB.fetchDailyPuzzlesInfo()
    }
    
    func setPuzzles() {
        piecesHidden = [false, false, true]
        let pRef1 = PFJ.getDailyPuzzleReferenceInRange(lowerBound: 1000, upperBound: 2000, isBlindfold: false)!
        let pRef2 = PFJ.getDailyPuzzleReferenceInRange(lowerBound: 2000, upperBound: 2500, isBlindfold: false)!
        let pRef3 = PFJ.getDailyPuzzleReferenceInRange(lowerBound: 1000, upperBound: 2000, isBlindfold: true)!
        print(pRef1)
        pRefs = [pRef1, pRef2, pRef3]
        puzzles = [PFJ.getPuzzle(fromPuzzleReference: pRef1)!, PFJ.getPuzzle(fromPuzzleReference: pRef2)!, PFJ.getPuzzle(fromPuzzleReference: pRef3)!]
    }
    
    // MARK: - Config
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: width*0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PuzzleCell
        guard let puzzles = puzzles else {return cell}
        let puzzle = puzzles[indexPath.row]
        let isBlindfold = piecesHidden[indexPath.row]
        cell.configUI(forPuzzle: puzzle, withAttemptInfo: dailyPuzzlesInfo, puzzleNumber: indexPath.row + 1, isBlindfold: isBlindfold)
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let puzzles = puzzles, let pRefs = pRefs else {return}
        let puzzle = puzzles[indexPath.row]
        let pRef = pRefs[indexPath.row]
        let isBlindfold = piecesHidden[indexPath.row]
        let pNum = indexPath.row + 1
        delegate?.didSelectPuzzle(puzzle: puzzle, puzzleReference: pRef, puzzleNumber: pNum, piecesHidden: isBlindfold, publicAttemptsInfo: dailyPuzzlesInfo)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.didMoveToPage(pageNumber: indexPath.row)
    }
    
    func fetchAndReloadData() {
        publicDB.fetchDailyPuzzlesInfo()
    }
    
}

extension DailyPuzzlesCollectionController: PublicDBMSDelegate {
    func sendRankedUsers(rankedUsers: RankedUsers?) {
    }
    
    func sendDailyPuzzlesInfo(info: DailyPuzzlesInfo?) {
        guard let info = info else {return}
        self.dailyPuzzlesInfo = info
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
        }
    }
    
    
}

class PuzzleCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var numTries: Int!
    var numCorrectTries: Int!
    var numIncorrectTries: Int!
    var chartController: DailyPuzzleChartController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func configUI(forPuzzle puzzle: Puzzle, withAttemptInfo info: DailyPuzzlesInfo?, puzzleNumber: Int, isBlindfold: Bool) {
        backgroundColor = CommonUI().blackColorLight
        subviews.forEach{$0.removeFromSuperview()}
        if let info = info {
            switch puzzleNumber {
            case 1:
                numTries = info.P1_ATTEMPTS
                numCorrectTries = info.P1_CORRECT
                numIncorrectTries = info.P1_INCORRECT ; break
            case 2:
                numTries = info.P2_ATTEMPTS
                numCorrectTries = info.P2_CORRECT
                numIncorrectTries = info.P2_INCORRECT ; break
            case 3:
                numTries = info.P3_ATTEMPTS
                numCorrectTries = info.P3_CORRECT
                numIncorrectTries = info.P3_INCORRECT ; break
            default: break
            }
        } else {
            numTries = 0
            numCorrectTries = 0
            numIncorrectTries = 0
        }
        chartController = DailyPuzzleChartController(numTries: numTries, numCorrectTries: numCorrectTries, numIncorrectTries: numIncorrectTries)
        
        let bc1 = ChessBoardImageController(sideLength: bounds.width/2,fen: puzzle.fen, shouldHidePieces: isBlindfold)
        bc1.view.backgroundColor = .clear
        bc1.view.layer.cornerRadius = 5
        bc1.view.clipsToBounds = true
        
        let hstack = CommonUI().configureHStackView(arrangedSubViews: [bc1.view, chartController.view])
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.distribution = .fillEqually
        hstack.spacing = 0
        addSubview(hstack)
        
        hstack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        hstack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        hstack.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
}

class DailyPuzzleChartController: UIViewController, ChartViewDelegate {
    
    // MARK: - Properties
    
    var numTries: Int!
    var percentCorrect: Double!
    var percentIncorrect: Double!
    lazy var chartView: PieChartView! = {
        let chart = PieChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.backgroundColor = .clear
        return chart
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        configAutoLayout()
        
        view.backgroundColor = .clear
    }
    
    init(numTries: Int, numCorrectTries: Int, numIncorrectTries: Int) {
        super.init(nibName: nil, bundle: nil)
        self.numTries = numTries
        self.percentCorrect = numTries == 0 ? 0 : (Double(numCorrectTries)/Double(numTries)*100).rounded(.toNearestOrAwayFromZero)
        self.percentIncorrect = numTries == 0 ? 0 : 100 - self.percentCorrect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Config
    
    func configUI() {
        
        configChart()
        view.addSubview(chartView)
    }
    
    func configAutoLayout() {
        chartView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        chartView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        chartView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        chartView.heightAnchor.constraint(equalTo: chartView.widthAnchor).isActive = true
        
    }
    
    func configChart() {
        chartView.drawHoleEnabled = true
        chartView.isUserInteractionEnabled = false
        chartView.rotationAngle = 0
        chartView.holeColor = .clear
        chartView.drawEntryLabelsEnabled = false
        chartView.legend.enabled = true
        
        let l = chartView.legend
        l.form = .circle
        l.font = UIFont(name: fontStringLight, size: 14)!
        l.textColor = .white
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .vertical
        
        var entries = [PieChartDataEntry]()
        entries.append(PieChartDataEntry(value: percentCorrect, label: "Correct:    \(percentCorrect!) %"))
        entries.append(PieChartDataEntry(value: percentIncorrect, label: "Incorrect:  \(percentIncorrect!) %"))
        
        let dataSet = PieChartDataSet(entries: entries, label: "  Attempts:   \(numTries!)")
        dataSet.drawValuesEnabled = false
        dataSet.colors = [CommonUI().greenCorrect, CommonUI().redIncorrect]
                
        chartView.data = PieChartData(dataSet: dataSet)
    }
}
