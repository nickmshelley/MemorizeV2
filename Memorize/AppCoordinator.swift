//
//  AppCoordinator.swift
//  Memorize
//
//  Created by Nick Shelley on 1/12/18.
//

import UIKit

final class AppCoordinator {
    let rootViewController: UITabBarController
    
    init(rootViewController: UITabBarController) {
        self.rootViewController = rootViewController
    }
    
    func start() {
        let reviewViewController = ReviewViewController()
        reviewViewController.tabBarItem = UITabBarItem(title: "Review", image: #imageLiteral(resourceName: "check-circle"), tag: 0)
        let cardsViewController = CardsViewController()
        cardsViewController.tabBarItem = UITabBarItem(title: "Cards", image: #imageLiteral(resourceName: "file"), tag: 0)
        let statsViewController = StatsViewController()
        statsViewController.tabBarItem = UITabBarItem(title: "Stats", image: #imageLiteral(resourceName: "bar-chart"), tag: 0)
        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "cog"), tag: 0)
        rootViewController.viewControllers = [reviewViewController, cardsViewController, statsViewController, settingsViewController]
        rootViewController.selectedViewController = reviewViewController
    }
}
