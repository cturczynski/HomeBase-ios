//
//  Shift.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

struct ShiftResult: Decodable {
    var shifts: [Shift]
}

struct Shift: Decodable {
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
