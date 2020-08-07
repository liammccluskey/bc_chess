//
//  ProgressController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth
import Charts
import CoreData

class ProgressController: UIViewController {
    
    // MARK: - Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var vstack: UIStackView!
    var puzzleModeSegment: UISegmentedControl!
    var visibilitySegment: UISegmentedControl!
    var scoreView: UIView!
    var scoreBView: UIView!
    var chartTitleLabel: UILabel!
    
    var puzzledUser: PuzzledUser!
    var puzzleAttempts: [PuzzleAttempt]!
    var puzzleBAttempts: [PuzzleAttempt]!
    var rush3Attempts: [Rush3Attempt]!
    var rush5Attempts: [Rush5Attempt]!
    
    var progressTable: ProgressTableController!
    
    var lineChart: LineChartView = {
        let chart = LineChartView()
        //chart.translatesAutoresizingMaskIntoConstraints = false
        chart.backgroundColor = .clear
        return chart.applyStandard()
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
        configAutoLayout()
    }
    
    // MARK: - Config
    
    func configUI() {
        configNavigationBar()
        
        clearPuzzleData()
        fetchData()
        setChartData()
        
        puzzleModeSegment = configSegment(items: ["Rated Puzzles", "Rush 3min", "Rush 5min"])
        scoreView = UIView().configScoreLabel(scoreTitle:  "RATING (Regular)  ", scoreValue: "1400")
        scoreBView = UIView().configScoreLabel(scoreTitle: "RATING (Blindfold)", scoreValue: "1200")
        chartTitleLabel = UILabel().configHeaderLabel(title: "Puzzle Rating vs. Time")
        vstack = CommonUI().configureStackView(arrangedSubViews: [
            puzzleModeSegment,
            lineChart,
            CommonUI().configureHStackView(arrangedSubViews: [scoreView, scoreBView]),
            UILabel().configHeaderLabel(title: "Recent Rated Puzzles")
        ])
        vstack.spacing = 5
        vstack.setCustomSpacing(20, after: scoreView)
        view.addSubview(vstack)
        
        progressTable = ProgressTableController()
        progressTable.puzzleAttempts = puzzleAttempts
        progressTable.tableView.reloadData()
        view.addSubview(progressTable.tableView)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        vstack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        
        lineChart.heightAnchor.constraint(equalToConstant: view.frame.height/4).isActive = true
        //lineChart.widthAnchor.constraint(equalToConstant: view.frame.height/4).isActive = true
        
        progressTable.tableView.topAnchor.constraint(equalTo: vstack.bottomAnchor, constant: 3).isActive = true
        progressTable.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        progressTable.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        progressTable.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 25)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.lightGray]
        navigationItem.title = "Your Progress"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
    }
    
    func fetchData() {
        do {
            let request = NSFetchRequest<PuzzleAttempt>(entityName: "PuzzleAttempt")
            request.predicate = NSPredicate(format: "piecesHidden == FALSE")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            let requestB = NSFetchRequest<PuzzleAttempt>(entityName: "PuzzleAttempt")
            requestB.predicate = NSPredicate(format: "piecesHidden == TRUE")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            let userRequest = NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")
            puzzleAttempts = try context.fetch(request)
            puzzleBAttempts = try context.fetch(requestB)
            let puzzledUsers = try context.fetch(userRequest)
            if puzzledUsers.count == 1 { puzzledUser = puzzledUsers[0]}
            else { print(" error fetching user from coredata with count: \(puzzledUsers.count)")}
        } catch {}
    }
    
    func setChartData() {
        var e1 = [ChartDataEntry]()
        var e2 = [ChartDataEntry]()
        e1.append(ChartDataEntry(x: Double(puzzledUser.registerTimestamp!.timeIntervalSince1970),y:1200.0))
        e2.append(ChartDataEntry(x: Double(puzzledUser.registerTimestamp!.timeIntervalSince1970),y:1200.0))
        for i in 0..<puzzleAttempts.count {
            let pA = puzzleAttempts[i]
            e1.append(ChartDataEntry(x: Double(pA.timestamp!.timeIntervalSince1970), y: Double(pA.newRating)))
        }
        for i in 0..<puzzleBAttempts.count {
            let pA = puzzleBAttempts[i]
            e2.append(ChartDataEntry(x: Double(pA.timestamp!.timeIntervalSince1970), y: Double(pA.newRating)))
        }
        let date = Date()
        e1.append(ChartDataEntry(x: Double(date.timeIntervalSince1970),y:1200.0))
        e2.append(ChartDataEntry(x: Double(date.timeIntervalSince1970),y:1200.0))
        let set1 = LineChartDataSet(entries: e1, label: "Pieces Shown").applyStandard(lineColor: CommonUI().greenColor)
        let set2 = LineChartDataSet(entries: e2, label: "Pieces Hidden").applyStandard(lineColor: CommonUI().redColor)
        lineChart.data = LineChartData(dataSets: [set1, set2])
    }
    
    func addChartDataItem() {
        // add new items
        let date = Date()
        let pA = PuzzleAttempt(context: context)
        pA.newRating = Int32(1000 + [10,5,-15,-20,20].randomElement()!)
        pA.piecesHidden = false
        pA.puzzleType = 0
        pA.puzzleIndex = Int32(Int(10))
        pA.ratingDelta = 0
        pA.timestamp = date
        pA.wasCorrect = [true, false].randomElement()!
        let pB = PuzzleAttempt(context: context)
        pB.newRating = Int32(1000 + [10,5,-15,-20,20].randomElement()! - 400)
        pB.piecesHidden = true
        pB.puzzleType = 0
        pB.puzzleIndex = Int32(Int(10))
        pB.ratingDelta = 0
        pB.timestamp = date
        pB.wasCorrect = [true, false].randomElement()!
        do { try context.save() }
        catch { print(error) }
    }
    
    func clearPuzzleData() {
        if let result = try? context.fetch(NSFetchRequest<PuzzleAttempt>(entityName: "PuzzleAttempt")) {
            for pa in result {
                context.delete(pa)
            }
        }
        if let result = try? context.fetch(NSFetchRequest<Rush3Attempt>(entityName: "Rush3Attempt")) {
            for pa in result {
                context.delete(pa)
            }
        }
        if let result = try? context.fetch(NSFetchRequest<Rush5Attempt>(entityName: "Rush5Attempt")) {
            for pa in result {
                context.delete(pa)
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc func refreshAction() {
        addChartDataItem()
        fetchData()
        progressTable.puzzleAttempts = puzzleAttempts
        DispatchQueue.main.async {
            self.setChartData()
            self.progressTable.tableView.reloadData()
        }
     
    }
    
    @objc func segmentAction() {
        
    }
    
    // MARK: - Config Helper
    
    func configSegment(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        sc.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        let font = UIFont(name: fontString, size: 16)
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

extension LineChartDataSet {
    func applyStandard(lineColor: NSUIColor) -> LineChartDataSet{
        self.colors = [lineColor]
        self.axisDependency = .left
        self.drawCirclesEnabled = true
        self.drawValuesEnabled  = false
        self.drawCircleHoleEnabled = false
        self.circleRadius = 3
        self.circleColors = [lineColor]
        self.lineWidth = 3
        self.fillAlpha = 1
        self.highlightColor = .white
        return self
    }
}

extension LineChartView {
    func applyStandard() -> LineChartView {
        self.xAxis.labelTextColor = .white
        self.leftAxis.labelTextColor = .white
        self.rightAxis.enabled = false
        self.xAxis.labelPosition = .bottom
        self.xAxis.valueFormatter = DateValueFormatter()
        self.xAxis.setLabelCount(4, force: true)
        self.xAxis.avoidFirstLastClippingEnabled = true
        self.legend.enabled = true
        self.drawGridBackgroundEnabled = false
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        let l = self.legend
        l.form = .circle
        l.font = UIFont(name: fontStringLight, size: 16)!
        l.textColor = .white
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        return self
    }
}

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        //dateFormatter.dateFormat = "dd MMM HH:mm"
        dateFormatter.dateStyle = .short
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}


