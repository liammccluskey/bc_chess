//
//  LeaderboardTableController.swift
//  BCPtest
//
//  Created by Guest on 8/4/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth

class LeaderboardTableController: UITableViewController{
    
    // MARK: - Properties
    
    var rankedUsers: [RankedUser] = []
    var thisUserPosition: Int = 0
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LeaderboardTableCell.self, forCellReuseIdentifier: leaderboardTableCellID)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Config
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankedUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: leaderboardTableCellID, for: indexPath) as! LeaderboardTableCell
        let rankedUser = rankedUsers[indexPath.row]
        cell.rankedUser = rankedUser
        cell.rankIndex = indexPath.row + 1
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

let leaderboardTableCellID = "leaderboardTableCellID"
class LeaderboardTableCell: UITableViewCell {
    
    // MARK: - Init
    
    var rankIndex: Int! {
        didSet {
            l1.text = "# \(rankIndex ?? -1)    "
            if rankIndex == 1 { l1.backgroundColor = CommonUI().goldColor; l1.textColor = .white }
            else if rankIndex == 2 { l1.backgroundColor = CommonUI().silverColor; l1.textColor = .white }
            else if rankIndex == 3 { l1.backgroundColor = CommonUI().bronzeColor; l1.textColor = .white }
            else { l1.backgroundColor = .clear; l1.textColor = .lightGray }
        }
    }
    var rankedUser: RankedUser! {
        didSet {
            l2.text = flag(country: rankedUser.COUNTRY_CODE) + "  " + rankedUser.USERNAME
            l3.text = rankedUser.SCORE
            guard let thisUser = Auth.auth().currentUser else {return}
            if thisUser.uid == rankedUser.UID {
                backgroundColor = CommonUI().tabBarColor
            } else {
                backgroundColor = .clear
            }
        }
    }
    var l1: UILabel!
    var l2: UILabel!
    var l3: UILabel!
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
        l1 = UILabel().configLeaderboardCell(text: "", textColor: .lightGray, alignment: .center, fontSize: 15)
        l2 = UILabel().configLeaderboardCell(text: "", textColor: .lightGray, alignment: .left)
        l3 = UILabel().configLeaderboardCell(text: "", textColor: .white, alignment: .right)
        addSubview(l1)
        addSubview(l2)
        addSubview(l3)
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func configAutoLayout() {
        l1.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        l1.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //l1.widthAnchor.constraint(equalToConstant: 60).isActive = true
        l1.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        l2.leftAnchor.constraint(equalTo: l1.rightAnchor, constant: 10).isActive = true
        l2.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        l3.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        l3.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}

extension UILabel {
    func configLeaderboardCell(text: String, textColor: UIColor, alignment: NSTextAlignment, fontSize: CGFloat = 17) -> UILabel{
        self.text = text
        self.textColor = textColor
        self.textAlignment = alignment
        self.font = UIFont(name: fontString, size: fontSize)
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}


func flag(country:String) -> String {
    let base : UInt32 = 127397
    var s = ""
    for v in country.unicodeScalars {
        s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
}



