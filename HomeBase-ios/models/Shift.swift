//
//  Shift.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

public var currentUserShifts: [Shift]?

struct ShiftResult: Codable {
    var error: String?
    var shifts: [Shift]?
}

public struct Shift: Codable {
    var id: Int
    var date: Date
    var employeeId: Int
    var position: Position
    var start: Date
    var end: Date
    var clockIn: Date?
    var clockOut: Date?
    var tips: Double?
    var totalTips: Double?
}

struct IndividualShift {
    var date: Date
    var clockTime: Date
    var clockDirection: String
    var totalShiftTime: String
}
