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
    
    //newUser flag to save time not retrieving shifts if we know we don't need to
    var newUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInAction(_ sender: Any) {
        if usernameTextField.text!.count <= 0 { return }
        
        newUser = false
        startLoadingView(controller: self)
        //allow for shortcut for making new users from app
        if passwordTextField.text?.lowercased() == "admin" {
            createAndLoginUser()
        } else {
            getAndLoginUser()
        }
    }
    
    func createAndLoginUser() {
        let username = usernameTextField.text!.lowercased()
        let firstLetter: String = (username[username.startIndex].uppercased())
        let range = username.index(after: username.startIndex)...
        let restOfName: String = username.count > 1 ? String(username[range]) : ""
        let name = firstLetter.appending(restOfName)
        
        let newEmployee = Employee(id: 0, name: name, phone: "", email: "\(username)@homebase.com", username: username, managerFlag: false, profileImageString: nil, startDate: Date())
        
        EmployeeRequest(action: "create").saveToDb(obj: newEmployee) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("ERROR: \n\(error)")
                    displayAlert("Error", message: "Could not create new user at this time.", sender: self!)
                case .success(_):
                    self?.newUser = true
                    self?.getAndLoginUser()
                }
            }
        }
    }
    
    //we want a list of all the employees for later in the app (allEmployees),
    //so let's just grab all of them, and then just verify and pick our desired user for currentUser
    //(Yes, I know this is not how we would do it with a real auth system)
    func getAndLoginUser() {
        EmployeeRequest(id: nil, username: nil).fetchEmployees { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("ERROR: \n\(error)")
                    displayAlert("Error", message: "Could not log in at this time. Please try again later or contact support.", sender: self!)
                case .success(let employees):
                    let thisUser = employees.filter { $0.username.lowercased() == self?.usernameTextField.text?.lowercased() }
                    if thisUser.isEmpty {
                        displayAlert("Invalid login", message: "No users registered with that username.", sender: self!)
                    } else {
                        let employee = thisUser[0]
                        allEmployees = employees
                        if self!.newUser {
                            self?.loginUser(user: employee, shifts: [Shift]())
                        } else {
                            self?.getUsersShifts(employee: employee)
                        }
                    }
                }
            }
        }
    }
    
    //get all the users shifts for later in the app (currentUserShifts)
    func getUsersShifts(employee: Employee) {
        let shiftRequest = ShiftRequest(id: nil, employee: employee.id, date: nil, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("ERROR: \n\(error)")
                    displayAlert("Error", message: "Could not load all user data. Please try again later or contact support.", sender: self!)
                case .success(let shifts):
                    self?.loginUser(user: employee, shifts: shifts)
                }
            }
        }
    }
    
    func loginUser(user: Employee, shifts: [Shift]) {
        endLoadingView()
        currentUser = user
        currentUserShifts = shifts
        makeNewRootController(vcId: "TabBarViewController", fromController: self)
    }
}
