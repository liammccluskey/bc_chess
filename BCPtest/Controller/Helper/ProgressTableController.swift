//
//  ProgressTableController.swift
//  BCPtest
//
//  Created by Guest on 8/6/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import CoreData

// PuzzleAttempt: #00050054     +10     Blind   10/10/20
// rushattempt:   #Score: 35    Timeout/Strikeout   10/10/20

class ProgressTableController: UITableViewController {
    
    // MARK: - Properties
    
    var delegate: ProgressTableDelegate?
    var puzzleAttempts: [PuzzleAttempt] = []
    var rush3attempts: [Rush3Attempt] = []
    var rush5attempts: [Rush5Attempt] = []
    var attemptType: Int = 0// 0: puzzleAttempt, 1: rush3attempt, 2: rush5attempt
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //tableView.backgroundColor = .clear
        tableView.layer.borderColor = CommonUI().blackColorLight.cgColor
        tableView.layer.borderWidth = 1.5
        tableView.separatorColor = .darkGray
        tableView.backgroundColor = UIColor(red: 5/255, green: 5/255, blue: 8/255, alpha: 1)
        
        tableView.register(PuzzleAttemptCell.self, forCellReuseIdentifier: puzzleAttemptCellID)
    }
    
    // MARK: - Config
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch attemptType {
        case 0: return puzzleAttempts.count
        case 1: return rush3attempts.count
        case 2: return rush5attempts.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: puzzleAttemptCellID, for: indexPath) as! PuzzleAttemptCell
        switch attemptType {
        case 0:
            let index = puzzleAttempts.count - indexPath.row - 1
            let attempt = puzzleAttempts[index]
            cell.puzzleAttempt = attempt
            return cell
        case 1:
            let index = rush3attempts.count - indexPath.row - 1
            let attempt = rush3attempts[index]
            cell.rush3Attempt = attempt
            return cell
        case 2:
            let index = rush5attempts.count - indexPath.row - 1
            let attempt = rush5attempts[index]
            cell.rush5Attempt = attempt
            return cell
        default:
            return cell
        }
      
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if attemptType == 0 { // puzzle rush attempts don't currently have an action
            let index = puzzleAttempts.count - indexPath.row - 1
            let attempt = puzzleAttempts[index]
            delegate?.didSelectPuzzle(type: Int(attempt.puzzleType), index: Int(attempt.puzzleIndex))
        }
    }
}

let puzzleAttemptCellID = "pacID"
class PuzzleAttemptCell: UITableViewCell {
    
    // MARK: - Init
    
    var puzzleAttempt: PuzzleAttempt! {
        didSet {
            let puzzleID = String(repeating: "0", count: 7 - String(puzzleAttempt.puzzleIndex).count)
                + String(puzzleAttempt.puzzleIndex) + String(puzzleAttempt.puzzleType)
            let deltaColor = puzzleAttempt.wasCorrect ? CommonUI().greenColor : CommonUI().redColor
            let delta = puzzleAttempt.wasCorrect ? "+ " : "  "
            let visibility = puzzleAttempt.piecesHidden ? "Blindfold" : "Regular  "
            print(visibility)
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let date = formatter.string(from: puzzleAttempt.timestamp!)
            l1.text = "#\(puzzleID)"
            l2.textColor = deltaColor
            l2.text = "\(delta)\(puzzleAttempt.ratingDelta)"
            l3.text = visibility
            l4.text = date
        }
    }
    var rush3Attempt: Rush3Attempt! {
        didSet {
            let lossType = rush3Attempt.didTimeout ? "Timeout " : "Strikeout"
            let visibility = rush3Attempt.piecesHidden ? "Blindfold" : "Regular  "
            print(visibility)
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let date = formatter.string(from: rush3Attempt.timestamp!)
            l1.text = "Score: \(rush3Attempt.numCorrect)"
            l1.textColor = .white
            l2.text = lossType
            l2.textColor = CommonUI().redColor
            l3.text = visibility
            l4.text = date
        }
    }
    var rush5Attempt: Rush5Attempt! {
        didSet {
            let lossType = rush5Attempt.didTimeout ? "Timeout " : "Strikeout"
            let visibility = rush5Attempt.piecesHidden ? "Blindfold" : "Regular  "
            print(visibility)
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let date = formatter.string(from: rush5Attempt.timestamp!)
            l1.text = "Score: \(rush5Attempt.numCorrect)"
            l1.textColor = .white
            l2.textColor = CommonUI().redColor
            l2.text = lossType
            l3.text = visibility
            l4.text = date
        }
    }
    var l1: UILabel!
    var l2: UILabel!
    var l3: UILabel!
    var l4: UILabel!
    var hstack: UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
        configAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Config
    
    func configUI() {
        l1 =  UILabel().configCellLabel(text: "", textColor: .lightGray)
        l2 = UILabel().configCellLabel(text: "", textColor: .clear)
        l3 = UILabel().configCellLabel(text: "", textColor: .lightGray)
        l4 = UILabel().configCellLabel(text: "", textColor: .white)
        hstack = CommonUI().configureHStackView(arrangedSubViews: [l1, l2, l3, l4])
        hstack.distribution = .fillEqually
        addSubview(hstack)
        
        backgroundColor = .clear
    }
    
    func configAutoLayout() {
        hstack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        hstack.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        hstack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        hstack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}
