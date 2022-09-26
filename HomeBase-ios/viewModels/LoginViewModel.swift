//
//  ShiftViewModel.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 9/25/22.
//

import Foundation

class LoginViewModel: ViewModel {
    
    var login: (() -> Void)?
    
    func createNewUser(user: Employee) {
        EmployeeRequest(action: "create").saveToDb(obj: user) { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not create new user at this time.\n\(error)")
            case .success(_):
                self?.loginUser(username: user.username, newUser: true)
            }
        }
    }
    
    //we want a list of all the employees for later in the app (allEmployees),
    //so let's just grab all of them, and then just verify and pick our desired user for currentUser
    //(Yes, I know this is not how we would do it with a real auth system)
    func loginUser(username: String, newUser: Bool) {
        EmployeeRequest(id: nil, username: nil).fetchEmployees { [weak self] result in
            switch result {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not log in at this time.\n\(error)")
            case .success(let employees):
                let thisUser = employees.filter { $0.username.lowercased() == username.lowercased() }
                if thisUser.isEmpty {
                    self?.errorMessage = DisplayError(title: "Invalid login", message: "No users registered with that username.")
                } else {
                    let employee = thisUser[0]
                    allEmployees = employees
                    if newUser {
                        currentUser = employee
                        currentUserShifts = [Shift]()
                        self?.login?()
                    } else {
                        self?.getUsersShifts(employee: employee)
                    }
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
                currentUser = employee
                currentUserShifts = shifts
                self?.login?()
            }
        }
    }
}
