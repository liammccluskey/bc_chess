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

import CoreData

// globals
var PFJ: PuzzlesFromJson!
class ContainerController: UIViewController {
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        PFJ = PuzzlesFromJson()
        if UserDataManager().isFirstLaunch() {
            PFJ.savePuzzlesToCoreData()
            UserDataManager().setDidLaunch()
            UserDataManager().setMembershipType(type: 0)
            configSignInController()
        } else if let _ = Auth.auth().currentUser {
            let userHasCoreData: Bool = UserDBMS().getPuzzledUser() != nil
            if userHasCoreData == false {
                UserDBMS().initExistingUserCoreData(uid: Auth.auth().currentUser!.uid)
            }
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
