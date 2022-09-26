//
//  EmployeeViewModel.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 9/25/22.
//

import Foundation

class ProfileViewModel: ViewModel {
    
    var saveNewImage: (() -> Void)?
    
    func saveNewUserImage(user: Employee) {
        EmployeeRequest.init(action: "update").saveToDb(obj: user) { [weak self] result in
            switch(result) {
            case .failure(let error):
                print("ERROR: \n\(error)")
                self?.errorMessage = DisplayError(title: "Error", message: "Could not save profile image at this time.\n\(error)")
            case .success( _):
                currentUser = user
                self?.saveNewImage?()
                self?.finishedLoading?()
                self?.successMessage = "Profile image saved."
            }
        }
    }
    
}
