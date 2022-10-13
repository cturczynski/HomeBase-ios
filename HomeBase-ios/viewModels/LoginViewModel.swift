//
//  ShiftViewModel.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 9/25/22.
//

import Foundation

class LoginViewModel: ViewModel {
    
    var authManager = FirebaseAuthManager()
    var login: (() -> Void)?
    var employees : [Employee]? {
        didSet {
            allEmployees = self.employees
        }
    }
    var user : Employee? {
        didSet {
            currentUser = self.user
        }
    }
    var shifts : [Shift]? {
        didSet {
            currentUserShifts = self.shifts
        }
    }
    
    func createNewUser(user: Employee, password: String) {
        authManager.signUp(email: user.email, password: password) { [weak self] errorString in
            if errorString != nil {
                self?.errorMessage = DisplayError(title: "Error", message: errorString!)
            } else {
                EmployeeRequest(action: "create").saveToDb(obj: user) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print("ERROR: \n\(error)")
                        self?.errorMessage = DisplayError(title: "Error", message: "Could not create new user at this time.\n\(error)")
                    case .success(_):
                        self?.getAndSetUsers(userEmail: user.email, newUser: true)
                    }
                }
            }
        }
    }
    
    //we want a list of all the employees for later in the app (allEmployees),
    //so let's just grab all of them, and then just verify and pick our desired user for currentUser
    //(Yes, I know this is not how we would do it with a real auth system)
    func loginUser(username: String, password: String, newUser: Bool) {
        var email = username
        if email.firstIndex(of: "@") == nil {
            email += "@homebase.com"
        }
        authManager.login(email: email, password: password, completion: { [weak self] errorString in
            if errorString != nil {
                self?.errorMessage = DisplayError(title: "Error", message: errorString!)
            } else {
                self?.getAndSetUsers(userEmail: email, newUser: false)
            }
        })
    }
    
    func getAndSetUsers(userEmail: String, newUser: Bool) {
        EmployeeRequest(id: nil, username: nil).fetchEmployees { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not log in at this time.\n\(error)")
            case .success(let employees):
                let thisUser = employees.filter { $0.email.lowercased() == userEmail.lowercased() }
                let employee = thisUser[0]
                self?.employees = employees
                if newUser {
                    self?.user = employee
                    self?.shifts = [Shift]()
                    self?.login?()
                } else {
                    self?.getUsersShifts(employee: employee)
                }
            }
        }
    }
    
    //get all the users shifts for later in the app (currentUserShifts)
    func getUsersShifts(employee: Employee) {
        let shiftRequest = ShiftRequest(id: nil, employee: employee.id, date: nil, start: nil, end: nil)
        shiftRequest.fetchShifts { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not load all user data.\n\(error)")
            case .success(let shifts):
                self?.user = employee
                self?.shifts = shifts
                self?.login?()
            }
        }
    }
}
