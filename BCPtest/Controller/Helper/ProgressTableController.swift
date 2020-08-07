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
    
    var puzzleAttempts: [PuzzleAttempt] = []
    var rush5attempts: [Rush5Attempt] = []
    var rush3attempts: [Rush3Attempt] = []
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.layer.borderColor = CommonUI().blackColorLight.cgColor
        tableView.layer.borderWidth = 4
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        
        tableView.register(PuzzleAttemptCell.self, forCellReuseIdentifier: puzzleAttemptCellID)
    }
    
    // MARK: - Config
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return puzzleAttempts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attempt = puzzleAttempts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: puzzleAttemptCellID, for: indexPath) as! PuzzleAttemptCell
        cell.puzzleAttempt = attempt
        return cell
    }
}

let puzzleAttemptCellID = "pacID"
class PuzzleAttemptCell: UITableViewCell {
    
    // MARK: - Init
    
    var puzzleAttempt: PuzzleAttempt! {
        didSet {
            configUI()
            configAutoLayout()
        }
    }
    var hstack: UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Config
    
    func configUI() {
        let puzzleID = String(repeating: "0", count: 7 - String(puzzleAttempt.puzzleIndex).count)
            + String(puzzleAttempt.puzzleIndex) + String(puzzleAttempt.puzzleType)
        let deltaColor = puzzleAttempt.wasCorrect ? CommonUI().greenColor : CommonUI().redColor
        let delta = puzzleAttempt.wasCorrect ? "+ " : " - "
        let visibility = puzzleAttempt.piecesHidden ? "Regular  " : "Blindfold"
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let date = formatter.string(from: puzzleAttempt.timestamp!)
        hstack = CommonUI().configureHStackView(arrangedSubViews: [
            UILabel().configCellLabel(text: "#\(puzzleID)", textColor: .lightGray),
            UILabel().configCellLabel(text: "\(delta)\(puzzleAttempt.ratingDelta)", textColor: deltaColor),
            UILabel().configCellLabel(text: visibility, textColor: .lightGray),
            UILabel().configCellLabel(text: date, textColor: .white)
        ])
        addSubview(hstack)
        
        backgroundColor = .clear
    }
    
    func configAutoLayout() {
        hstack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        hstack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        hstack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        hstack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}
