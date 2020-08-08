//
//  ThemeTableController.swift
//  BCPtest
//
//  Created by Guest on 7/27/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class ThemeTableController: UITableViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var delegate: ThemeTableDelegate?
    
    var headerView = CommonUI().configureHeaderLabel(title: "SWIPE DOWN TO APPLY CHANGES", backC: CommonUI().blackColor, textC: .white)
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.backgroundColor = CommonUI().blackColor
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        
        autoLayout()
    }
    
  
    
    func autoLayout() {
        headerView.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 10).isActive = true
        headerView.layoutIfNeeded()
    }
    
    // MARK: - Config
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return ColorTheme.allCases.count
        case 1: return PieceStyleTheme.allCases.count
        //case 2: return ColorTheme.allCases.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Select Board Color Theme"
        case 1: return "Select Piece Style"
        //case 2: return "Select Button Color Theme"
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont(name: fontString, size: 18)
        cell.textLabel?.textColor = CommonUI().blackColor
        switch indexPath.section {
        case 1:
            let pieceStyle = PieceStyleTheme(rawValue: indexPath.row)
            cell.imageView?.image = pieceStyle!.imageSet.withRenderingMode(.alwaysOriginal)
            cell.backgroundColor = CommonUI().whiteColor
            return cell
        default:
            let colorTheme = ColorTheme(rawValue: indexPath.row)
            cell.textLabel?.textColor = CommonUI().blackColor
            cell.textLabel?.text = colorTheme?.description
            cell.backgroundColor = colorTheme!.darkSquareColor
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: UserDataManager().setBoardColor(boardColor: ColorTheme(rawValue: indexPath.row)!); break
        case 1: UserDataManager().setPieceStyle(pieceStyle: indexPath.row); break
        default: break
        }
        //delegate?.didSubmitChangeAt(indexPath: indexPath)
    }
}
