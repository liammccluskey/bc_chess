//
//  TabBarController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//
 
import UIKit

public var tabBarHeight: CGFloat!
class TabBarController: UITabBarController {
    
    // MARK: - Properties
    
    var signOutDelegate: SignOutDelegate?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarHeight = tabBar.frame.height
        
        configureTabBar()
    }
    
    // MARK: - Config
    
    func configureTabBar() {
        let homeController = HomeController()
        let progressController = ProgressController()
        let leaderboardController = LeaderboardController()
        let settingsController = SettingsController()
        settingsController.delegate = self
        
        let controller1 = UINavigationController(rootViewController: homeController)
        //controller1.tabBarItem.image = #imageLiteral(resourceName: "puzzle")
        //controller1.tabBarItem.title = "Puzzles"
        controller1.tabBarItem.image = UIImage(systemName: "house.fill")
        controller1.tabBarItem.title = "Home"
        let controller2 = UINavigationController(rootViewController: progressController)
        //controller2.tabBarItem.image = #imageLiteral(resourceName: "progress")
        controller2.tabBarItem.image = UIImage(systemName: "chart.bar.fill")
        controller2.tabBarItem.title = "Progress"
        let controller3 = UINavigationController(rootViewController: leaderboardController)
        //controller3.tabBarItem.image = #imageLiteral(resourceName: "leaderboard")
        controller3.tabBarItem.image = UIImage(systemName: "person.3.fill")
        controller3.tabBarItem.title = "Leaderboard"
        let controller4 = UINavigationController(rootViewController: settingsController)
        controller4.tabBarItem.image = #imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate)
        //controller4.tabBarItem.image = UIImage(systemName: "gearshape")
        controller4.tabBarItem.title = "Settings"
    
        viewControllers = [controller1, controller2, controller3, controller4]
 
        tabBar.barTintColor = CommonUI().tabBarColor
        tabBar.tintColor = CommonUI().csRed
        
        tabBar.isTranslucent = false
    }
}

extension TabBarController: SignOutDelegate {
    func notifyOfSignOut() {
        signOutDelegate?.notifyOfSignOut()
    }
    
    
}
    
