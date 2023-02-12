//
//  MainTabBarViewController.swift
//  NasaApp
//
//  Created by Şükrü Özkoca on 31.01.2023.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let vc1 = UINavigationController(rootViewController: CuriosityViewController())
        let vc2 = UINavigationController(rootViewController: OpportunityViewController())
        let vc3 = UINavigationController(rootViewController: SpiritViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "photo")
        vc2.tabBarItem.image = UIImage(systemName: "photo")
        vc3.tabBarItem.image = UIImage(systemName: "photo")

        vc1.title = "Curiosity"
        vc2.title = "Opportunity"
        vc3.title = "Spirit"
        
        tabBar.tintColor = .black
        
        setViewControllers([vc1,vc2,vc3], animated: true)
    }
}
