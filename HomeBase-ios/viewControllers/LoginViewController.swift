//
//  LoginViewController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/29/22.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signInAction(_ sender: Any) {
        if usernameTextField.text!.count <= 0 { return }
        
        let employeeRequest = EmployeeRequest.init(id: nil, username: usernameTextField.text)
        employeeRequest.fetchEmployees { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let employees):
                DispatchQueue.main.async {
                    if employees.isEmpty {
                        displayAlert("Invalid login", message: "No users registered with that username.", sender: self!)
                    } else {
                        let employee = employees[0]
                        self?.loginUser(user: employee)
                    }
                }
            }
        }
    }
    
    func loginUser(user: Employee) {
        currentUser = user
        goToViewController(vcId: "TabBarViewController", fromController: self)
    }
}
