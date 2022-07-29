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
        let employeeRequest = EmployeeRequest.init(id: 1)
        employeeRequest.fetchEmployees { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let employees):
                let employee = employees[0]
                self?.nameLabel.text = employee.name
                self?.emailLabel.text = employee.email
                self?.phoneLabel.text = employee.phone
                self?.startDateLabel.text = employee.startDate.formatted()
            }
        }
    }
    
    @IBAction func signOutAction(_ sender: Any) {
    }
    
}
