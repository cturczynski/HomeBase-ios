//
//  NavBarViewController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/11/22.
//

import Foundation
import UIKit

class NavBarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.addCustomBottomLine(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.05), height: 1)
        
        let logo = UIImage(named: "homebase-logo.png")
        let logoView = UIImageView(image: logo)
        
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.widthAnchor.constraint(equalToConstant: (navigationController?.navigationBar.frame.width)!/2).isActive = true
        logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor, multiplier: 0.18).isActive = true
        navigationItem.titleView = logoView
    }
    
}

extension UINavigationController
{
    func addCustomBottomLine(color:UIColor,height:Double)
    {
        //Hiding Default Line and Shadow
        navigationBar.setValue(true, forKey: "hidesShadow")
        //Creating New line
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width:0, height: height))
        lineView.backgroundColor = color
        navigationBar.addSubview(lineView)

        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.widthAnchor.constraint(equalTo: navigationBar.widthAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
        lineView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
    }
}
