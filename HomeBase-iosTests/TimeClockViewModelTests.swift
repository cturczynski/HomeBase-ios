//
//  TimeClockViewModelTests.swift
//  HomeBase-iosTests
//
//  Created by Casey Turczynski on 9/25/22.
//

import XCTest
@testable import HomeBase_ios

final class TimeClockViewModelTests: XCTestCase {
    
    var sut : TimeClockViewModel!
    var shift1 : Shift!
    var shift2 : Shift!
    var now : Date? = Date()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = TimeClockViewModel()
        let earlier = Calendar.current.date(byAdding: .hour, value: -5, to: now!)
        let earliest = Calendar.current.date(byAdding: .hour, value: -10, to: now!)
        shift1 = Shift(id: 0, date: Date(), employeeId: 1, position: .barback, start: Date(), end: Date(), clockIn: earliest, clockOut: earlier)
        shift2 = Shift(id: 1, date: Date(), employeeId: 1, position: .bartender, start: Date(), end: Date(), clockIn: now)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        shift1 = nil
        shift2 = nil
        now = nil
        try super.tearDownWithError()
    }

    func testGetShifts() {
        sut.getShifts(userShifts: [shift1, shift2])
        XCTAssert(sut.timeclockShifts?[0].clockTime == now, "getShifts function not populating timeclockShifts correctly")
    }
    
    func testGetTodaysShifts() {
        sut.getTodaysShift(userShifts: [shift1, shift2])
        XCTAssert(sut.clockButtonText == "Clock Out", "getTodaysShifts not populating/sorting correctly")
    }

}
