//
//  ViewModel.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 9/25/22.
//

import Foundation

public struct DisplayError {
    var title: String
    var message: String
}

class ViewModel: NSObject {
    var displayError: ((String, String) -> Void)?
    var displayToast: ((String) -> Void)?
    var finishedLoading: (() -> Void)?
    
    var errorMessage: DisplayError? {
        didSet {
            self.finishedLoading?()
            self.displayError?((self.errorMessage?.title)!, (self.errorMessage?.message)!)
        }
    }
    var successMessage: String? {
        didSet {
            self.displayToast?(self.successMessage!)
        }
    }
    
    override init() {
        super.init()
        self.finishedLoading = {
            DispatchQueue.main.async {
                endLoadingView()
            }
        }
    }
}
