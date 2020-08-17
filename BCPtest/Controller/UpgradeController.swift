//
//  UpgradeController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/16/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import StoreKit

class UpgradeController: UIViewController {
    
    // MARK: - Properties
    
    var upgradeButton: UIButton!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        configAutoLayout()
    }
    
    // MARK: - Config
    
    func configUI() {
        
    }
    
    func configAutoLayout() {
        
    }
    
    func configUpgradeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Upgrade", for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 23)
        button.backgroundColor = CommonUI().csRed
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(upgradeAction), for: .touchUpInside)
        button.setTitleColor(CommonUI().redColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Selectors
    
    @objc func upgradeAction() {
        
    }
    
    
}
