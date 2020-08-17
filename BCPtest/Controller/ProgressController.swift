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
    var scoreView: ScoreLabel!
    var scoreBView: ScoreLabel!
    
    var puzzledUser: PuzzledUser!
    
    var puzzleAttempts: [PuzzleAttempt]!
    var puzzleRegularAttempts: [PuzzleAttempt]!
    var puzzleBlindfoldAttempts: [PuzzleAttempt]!
    
    var rush3Attempts: [Rush3Attempt]!
    var rush3RegularAttempts: [Rush3Attempt]!
    var rush3BlindfoldAttempts: [Rush3Attempt]!

    var rush5Attempts: [Rush5Attempt]!
    var rush5RegularAttempts: [Rush5Attempt]!
    var rush5BlindfoldAttempts: [Rush5Attempt]!
    
    var tableTitleLabel: UILabel!
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
        
        puzzledUser = UserDBMS().getPuzzledUser()

        configUI()
        configAutoLayout()
    }
    
    // MARK: - Config
    
    func configUI() {
        configNavigationBar()
        
        fetchData()
        setPuzzleAttemptChartData()
        
        puzzleModeSegment = configSegment(items: ["Rated Puzzles", "Rush 3min", "Rush 5min"])
        scoreView = ScoreLabel(puzzledUser: puzzledUser, attemptType: 0, isBlindfold: false)
        scoreBView = ScoreLabel(puzzledUser: puzzledUser, attemptType: 0, isBlindfold: true)
        tableTitleLabel = UILabel().configHeaderLabel(title: "Recent Rated Puzzles")
        let hstack = CommonUI().configureHStackView(arrangedSubViews: [scoreView, scoreBView])
        hstack.distribution = .fillEqually
        vstack = CommonUI().configureStackView(arrangedSubViews: [
            puzzleModeSegment,
            lineChart,
            hstack,
            tableTitleLabel
        ])
        vstack.spacing = 5
        vstack.setCustomSpacing(20, after: hstack)
        view.addSubview(vstack)
        
        progressTable = ProgressTableController()
        progressTable.delegate = self
        progressTable.puzzleAttempts = puzzleAttempts
        progressTable.attemptType = 0
        progressTable.tableView.reloadData()
        view.addSubview(progressTable.tableView)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        vstack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        
        lineChart.heightAnchor.constraint(equalToConstant: view.frame.height/3.9).isActive = true
        
        progressTable.tableView.topAnchor.constraint(equalTo: vstack.bottomAnchor, constant: 3).isActive = true
        progressTable.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        progressTable.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        progressTable.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 23)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.lightGray]
        navigationItem.title = "Your Progress"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
    }
    
    func fetchData() {
        do {
            let sortAscendingDate = NSSortDescriptor(key: "timestamp", ascending: true)
            guard let thisUser = Auth.auth().currentUser else {return}
            let predicate = NSPredicate(format: "puzzledUser.uid == %@", thisUser.uid)
            
            let requestPA = NSFetchRequest<PuzzleAttempt>(entityName: "PuzzleAttempt")
            requestPA.sortDescriptors = [sortAscendingDate]
            requestPA.predicate = predicate
            puzzleAttempts = try context.fetch(requestPA)
            puzzleRegularAttempts = puzzleAttempts.filter{$0.piecesHidden == false}
            puzzleBlindfoldAttempts = puzzleAttempts.filter{$0.piecesHidden == true}
            
            let requestR3A = NSFetchRequest<Rush3Attempt>(entityName: "Rush3Attempt")
            requestR3A.sortDescriptors = [sortAscendingDate]
            requestR3A.predicate = predicate
            rush3Attempts = try context.fetch(requestR3A)
            rush3RegularAttempts = rush3Attempts.filter{$0.piecesHidden == false}
            rush3BlindfoldAttempts = rush3Attempts.filter{$0.piecesHidden == true}
            
            let requestR5A = NSFetchRequest<Rush5Attempt>(entityName: "Rush5Attempt")
            requestR5A.sortDescriptors = [sortAscendingDate]
            requestR5A.predicate = predicate
            rush5Attempts = try context.fetch(requestR5A)
            rush5RegularAttempts = rush5Attempts.filter{$0.piecesHidden == false}
            rush5BlindfoldAttempts = rush5Attempts.filter{$0.piecesHidden == true}
            
            puzzledUser = UserDBMS().getPuzzledUser()!
        } catch {}
    }
    
    func setPuzzleAttemptChartData() {
        var e1 = [ChartDataEntry]()
        var e2 = [ChartDataEntry]()
        e1.append(ChartDataEntry(x: Double(puzzledUser.registerTimestamp!.timeIntervalSince1970),y:1000))
        e2.append(ChartDataEntry(x: Double(puzzledUser.registerTimestamp!.timeIntervalSince1970),y:800))
        for i in 0..<puzzleRegularAttempts.count {
            let pA = puzzleRegularAttempts[i]
            e1.append(ChartDataEntry(x: Double(pA.timestamp!.timeIntervalSince1970), y: Double(pA.newRating)))
        }
        for i in 0..<puzzleBlindfoldAttempts.count {
            let pA = puzzleBlindfoldAttempts[i]
            e2.append(ChartDataEntry(x: Double(pA.timestamp!.timeIntervalSince1970), y: Double(pA.newRating)))
        }
        let date = Date()
        e1.append(ChartDataEntry(x: Double(date.timeIntervalSince1970),y:Double(puzzledUser.puzzle_Elo)))
        e2.append(ChartDataEntry(x: Double(date.timeIntervalSince1970),y: Double(puzzledUser.puzzleB_Elo)))
        let set1 = LineChartDataSet(entries: e1, label: "Pieces Shown").applyStandard(lineColor: CommonUI().greenColor)
        let set2 = LineChartDataSet(entries: e2, label: "Pieces Hidden").applyStandard(lineColor: CommonUI().blueColorDark)
        lineChart.data = LineChartData(dataSets: [set1, set2])
        
        lineChart.leftAxis.axisMinimum = (lineChart.data?.yMin ?? 800) - 200
        lineChart.leftAxis.axisMaximum = (lineChart.data?.yMax ?? 1200) + 200
    }
    
    func setRush3AttemptChartData() {
        var e1 = [ChartDataEntry]()
        var e2 = [ChartDataEntry]()
        e1.append(ChartDataEntry(x: Double(puzzledUser.registerTimestamp!.timeIntervalSince1970),y:0.0))
        e2.append(ChartDataEntry(x: Double(puzzledUser.registerTimestamp!.timeIntervalSince1970),y:0.0))
        for i in 0..<rush3RegularAttempts.count {
            let rA = rush3RegularAttempts[i]
            e1.append(ChartDataEntry(x: Double(rA.timestamp!.timeIntervalSince1970), y: Double(rA.numCorrect)))
        }
        for i in 0..<rush3BlindfoldAttempts.count {
            let rA = rush3BlindfoldAttempts[i]
            e2.append(ChartDataEntry(x: Double(rA.timestamp!.timeIntervalSince1970), y: Double(rA.numCorrect)))
        }
        let date = Date()
        //e1.append(ChartDataEntry(x: Double(date.timeIntervalSince1970),y:Double(puzzledUser.rush3_HS)))
        //e2.append(ChartDataEntry(x: Double(date.timeIntervalSince1970),y: Double(puzzledUser.rush3B_HS)))
        let set1 = LineChartDataSet(entries: e1, label: "Pieces Shown").applyStandard(lineColor: CommonUI().greenColor)
        let set2 = LineChartDataSet(entries: e2, label: "Pieces Hidden").applyStandard(lineColor: CommonUI().blueColorDark)
        lineChart.data = LineChartData(dataSets: [set1, set2])
        
        lineChart.leftAxis.axisMinimum = -1
        lineChart.leftAxis.axisMaximum = (lineChart.data?.yMax ?? 10) + 5
    }
    
    func setRush5AttemptChartData() {
        var e1 = [ChartDataEntry]()
        var e2 = [ChartDataEntry]()
        e1.append(ChartDataEntry(x: Double(puzzledUser.registerTimestamp!.timeIntervalSince1970),y:0.0))
        e2.append(ChartDataEntry(x: Double(puzzledUser.registerTimestamp!.timeIntervalSince1970),y:0.0))
        for i in 0..<rush5RegularAttempts.count {
            let rA = rush5RegularAttempts[i]
            e1.append(ChartDataEntry(x: Double(rA.timestamp!.timeIntervalSince1970), y: Double(rA.numCorrect)))
        }
        for i in 0..<rush5BlindfoldAttempts.count {
            let rA = rush5BlindfoldAttempts[i]
            e2.append(ChartDataEntry(x: Double(rA.timestamp!.timeIntervalSince1970), y: Double(rA.numCorrect)))
        }
        let date = Date()
       // e1.append(ChartDataEntry(x: Double(date.timeIntervalSince1970),y:Double(puzzledUser.rush5_HS)))
       // e2.append(ChartDataEntry(x: Double(date.timeIntervalSince1970),y: Double(puzzledUser.rush5B_HS)))
        let set1 = LineChartDataSet(entries: e1, label: "Pieces Shown").applyStandard(lineColor: CommonUI().greenColor)
        let set2 = LineChartDataSet(entries: e2, label: "Pieces Hidden").applyStandard(lineColor: CommonUI().blueColorDark)
        lineChart.data = LineChartData(dataSets: [set1, set2])
        
        lineChart.leftAxis.axisMinimum = -1
        lineChart.leftAxis.axisMaximum = (lineChart.data?.yMax ?? 10) + 10
    }
    
    // MARK: - Selectors
    
    @objc func refreshAction() {
        fetchData()
        progressTable.puzzleAttempts = puzzleAttempts
        progressTable.rush3attempts = rush3Attempts
        progressTable.rush5attempts = rush5Attempts
        puzzleModeSegment.sendActions(for: .valueChanged)
     
    }
    
    @objc func modeSegmentAction() {
        switch puzzleModeSegment.selectedSegmentIndex {
        case 0: // rated puzzles
            progressTable.attemptType = 0
            scoreView.setLabelValues(forPuzzledUser: puzzledUser, forAttemptType: 0, isBlindfold: false)
            scoreBView.setLabelValues(forPuzzledUser: puzzledUser, forAttemptType: 0, isBlindfold: true)
            tableTitleLabel.text = "Recent Puzzle Attempts"
            setPuzzleAttemptChartData()
            break
        case 1: // rush 3 min
            progressTable.attemptType = 1
            scoreView.setLabelValues(forPuzzledUser: puzzledUser, forAttemptType: 1, isBlindfold: false)
            scoreBView.setLabelValues(forPuzzledUser: puzzledUser, forAttemptType: 1, isBlindfold: true)
            tableTitleLabel.text = "Recent 3min Puzzle Rush"
            setRush3AttemptChartData()
            break
        case 2: // rush 5 min
            progressTable.attemptType = 2
            scoreView.setLabelValues(forPuzzledUser: puzzledUser, forAttemptType: 2, isBlindfold: false)
            scoreBView.setLabelValues(forPuzzledUser: puzzledUser, forAttemptType: 2, isBlindfold: true)
            tableTitleLabel.text = "Recent 5min Puzzle Rush"
            setRush5AttemptChartData()
            break
        default: break
        }
        DispatchQueue.main.async {
            self.progressTable.tableView.reloadData()
        }
    }
    
    // MARK: - Config Helper
    
    func configSegment(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        sc.addTarget(self, action: #selector(modeSegmentAction), for: .valueChanged)
        let font = UIFont(name: fontString, size: 16)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().csRed], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.darkGray], for: .normal)
        sc.tintColor = .lightGray
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = CommonUI().blackColor
        sc.layer.cornerRadius = 20
        sc.clipsToBounds = true
        return sc
    }
}

extension ProgressController: ProgressTableDelegate {
    func didSelectPuzzle(type: Int, index: Int) {
        let request = PuzzleReference.fetchRequest() as NSFetchRequest<PuzzleReference>
        request.predicate = NSPredicate(format:"puzzleType == \(type) AND puzzleIndex == \(index)")
        do {
            let pRef = try context.fetch(request)
            let controller = PuzzleLearningController(piecesHidden: false, puzzleReference: pRef[0], senderIsProgressController: true)
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        } catch {
            print("Error fetching PuzzleReference and presenting learning controller")
        }
    }
}

extension LineChartDataSet {
    func applyStandard(lineColor: NSUIColor) -> LineChartDataSet{
        self.colors = [lineColor]
        self.axisDependency = .left
        self.drawCirclesEnabled = true
        self.drawValuesEnabled  = false
        self.drawCircleHoleEnabled = false
        self.circleRadius = 2
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
        self.xAxis.drawGridLinesEnabled = false
        self.leftAxis.drawGridLinesEnabled = false
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


