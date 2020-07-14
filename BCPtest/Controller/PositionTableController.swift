//
//  PositionTableController.swift
//  BCPtest
//
//  Created by Marty McCluskey on 7/12/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class PositionTableController: UITableViewController {
    
    // MARK: - Properties
    
    var puzzle: Puzzle?
    var isWhite: Bool = true // not checked unless self.puzzle != nil
    
    // MARK: - Config
    
    init(puzzle: Puzzle, isWhite: Bool) {
        self.puzzle = puzzle
        self.isWhite = isWhite
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .black
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = isWhite ? "WHITE POSITION" : "BLACK POSITION"
        label.textColor = .white
        label.backgroundColor = .clear
        label.textAlignment = .center
        view.backgroundColor = .black
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.imageView?.image = UIImage(named: "bb")?.withRenderingMode(.alwaysOriginal)
        guard let p = puzzle else {return cell}
        let position = p.position
        switch indexPath.row {
        case 0: // pawn
            let squares = isWhite ? position.P : position.p
            cell.textLabel?.text = squares.joined(separator: ", ")
            let imageName = isWhite ? "wp":"bp"
            cell.imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
            if squares.count > 4 {
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
            }
        case 1: // knight
            let squares = isWhite ? position.N : position.n
            cell.textLabel?.text = squares.joined(separator: ", ")
            let imageName = isWhite ? "wn":"bn"
            cell.imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        case 2: // bishop
            let squares = isWhite ? position.B : position.b
            cell.textLabel?.text = squares.joined(separator: ", ")
            let imageName = isWhite ? "wb":"bb"
            cell.imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        case 3: // rook
            let squares = isWhite ? position.R : position.r
            cell.textLabel?.text = squares.joined(separator: ", ")
            let imageName = isWhite ? "wr":"br"
            cell.imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        case 4: // queen
            let squares = isWhite ? position.Q : position.q
            cell.textLabel?.text = squares.joined(separator: ", ")
            let imageName = isWhite ? "wq":"bq"
            cell.imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        case 5: // king
            let squares = isWhite ? position.K : position.k
            cell.textLabel?.text = squares.joined(separator: ", ")
            let imageName = isWhite ? "wk":"bk"
            cell.imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        default:
            print()
        }
        cell.imageView?.backgroundColor = CommonUI().blueColor
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .black
        
        return cell
    }
 
    // MARK: - Interface
    
    func setData(puzzle: Puzzle, isWhite: Bool) {
        self.puzzle = puzzle
        self.isWhite = isWhite
    }
    
}
