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
    
    var loginViewModel : LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViewModel()
    }
    
    func initViewModel() {
        loginViewModel = LoginViewModel()
        loginViewModel.displayError = { (title, message) in
            DispatchQueue.main.async {
                displayAlert(title, message: message, sender: self)
            }
        }
        loginViewModel.login = {
            DispatchQueue.main.async {
                endLoadingView()
                makeNewRootController(vcId: "TabBarViewController", fromController: self)
            }
        }
    }
    
    @IBAction func signInAction(_ sender: Any) {
        if usernameTextField.text!.count <= 0 { return }
        
        startLoadingView(controller: self)
        //allow for shortcut for making new users from app
        if passwordTextField.text?.lowercased() == "admin" {
            createAndLoginUser()
        } else {
            loginViewModel.loginUser(username: self.usernameTextField.text!, newUser: false)
        }
    }
    
    func createAndLoginUser() {
        let username = usernameTextField.text!.lowercased()
        let firstLetter: String = (username[username.startIndex].uppercased())
        let range = username.index(after: username.startIndex)...
        let restOfName: String = username.count > 1 ? String(username[range]) : ""
        let name = firstLetter.appending(restOfName)
        
        let newEmployee = Employee(id: 0, name: name, phone: "", email: "\(username)@homebase.com", username: username, managerFlag: false, profileImageString: nil, startDate: Date())
        
        loginViewModel.createNewUser(user: newEmployee)
    }
}
