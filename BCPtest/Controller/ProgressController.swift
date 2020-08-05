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
    
    var puzzleAttempts: [PuzzleAttempt]!
    var puzzleBAttempts: [PuzzleAttempt]!
    var rush3Attempts: [Rush3Attempt]!
    var rush5Attempts: [Rush5Attempt]!
    
    var progressTable: ProgressTableController!
    

    var lineChart: LineChartView = {
        let chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
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
        
        //visibilitySegment = configSegment(items: ["Pieces Shown","Pieces Hidden"])
        puzzleModeSegment = configSegment(items: ["Rated Puzzles", "Rush 3min", "Rush 5min"])
        scoreView = UIView().configScoreLabel(scoreTitle:  "RATING (Regular)  ", scoreValue: "1400")
        scoreBView = UIView().configScoreLabel(scoreTitle: "RATING (Blindfold)", scoreValue: "1200")
        chartTitleLabel = UILabel().configHeaderLabel(title: "Puzzle Rating vs. Time")
        vstack = CommonUI().configureStackView(arrangedSubViews: [
            puzzleModeSegment,
            CommonUI().configureHStackView(arrangedSubViews: [scoreView, scoreBView]),
            chartTitleLabel
        ])
        vstack.spacing = 15
        vstack.setCustomSpacing(40, after: scoreView)
        view.addSubview(vstack)
        
        clearPuzzleData()
        addChartDataItem()
        fetchData()
        setChartData()
        view.addSubview(lineChart)
        
        progressTable = ProgressTableController()
        progressTable.attempts = puzzleAttempts
        progressTable.tableView.reloadData()
        view.addSubview(progressTable.tableView)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        vstack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        lineChart.topAnchor.constraint(equalTo: vstack.bottomAnchor, constant: -5).isActive = true
        lineChart.heightAnchor.constraint(equalToConstant: view.frame.height/4).isActive = true
        lineChart.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        lineChart.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        
        progressTable.tableView.topAnchor.constraint(equalTo: lineChart.bottomAnchor, constant: 20).isActive = true
        progressTable.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        progressTable.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
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
            puzzleAttempts = try context.fetch(request)
            puzzleBAttempts = try context.fetch(requestB)
        } catch {}
    }
    
    func setChartData() {
        var e1 = [ChartDataEntry]()
        var e2 = [ChartDataEntry]()
        for i in 0..<puzzleAttempts.count {
            let pA = puzzleAttempts[i]
            e1.append(ChartDataEntry(x: Double(pA.timestamp!.timeIntervalSince1970), y: Double(pA.newRating)))
        }
        for i in 0..<puzzleBAttempts.count {
            let pA = puzzleBAttempts[i]
            e2.append(ChartDataEntry(x: Double(pA.timestamp!.timeIntervalSince1970), y: Double(pA.newRating)))
        }
        let set1 = LineChartDataSet(entries: e1, label: "Pieces Shown").applyStandard(lineColor: CommonUI().blueColorDark)
        let set2 = LineChartDataSet(entries: e2, label: "Pieces Hidden").applyStandard(lineColor: CommonUI().blueColorLight)
        lineChart.data = LineChartData(dataSets: [set1, set2])
    }
    
    func addChartDataItem() {
        // add new items
        let date = Date()
        let pA = PuzzleAttempt(context: context)
        pA.newRating = Int32(1000 + [100,150,-150,300,200].randomElement()!)
        pA.piecesHidden = false
        pA.puzzleType = 0
        pA.puzzleIndex = Int32(Int(10))
        pA.ratingDelta = 0
        pA.timestamp = date
        pA.wasCorrect = [true, false].randomElement()!
        let pB = PuzzleAttempt(context: context)
        pB.newRating = Int32(1000 + [100,150,-150,300,200].randomElement()! - 600)
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
        setChartData()
        
        progressTable.attempts = puzzleAttempts
        DispatchQueue.main.async {
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
        //self.xAxis.granularity = 1
        self.xAxis.setLabelCount(3, force: true)
        self.xAxis.avoidFirstLastClippingEnabled = true
        self.legend.enabled = true
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
        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

class ProgressTableController: UITableViewController {
    
    // MARK: - Properties
    
    var attempts: [PuzzleAttempt] = []
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.layer.borderColor = CommonUI().blackColorLight.cgColor
        tableView.layer.borderWidth = 4
    }
    
    // MARK: - Config
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attempts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attempt = attempts[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.imageView?.image = attempt.wasCorrect ? #imageLiteral(resourceName: "check").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "redxwhitefill").withRenderingMode(.alwaysOriginal)
        cell.textLabel?.text = DateFormatter.localizedString(from: attempt.timestamp!, dateStyle: .long, timeStyle: .none)
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: fontStringLight, size: 16)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UILabel().configHeaderLabel(title: "Recent Rated Puzzles")
    }

}


