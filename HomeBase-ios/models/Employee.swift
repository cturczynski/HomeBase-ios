//
//  Employee.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

public var currentUser: Employee?

struct EmployeeResult: Decodable {
    var employees: [Employee]
}

public struct Employee: Decodable {
    var id: Int
    var name: String
    var phone: String
    var email: String
    var managerFlag: Bool
    var profileImageString: String?
    var startDate: Date
}
