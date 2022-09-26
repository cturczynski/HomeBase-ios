//
//  TipSheetViewModelTests.swift
//  HomeBase-iosTests
//
//  Created by Casey Turczynski on 9/25/22.
//

import XCTest
@testable import HomeBase_ios

final class TipSheetViewModelTests: XCTestCase {

    var sut : TipSheetViewModel!
    var shift1 : Shift!
    var shift2 : Shift!
    var now : Date? = Date()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = TipSheetViewModel()
        let earlier = Calendar.current.date(byAdding: .hour, value: -5, to: now!)
        let earliest = Calendar.current.date(byAdding: .hour, value: -10, to: now!)
        shift1 = Shift(id: 0, date: Date(), employeeId: 1, position: .barback, start: Date(), end: Date(), clockIn: earliest, clockOut: earlier, tips: 1000.0)
        shift2 = Shift(id: 1, date: Date(), employeeId: 1, position: .bartender, start: Date(), end: Date(), clockIn: earlier, clockOut: now, tips: 1000.0)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        shift1 = nil
        shift2 = nil
        now = nil
        try super.tearDownWithError()
    }
    
    func testSortShifts() {
        sut.sortShifts(shifts: [shift2, shift1])
        XCTAssert(sut.displayShifts?[0].id == 0)
    }
    
    func testChangeDate() {
        sut.tipSheetDate = now
        sut.changeDateAndRefresh(byDays: 1)
        XCTAssert(sut.tipSheetDate! > now!, "Change date func not working")
    }

}
