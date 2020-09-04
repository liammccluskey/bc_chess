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

class SettingsController: UIViewController, SettingsTableDelegate {
    
    // MARK: - Properties
    
    var delegate: SignOutDelegate?
    
    var userInfoStack: UIStackView!
    
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
        
        userInfoStack = configUserInfoStack()
        view.addSubview(userInfoStack)
        
        settingsTable = SettingsTableController()
        settingsTable.settingsDelegate = self
        view.addSubview(settingsTable.tableView)
        
        signOutButton = configSignOutButton()
        view.addSubview(signOutButton)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        userInfoStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        userInfoStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        userInfoStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        settingsTable.tableView.topAnchor.constraint(equalTo: userInfoStack.bottomAnchor, constant: 20).isActive = true
        settingsTable.tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 10).isActive = true
        settingsTable.tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        settingsTable.tableView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor, constant: -20).isActive = true
        
        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signOutButton.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().navBarColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 15)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.white]
        navigationItem.title = "Settings".uppercased()
    }
    
    func configUserInfoStack() -> UIStackView? {
        guard let thisUser = Auth.auth().currentUser else {return nil}
        let membershipColor = UserDataManager().getMembershipColor()
        let membershipName = UserDataManager().getMembershipName()
        let emailView = configInfoView(titleText: "Email", valueText: thisUser.email ?? "N/A")
        let usernameView = configInfoView(titleText: "Username ", valueText: thisUser.displayName ?? "N/A")
        let membershipView = configInfoView(titleText: "Membership ", valueText: membershipName, valueColor: membershipColor)
        
        let vstack = CommonUI().configureStackView(arrangedSubViews: [emailView, usernameView, membershipView])
        vstack.spacing = 10
        return vstack
    }
    
    func configInfoView(titleText: String, valueText: String, valueColor: UIColor = .white) -> UIStackView {
        let title = UILabel()
        title.textColor = .white
        title.font = UIFont(name: fontString, size: 19)
        title.text = titleText
        let value = UILabel()
        value.textColor = valueColor
        value.font = UIFont(name: fontStringLight, size: 18)
        value.text = valueText
        
        let hstack = CommonUI().configureHStackView(arrangedSubViews: [title, value])
        hstack.distribution = .equalCentering
        hstack.translatesAutoresizingMaskIntoConstraints = true
        return hstack
    }
    
    func configSignOutButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont(name: fontStringBold, size: 20)
        button.backgroundColor = UIColor().fromRGB("235,235,240")
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(signOutAction), for: .touchUpInside)
        button.setTitleColor(CommonUI().blackColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Selectors
    
    @objc func signOutAction() {
        do { try Auth.auth().signOut() }
        catch { print("sign out error") }
        delegate?.notifyOfSignOut()
    }
    
    // MARK: - Extension
    
    func didSelectRow(rowIndex: Int) {
        switch rowIndex {
        case 0:
            let controller = ThemeController()
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)//present(ThemeTableController(style: .insetGrouped), animated: true)
        case 1: SKStoreReviewController.requestReview()
        case 2: navigationController?.pushViewController(UpgradeController(), animated: true)
        default: break;
        }
    }

}

class SettingsTableController: UITableViewController {
    
    // MARK: - Init
    
    var settingsDelegate: SettingsTableDelegate?
    var settingsOptions = ["Board Theme", "Rate the App", "Upgrade"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: settingsCellID)
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        settingsDelegate?.didSelectRow(rowIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
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
        button.setImage(UIImage(systemName: "chevron.right")?
            .withRenderingMode(.alwaysOriginal).withTintColor(CommonUI().silverColor), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        l1 = configCellLabel(text: "", textColor: .white)
        addSubview(l1)
        addSubview(editButton)
        
        backgroundColor = .clear
    }
    
    func configAutoLayout() {
        l1.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
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
        l.font = UIFont(name: fontString, size: 18)
        l.backgroundColor = .clear
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
}

