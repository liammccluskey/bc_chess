//
//  ContainerController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

// globals
var puzzlesFromJSON: Puzzles!
var PFJ = PuzzlesFromJson()
class ContainerController: UIViewController {
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PFJ = PuzzlesFromJson()
        
        //puzzlesFromJSON = PuzzlesFromJson().puzzles
        configTabBarController()
        
        if Auth.auth().currentUser != nil {
            configTabBarController()
        } else {
            configSignInController()
        }
        
    }
    
    // MARK: - Config
    
    func configSignInController() {
        let controller = SignInController()
        controller.delegate = self
        showChildViewController(child: controller)
    }

    func configTabBarController() {
        let controller = TabBarController()
        controller.signOutDelegate = self
        showChildViewController(child: controller)
    }
    
    // MARK: - Handlers
    
    func showChildViewController(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        didMove(toParent: self)
    }
    
   
}

extension ContainerController: SignInDelegate, SignOutDelegate {
    func notifyOfSignIn() {
        configTabBarController()
    }
    
    func notifyOfSignOut() {
        view.subviews.forEach{ (subview) in subview.removeFromSuperview()}
        configSignInController()
    }
}
