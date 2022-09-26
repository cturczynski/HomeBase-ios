//
//  HomeBase_iosTests.swift
//  HomeBase-iosTests
//
//  Created by Casey Turczynski on 6/14/22.
//

import XCTest
@testable import HomeBase_ios

class HomeBase_iosTests: XCTestCase {

    var dateFormatter: DateFormatter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        dateFormatter = createDateFormatter(withFormat: "yyyy-MM-dd")

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }
    
    func testEmployeeRequestInit() {
        let req = EmployeeRequest(id: 1, username: "casey")
        XCTAssert(req.requestURL.absoluteString == "https://homebase-ct.herokuapp.com/employee?id=1&username=casey", "URL string not formed correctly")
        
        let req2 = EmployeeRequest(id: nil, username: nil)
        XCTAssert(req2.requestURL.absoluteString == "https://homebase-ct.herokuapp.com/employee/all", "URL string not formed correctly")
        
        let req3 = EmployeeRequest(action: "create")
        XCTAssert(req3.requestURL.absoluteString == "https://homebase-ct.herokuapp.com/employee/create", "URL string not formed correctly")
    }
    
    func testShiftRequestInit() {
        let today = Date()
        let date = dateFormatter.string(from: today)
        let req = ShiftRequest(id: 1, employee: 2, date: today, start: today, end: today)
        XCTAssert(req.requestURL.absoluteString == "https://homebase-ct.herokuapp.com/shift?id=1&employee=2&date='\(date)'&start='\(date)'&end='\(date)'", "URL string not formed correctly")
        
        let req2 = ShiftRequest(id: nil, employee: nil, date: nil, start: nil, end: nil)
        XCTAssert(req2.requestURL.absoluteString == "https://homebase-ct.herokuapp.com/shift/all", "URL string not formed correctly")
        
        let req3 = ShiftRequest(action: "update")
        XCTAssert(req3.requestURL.absoluteString == "https://homebase-ct.herokuapp.com/shift/update", "URL string not formed correctly")
    }
    
    func testPhoneNumberFormatter() {
        let str = formatPhoneNumber(phone: "1234567890")
        XCTAssert(str == "(123) 456-7890", "Phone formatter not working")
    }

}
