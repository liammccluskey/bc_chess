//
//  TabBarController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//
 
import UIKit

class TabBarController: UITabBarController {
    
    // MARK: - Properties
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabBar()
    }
    
    // MARK: - Config
    
    func configureTabBar() {
        let homeController = HomeController()
        let progressController = ProgressController()
        let leaderboardController = LeaderboardController()
        let settingsController = SettingsController()
        
        let controller1 = UINavigationController(rootViewController: homeController)
        controller1.tabBarItem.image = #imageLiteral(resourceName: "puzzle")
        controller1.tabBarItem.title = "Puzzles"
        let controller2 = UINavigationController(rootViewController: progressController)
        controller2.tabBarItem.image = #imageLiteral(resourceName: "progress")
        controller2.tabBarItem.title = "Progress"
        let controller3 = UINavigationController(rootViewController: leaderboardController)
        controller3.tabBarItem.image = #imageLiteral(resourceName: "leaderboard")
        controller3.tabBarItem.title = "Leaderboard"
        let controller4 = UINavigationController(rootViewController: settingsController)
        controller4.tabBarItem.image = #imageLiteral(resourceName: "settings")
        controller4.tabBarItem.title = "Settings"
        
        
        
        viewControllers = [controller1, controller2, controller3, controller4]
        
        
        
        // black bar with white items
        //tabBar.barTintColor = .black
        //tabBar.tintColor = .white
        
        // white bar with black items
        tabBar.barTintColor = .black
        tabBar.tintColor = CommonUI().blueColorLight
        
        tabBar.isTranslucent = false
    }
}
    
