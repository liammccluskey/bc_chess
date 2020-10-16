//
//  SlideMenuTableController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 10/11/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class TestSlideMenuController: UIViewController {
    var slideMenu: SlideMenuTableController!
    override func viewDidLoad() {
        super.viewDidLoad()
        slideMenu = SlideMenuTableController()
        view.addSubview(slideMenu.tableView)
    }
    override func viewDidLayoutSubviews() {
        slideMenu.tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width*0.7, height: view.frame.height)
    }
}

class SlideMenuTableController: UITableViewController {
    
    // MARK: - Properties
    
    var delegate: SlideMenuTableDelegate?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = CommonUI().blackColorLight
        tableView.separatorColor = CommonUI().blackColor
    }
    
    // MARK: - Config
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SlideMenuItems.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        cell.backgroundColor = .clear
        cell.selectionStyle = .gray
        cell.imageView?.tintColor = .lightGray
        cell.textLabel?.textColor = .lightGray
        cell.textLabel?.font = UIFont(name: fontString, size: 17)
        let menuItem = SlideMenuItems(rawValue: indexPath.row)!
        cell.imageView?.image = menuItem.image ?? UIImage()
        cell.textLabel?.text = menuItem.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectController(controllerIndex: indexPath.row)
    }
}

enum SlideMenuItems: Int, CaseIterable {
    case home, progress, openings, leaderboard, upgrade, settings
    
    var description: String {
        switch self {
        case .home: return "Puzzles"
        case .progress: return "Progress"
        case .openings: return "Openings"
        case .leaderboard: return "Leaderboard"
        case .upgrade: return "Upgrade"
        case .settings: return "Settings"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .home: return UIImage(systemName: "house.fill")
        case .progress: return UIImage(systemName: "chart.bar.fill")
        case .openings: return UIImage(systemName: "book.fill")
        case .leaderboard: return UIImage(systemName: "person.3.fill")
        case .upgrade: return UIImage(systemName: "star.fill")
        case .settings: return #imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate)
        }
    }
    
    var linkedViewController: UIViewController {
        switch self {
        case .home: return HomeController()
        case .progress: return ProgressController()
        case .openings: return OpeningsController()
        case .leaderboard: return LeaderboardController()
        case .upgrade: return UpgradeController()
        case .settings: return SettingsController()
        }
    }
}
