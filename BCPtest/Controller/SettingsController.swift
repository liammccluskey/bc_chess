//
//  SettingsController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth
import StoreKit

class SettingsController: UIViewController {
    
    // MARK: - Properties
    
    var delegate: SignOutDelegate?
    
    var settingsTable: SettingsTableController!
    var signOutButton: UIButton!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        configAutoLayout()
    }
    
    // MARK: - Config
    
    func configUI() {
        configNavigationBar()
        
        settingsTable = SettingsTableController()
        view.addSubview(settingsTable.tableView)
        
        signOutButton = configSignOutButton()
        view.addSubview(signOutButton)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        settingsTable.tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        settingsTable.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        settingsTable.tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        settingsTable.tableView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        signOutButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        signOutButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 17)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.white]
        navigationItem.title = "Settings".uppercased()
    }
    
    func configSignOutButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 25)
        button.backgroundColor = CommonUI().blackColor
        button.layer.borderWidth = 3
        button.layer.borderColor = CommonUI().redColor.cgColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
    
        button.addTarget(self, action: #selector(signOutAction), for: .touchUpInside)
        button.setTitleColor(CommonUI().redColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Selectors
    
    @objc func signOutAction() {
        do { try Auth.auth().signOut() }
        catch { print("sign out error") }
        delegate?.notifyOfSignOut()
    }

}

class SettingsTableController: UITableViewController {
    
    // MARK: - Init
    
    var settingsOptions = ["Board Theme", "Rate the App"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: settingsCellID)
        
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //tableView.separatorColor = .white
        view.backgroundColor = .clear
    }
    
    // MARK: - Config
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsCellID, for: indexPath) as! SettingsCell
        let settingsOption = settingsOptions[indexPath.row]
        cell.settingsOption = settingsOption
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let controller = ThemeTableController(style: .insetGrouped)
            present(controller, animated: true)
            break;
        case 1: SKStoreReviewController.requestReview(); break;
        default: break;
        }
    }
}

let settingsCellID = "settingsCellID"
class SettingsCell: UITableViewCell {
    
    // MARK: - Init
    
    var settingsOption: String! {
        didSet {
            l1.text = settingsOption
        }
    }

    var l1: UILabel!
    var editButton: UIButton! = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
        configAutoLayout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Config
    
    func configUI() {
        l1 = configCellLabel(text: "", textColor: .white)
        addSubview(l1)
        addSubview(editButton)
        
        backgroundColor = .clear
    }
    
    func configAutoLayout() {
        l1.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        l1.topAnchor.constraint(equalTo: topAnchor).isActive = true
        l1.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        editButton.rightAnchor.constraint(equalTo: rightAnchor, constant:0).isActive = true
        editButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        editButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    func configCellLabel(text: String, textColor: UIColor) -> UILabel{
        let l = UILabel()
        l.text = text
        l.textColor = textColor
        l.textAlignment = .left
        l.font = UIFont(name: fontStringLight, size: 18)
        l.backgroundColor = .clear
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
}

