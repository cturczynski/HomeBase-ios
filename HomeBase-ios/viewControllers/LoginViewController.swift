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
        
        startLoadingView(controller: self)
        EmployeeRequest(id: nil, username: nil).fetchEmployees { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                    displayAlert("Error", message: "Could not log in at this time. Please try again later or contact support.", sender: self!)
                case .success(let employees):
                    let thisUser = employees.filter { $0.username.lowercased() == self?.usernameTextField.text?.lowercased() }
                    if thisUser.isEmpty {
                        displayAlert("Invalid login", message: "No users registered with that username.", sender: self!)
                    } else {
                        let employee = thisUser[0]
                        allEmployees = employees
                        self?.getUsersShifts(employee: employee)
                    }
                }
            }
        }
    }
    
    func getUsersShifts(employee: Employee) {
        let shiftRequest = ShiftRequest(id: nil, employee: employee.id, date: nil, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            DispatchQueue.main.async {
                endLoadingView()
                switch result {
                case .failure(let error):
                    print(error)
                    displayAlert("Error", message: "Could not load all user data. Please try again later or contact support.", sender: self!)
                case .success(let shifts):
                    self?.loginUser(user: employee, shifts: shifts)
                }
            }
        }
    }
    
    func loginUser(user: Employee, shifts: [Shift]) {
        currentUser = user
        currentUserShifts = shifts
        makeNewRootController(vcId: "TabBarViewController", fromController: self)
    }
}
