//
//  Employee.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

public var currentUser: Employee?

struct EmployeeResult: Codable {
    var error: String?
    var employees: [Employee]?
}

public struct Employee: Codable {
    var id: Int
    var name: String
    var phone: String
    var email: String
    var username: String
    var managerFlag: Bool
    var profileImageString: String?
    var startDate: Date
}
