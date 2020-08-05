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
    var visibilitySegment: UISegmentedControl!
    var puzzleModeSegment: UISegmentedControl!
    
    var puzzleAttempts: [PuzzleAttempt]!
    var puzzleBAttempts: [PuzzleAttempt]!
    var rush3Attempts: [Rush3Attempt]!
    var rush5Attempts: [Rush5Attempt]!

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
        
        
        createPuzzleAttemptData(piecesHidden: true)
        createPuzzleAttemptData(piecesHidden: false)
        fetchData()
        
        visibilitySegment = configSegment(items: ["Pieces Shown","Pieces Hidden"])
        puzzleModeSegment = configSegment(items: ["Rated Puzzles", "Rush 3min", "Rush 5min"])
        vstack = CommonUI().configureStackView(arrangedSubViews: [puzzleModeSegment])
        view.addSubview(vstack)
        
        // Linechart test
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
        let set1 = LineChartDataSet(entries: e1, label: "Pieces Shown").applyStandard(lineColor: CommonUI().purpleColor)
        let set2 = LineChartDataSet(entries: e2, label: "Pieces Hidden").applyStandard(lineColor: CommonUI().purpleColorLight)
        lineChart.data = LineChartData(dataSets: [set1, set2])
        view.addSubview(lineChart)

        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        vstack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        lineChart.topAnchor.constraint(equalTo: vstack.bottomAnchor).isActive = true
        lineChart.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lineChart.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lineChart.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 25)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.lightGray]
        navigationItem.title = "Your Progress"
    }
    
    func fetchData() {
        do {
            let request = PuzzleAttempt.fetchRequest() as NSFetchRequest<PuzzleAttempt>
            request.predicate = NSPredicate(format: "piecesHidden == FALSE")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            let requestB = PuzzleAttempt.fetchRequest() as NSFetchRequest<PuzzleAttempt>
            requestB.predicate = NSPredicate(format: "piecesHidden == TRUE")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            puzzleAttempts = try context.fetch(request)
            puzzleBAttempts = try context.fetch(requestB)
        } catch {}
    }
    
    func createPuzzleAttemptData(piecesHidden: Bool) {
        for i in 0...10 {
            let pA = PuzzleAttempt(context: context)
            pA.newRating = Int32(1000 + [100,150,-150,300,200].randomElement()!)
            pA.piecesHidden = piecesHidden
            pA.puzzleType = 0
            pA.puzzleIndex = Int32(Int(i))
            pA.ratingDelta = 0
            pA.timestamp = Date()
            pA.wasCorrect = true
            do { try context.save() }
            catch { print(error) }
        }
    }
    
    // MARK: - Selectors
    
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
        self.drawCirclesEnabled = false
        self.drawValuesEnabled  = false
        self.drawCircleHoleEnabled = false
        self.lineWidth = 3
        self.fillAlpha = 1
        self.highlightColor = .lightGray
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


