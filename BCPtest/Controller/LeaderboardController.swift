//
//  LeaderboardController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class LeaderboardController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        configAutoLayout()
    }
    
    // MARK: - Config
    
    func configUI() {
        configNavigationBar()
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 23)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.lightGray]
        navigationItem.title = "Leaderboard"
    }
}




