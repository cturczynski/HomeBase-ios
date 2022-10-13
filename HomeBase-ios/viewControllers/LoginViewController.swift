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
    @IBOutlet weak var createUserLabel: UILabel!
    
    var loginViewModel : LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUserLabel.adjustsFontSizeToFitWidth = true
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
        if let username = usernameTextField.text, let password = passwordTextField.text {
            if username.count <= 0 || password.count <= 0 { return }
            
            startLoadingView(controller: self)
            loginViewModel.loginUser(username: username, password: password, newUser: false)
        } else {
            displayAlert("Entry error", message: "Please fill in both fields", sender: self)
        }
    }
    
    @IBAction func joinAction(_ sender: Any) {
        if let username = usernameTextField.text, let password = passwordTextField.text {
            if username.count <= 0 || password.count <= 0 { return }
    
            startLoadingView(controller: self)
            createAndLoginUser(username: username, password: password)
        } else {
            displayAlert("Entry error", message: "Please fill in both fields", sender: self)
        }
    }
    
    func createAndLoginUser(username: String, password: String) {
        let username = username.lowercased()
        let firstLetter: String = (username[username.startIndex].uppercased())
        let range = username.index(after: username.startIndex)...
        let restOfName: String = username.count > 1 ? String(username[range]) : ""
        let name = firstLetter.appending(restOfName)
        
        let newEmployee = Employee(id: 0, name: name, phone: "", email: "\(username)@homebase.com", username: username, managerFlag: false, profileImageString: nil, startDate: Date())
        
        loginViewModel.createNewUser(user: newEmployee, password: password)
    }
}
