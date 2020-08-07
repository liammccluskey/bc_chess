//
//  SettingsController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsController: UIViewController {
    
    // MARK: - Properties
    
    var delegate: SignOutDelegate?
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
        
        signOutButton = configSignOutButton()
        view.addSubview(signOutButton)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        signOutButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        signOutButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 25)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.lightGray]
        navigationItem.title = "Settings"
    }
    
    func configSignOutButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("SIGN OUT", for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 30)
        button.backgroundColor = CommonUI().blackColor
        button.layer.borderWidth = 4
        button.layer.borderColor = CommonUI().blackColorLight.cgColor
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
