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
    var delegate: DailyPuzzlesCollectionDelegate?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        title = " Daily Puzzles - \(dateString)".uppercased()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.addSubview(refreshControl)
        //collectionView.alwaysBounceVertical = true
        
        collectionView.register(PuzzleCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.backgroundColor = .clear
    }
    
    // MARK: - Config
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: view.frame.width*0.35, height: view.frame.width*0.35)
        let width = collectionView.bounds.width
        return CGSize(width: width, height: width*0.5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PuzzleCell
        guard let puzzles = puzzles else {return cell}
        let puzzle = puzzles[indexPath.section*2 + indexPath.row]
        cell.configUI(forPuzzle: puzzle)
        //cell.difficultyLabel.text = "Difficulty:  " + String(puzzle.solution_moves.count*400 + Int.random(in: 3...200))
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let puzzles = puzzles else {return}
        delegate?.didSelectPuzzle(puzzle: puzzles[indexPath.section*2 + indexPath.row])
    }
    
    @objc func refreshAction() {
        collectionView.refreshControl?.endRefreshing()
    }
    
}

class PuzzleCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var chartController: DailyPuzzleChartController!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI(forPuzzle puzzle: Puzzle) {
        let bc1 = ChessBoardImageController(position: puzzle.position)
        bc1.view.backgroundColor = .clear
        bc1.view.layer.cornerRadius = 5
        bc1.view.clipsToBounds = true
        
        chartController = DailyPuzzleChartController()
        
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
       // chartView.drawCenterTextEnabled = true
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
        entries.append(PieChartDataEntry(value: 70.0, label: "Correct: 70%"))
        entries.append(PieChartDataEntry(value: 30.0, label: "Incorrect: 30%"))
        
        let dataSet = PieChartDataSet(entries: entries, label: "Attempts: 49900")
        dataSet.drawValuesEnabled = false
        dataSet.colors = [CommonUI().greenCorrect, CommonUI().redIncorrect]
                
        chartView.data = PieChartData(dataSet: dataSet)
        
    }
    
    
}
