//
//  Employee.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

struct EmployeeResult: Decodable {
    var employees: [Employee]
}

struct Employee: Decodable {
    var id: Int
    var name: String
    var phone: String
    var email: String
    var managerFlag: Bool
    var profileImageString: String?
    var startDate: Date
}
