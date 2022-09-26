//
//  YourTipsViewModelTests.swift
//  HomeBase-iosTests
//
//  Created by Casey Turczynski on 9/25/22.
//

import XCTest
@testable import HomeBase_ios

final class YourTipsViewModelTests: XCTestCase {

    var sut : YourTipsViewModel!
    var shift1 : Shift!
    var shift2 : Shift!
    var shift3 : Shift!
    var now : Date? = Date()
    var yesterday : Date?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = YourTipsViewModel()
        let earlier = Calendar.current.date(byAdding: .hour, value: -5, to: now!)
        let earliest = Calendar.current.date(byAdding: .hour, value: -10, to: now!)
        yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now!)
        shift1 = Shift(id: 0, date: now!, employeeId: 1, position: .barback, start: now!, end: now!, clockIn: earliest, clockOut: earlier, tips: 1000.0)
        shift2 = Shift(id: 1, date: now!, employeeId: 1, position: .bartender, start: now!, end: now!, clockIn: earlier, clockOut: now, tips: 1000.0)
        shift3 = Shift(id: 2, date: yesterday!, employeeId: 1, position: .bartender, start: yesterday!, end: yesterday!, clockIn: yesterday!, clockOut: earliest!, tips: 1000.0)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        shift1 = nil
        shift2 = nil
        shift3 = nil
        now = nil
        yesterday = nil
        try super.tearDownWithError()
    }
    
    func testSortAndCumulateShifts() {
        sut.sortAndCumulateShifts(shifts: [shift2, shift1, shift3])
        XCTAssert(sut.cumulatedShifts?[0].tips == 2000.0, "Shifts not ordered or cumulated correctly")
        XCTAssert(sut.shiftsDict?[yesterday!]?.count == 1, "Shifts not sorted correctly")
        XCTAssert(sut.shiftsDict?[now!]?.count == 2, "Shifts not sorted correctly")
    }

}
