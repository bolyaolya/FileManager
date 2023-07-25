//
//  TabBarController.swift
//  FileManager
//
//  Created by Ольга Бойко on 24.07.2023.
//

import UIKit

final class TabBarController : UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
        configure()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let fileVC = FilesViewController()
        let settingsVC = SettingsViewController()
        
        let fileNavContr = UINavigationController.init(rootViewController: fileVC)
        let settingsNavContr = UINavigationController.init(rootViewController: settingsVC)
        
        fileVC.tabBarItem = UITabBarItem(title: "Documents", image: UIImage(systemName: "folder"), tag: 0)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().backgroundColor = .systemGray6
        tabBar.unselectedItemTintColor = .gray
        tabBar.selectedImageTintColor = .blue
        
        setViewControllers([fileNavContr, settingsNavContr], animated: true)
    }
}
