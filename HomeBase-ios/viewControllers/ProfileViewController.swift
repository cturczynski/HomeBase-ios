//
//  ProfileViewController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 6/27/22.
//

import Foundation
import UIKit

class ProfileViewController: NavBarViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.image = UIImage(named: "profile-icon")
        if let user = currentUser {
            nameLabel.text = user.name
            nameLabel.adjustsFontSizeToFitWidth = true
            emailLabel.text = user.email
            emailLabel.adjustsFontSizeToFitWidth = true
            phoneLabel.text = formatPhoneNumber(phone: user.phone)
            phoneLabel.adjustsFontSizeToFitWidth = true
            startDateLabel.text = createDateFormatter(withFormat: "MM/dd/yyyy").string(from: user.startDate)
            startDateLabel.adjustsFontSizeToFitWidth = true
        } else {
            goToViewController(vcId: "LoginViewController", fromController: self)
        }
        EmployeeRequest.init(action: "update").setEmployee { [weak self] result in
            switch(result) {
            case .failure(let error):
                print(error)
            case .success(let success):
                if success {
                    print(success)
                } else {
                    
                }
            }
        }
        
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        currentUser = nil
        currentUserShifts = nil
        goToViewController(vcId: "LoginViewController", fromController: self)
    }
    
}
