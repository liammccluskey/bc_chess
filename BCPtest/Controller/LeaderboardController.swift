//
//  LeaderboardController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class LeaderboardController: UIViewController {
    
    // MARK: - Properties
    
    var publicDBMS: PublicDBMS!
    var rankedUsers: RankedUsers!
    
    var segmentStack: UIStackView!
    var rushTypeSegment: UISegmentedControl!
    var visibilitySegment: UISegmentedControl!
    var leaderboardTable: LeaderboardTableController!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        configAutoLayout()
        
        publicDBMS = PublicDBMS()
        publicDBMS.delegate = self
        publicDBMS.fetchRankedUsers()
    }
    
    // MARK: - Config
    
    func configUI() {
        configNavigationBar()
        
        rushTypeSegment = configSegment(items: ["Rush 3 min", "Rush 5 min"])
        visibilitySegment = configSegment(items: ["Regular", "Blindfold"])
        segmentStack = CommonUI().configureStackView(arrangedSubViews: [rushTypeSegment, visibilitySegment])
        segmentStack.spacing = 10
        view.addSubview(segmentStack)
        
        leaderboardTable = LeaderboardTableController()
        view.addSubview(leaderboardTable.tableView)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        segmentStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        segmentStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        segmentStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        leaderboardTable.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leaderboardTable.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        leaderboardTable.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        leaderboardTable.tableView.topAnchor.constraint(equalTo: segmentStack.bottomAnchor, constant: 20).isActive = true
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().navBarColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        let font = UIFont(name: fontStringBold, size: 17)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.white]
        navigationItem.title = "Leaderboard"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: self, action: #selector(showMeAction))
    }
    
    func configSegment(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        let font = UIFont(name: fontString, size: 15)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().softWhite], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.darkGray], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .black
        sc.selectedSegmentTintColor = .black
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        return sc
    }
    
    // MARK: - Selectors
    
    @objc func showMeAction() {
        let indexPath = IndexPath(row: leaderboardTable.thisUserPosition, section: 0)
        if leaderboardTable.thisUserPosition != -1 {
            leaderboardTable.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    @objc func segmentAction() {
        let rushType = rushTypeSegment.selectedSegmentIndex
        let visibility = visibilitySegment.selectedSegmentIndex
        var unsortedUsers: [RankedUser] = []
        if rushType == 0 && visibility == 0 { unsortedUsers = rankedUsers.RUSH3 }
        else if rushType == 0 && visibility == 1 { unsortedUsers = rankedUsers.RUSH3B }
        else if rushType == 1 && visibility == 0 { unsortedUsers = rankedUsers.RUSH5 }
        else if rushType == 1 && visibility == 1 { unsortedUsers = rankedUsers.RUSH5B }
        
        let sortedUsers = unsortedUsers.sorted(by: {Int($0.SCORE)! > Int($1.SCORE)!})
        leaderboardTable.rankedUsers = sortedUsers
        
        if let thisUser = Auth.auth().currentUser {
            if let thisUserPosition = sortedUsers.firstIndex(where: {$0.UID == thisUser.uid}) {
                leaderboardTable.thisUserPosition = thisUserPosition
                print("Position: " + String(thisUserPosition))
            }
            else {
                leaderboardTable.thisUserPosition = -1
            }
        }
        
        
        DispatchQueue.main.async {
            self.leaderboardTable.tableView.reloadData()
        }
    }
    
    @objc func refreshAction() {
        publicDBMS.fetchRankedUsers()
    }
}

extension LeaderboardController: PublicDBMSDelegate {
    func sendRankedUsers(rankedUsers: RankedUsers?) {
        guard let users = rankedUsers else {return}
        self.rankedUsers = users
        rushTypeSegment.sendActions(for: .valueChanged)
    }
    func sendDailyPuzzlesInfo(info: DailyPuzzlesInfo?) {
    }
}

struct RankedMinimums: Codable {
    var RUSH3: RankedUser
    var RUSH3B: RankedUser
    var RUSH5: RankedUser
    var RUSH5B: RankedUser
    
    func getValue(forKey key: String) -> RankedUser {
        if key == "RUSH3" { return self.RUSH3 }
        else if key == "RUSH3B" { return self.RUSH3B }
        else if key == "RUSH5" { return self.RUSH5 }
        else if key == "RUSH5B" { return self.RUSH5B }
        else { return self.RUSH3 }
    }
    
    mutating func setValue(value: RankedUser, forKey key: String) -> RankedMinimums{
        if key == "RUSH3" { self.RUSH3 = value }
        else if key == "RUSH3B" { self.RUSH3B = value }
        else if key == "RUSH5" { self.RUSH5 = value }
        else if key == "RUSH5B" { self.RUSH5B = value }
        return self
    }
}

struct RankedUsers: Codable {
    var RUSH3: [RankedUser]
    var RUSH3B: [RankedUser]
    var RUSH5: [RankedUser]
    var RUSH5B: [RankedUser]
}

struct RankedUser: Codable {
    var UID: String
    var USERNAME: String
    var SCORE: String
    var COUNTRY_CODE: String
    
    func toDict() -> [String: Any] {
        return ["SCORE": self.SCORE, "UID": self.UID, "USERNAME": self.USERNAME, "COUNTRY_CODE": self.COUNTRY_CODE]
    }
}







