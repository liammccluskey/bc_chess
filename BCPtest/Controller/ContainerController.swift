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
public var tabBarHeight: CGFloat = 49

class ContainerController: UIViewController {
    
    // MARK: - Properties
    
    var currentMainVCIndex: Int = -1
    lazy var tempHoverView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        
        return v
    }()
    var mainViewController: UINavigationController!
    var menuTableController: SlideMenuTableController!
    let menuTableWidth: CGFloat = UIScreen.main.bounds.width*0.6
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        PFJ = PuzzlesFromJson()
        
        let UDM = UserDataManager()
        
        if UDM.isFirstLaunch() {
            PFJ.savePuzzlesToCoreData()
            UDM.setDidLaunch()
            UDM.setMembershipType(type: 0)
        }
        if UDM.isFirstLaunchOfNewestVersion() {
            UDM.setDidLaunchNewestVersion()
            UDM.setBoardColor(boardColor: ColorTheme(rawValue: 0)!)
            UDM.setPieceStyle(pieceStyle: 0)
        }
        
        if let _ = Auth.auth().currentUser {
            let userHasCoreData: Bool = UserDBMS().getPuzzledUser() != nil
            if userHasCoreData == false {
                UserDBMS().initExistingUserCoreData(uid: Auth.auth().currentUser!.uid)
            }
            configMenuTableController()
            configMainViewController(withIndex: 0, isInitLoad: true)
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

    func configMenuTableController() {
        menuTableController = SlideMenuTableController(style: .plain)
        menuTableController.delegate = self
        let menuWidth: CGFloat = menuTableWidth
        let menuHeight: CGFloat = UIScreen.main.bounds.height
        menuTableController.tableView.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: menuHeight)
        
        view.addSubview(menuTableController.tableView)
    }
    
    func configMainViewController(withIndex vcIndex: Int, isInitLoad: Bool = false) {
        if currentMainVCIndex == vcIndex {
            return
        }
        currentMainVCIndex = vcIndex
        if mainViewController != nil {
            mainViewController.view.removeFromSuperview()
        }
        var controller = SlideMenuItems(rawValue: vcIndex)!.linkedViewController
        if let _controller = controller as? SettingsController {
            _controller.delegate = self
            controller = _controller
        }
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(showMenuAction))
        mainViewController = UINavigationController(rootViewController: controller)
        mainViewController.view.frame.origin.x = isInitLoad ? 0 : menuTableWidth
        view.addSubview(mainViewController.view)
    }
    
    // MARK: - Handlers
    
    func showChildViewController(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        didMove(toParent: self)
    }

    // MARK: - Selectors
    
    @objc func showMenuAction() {
        UIView.animate(withDuration: 0.2, animations: {
            self.menuTableController.tableView.frame.origin.x = 0
            self.mainViewController.view.frame.origin.x = self.menuTableWidth
        }) { (_) in
            self.view.addSubview(self.tempHoverView)
            self.tempHoverView.frame = self.mainViewController.view.frame
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideMenuAction))
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.hideMenuAction))
            swipe.direction = .left
            self.tempHoverView.addGestureRecognizer(tap)
            self.tempHoverView.addGestureRecognizer(swipe)
        }
    }
    
    @objc func hideMenuAction() {
        hideMenu()
    }
    
    func hideMenu() {
        tempHoverView.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.menuTableController.tableView.frame.origin.x = -self.menuTableWidth
            self.mainViewController.view.frame.origin.x = 0
        })
    }
   
}

extension ContainerController: SignInDelegate, SignOutDelegate {
    func notifyOfSignIn() {
        configMenuTableController()
        configMainViewController(withIndex: 0, isInitLoad: true)
    }
    
    func notifyOfSignOut() {
        view.subviews.forEach{ (subview) in subview.removeFromSuperview()}
        configSignInController()
    }
}

extension ContainerController: SlideMenuTableDelegate {
    func didSelectController(controllerIndex: Int) {
        configMainViewController(withIndex: controllerIndex)
        hideMenu()
    }
}


