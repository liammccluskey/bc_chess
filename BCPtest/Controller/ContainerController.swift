//
//  ContainerController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class ContainerController: UIViewController {
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configSignInController()
    }
    
    // MARK: - Config
    
    func configSignInController() {
        let controller = SignInController()
        controller.delegate = self
        showChildViewController(child: controller)
    }

    func configTabBarController() {
        let controller = TabBarController()
        showChildViewController(child: controller)
    }
    
    // MARK: - Handlers
    
    func showChildViewController(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        didMove(toParent: self)
    }
}

extension ContainerController: SignInDelegate {
    func notifyOfSignIn() {
        configTabBarController()
    }
}
