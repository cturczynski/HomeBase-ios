//
//  TabBarViewController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 6/27/22.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(red: 108/255, green: 205/255, blue: 238/255, alpha: 1)
        tabBar.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        tabBar.isTranslucent = true
    }
}
