//
//  HomeBase_iosApiTests.swift
//  HomeBase-iosApiTests
//
//  Created by Casey Turczynski on 9/25/22.
//

import XCTest
@testable import HomeBase_ios

final class HomeBase_iosApiTests: XCTestCase {
    
    var emp1 : EmployeeRequest!
    var emp2 : EmployeeRequest!
    var shift1 : ShiftRequest!
    var shift2 : ShiftRequest!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        emp1 = EmployeeRequest(id: nil, username: nil)
        emp2 = EmployeeRequest(id: 1, username: "casey")
        shift1 = ShiftRequest(id: nil, employee: nil, date: nil, start: nil, end: nil)
        let today = Date()
        let date = createDateFormatter(withFormat: "yyyy-MM-dd").string(from: today)
        shift2 = ShiftRequest(id: 1, employee: 2, date: today, start: today, end: today)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        emp1 = nil
        emp2 = nil
        shift1 = nil
        shift2 = nil
        try super.tearDownWithError()
    }

    func testFetchAllEmployees() throws {
        var employees : [Employee]?
        var requestError : ApiRequestError?
        let promise = XCTestExpectation(description: "Checking for no error")
        
        emp1.fetchEmployees { result in
            switch (result) {
            case .failure(let error):
                requestError = error
                employees = nil
            case .success(let emps):
                employees = emps
                requestError = nil
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssert(requestError == nil, "Request error not nil")
        XCTAssert(employees != nil, "Employees result is nil")
    }
    
    func testFetchSpecificEmployees() throws {
        var employees : [Employee]?
        var requestError : ApiRequestError?
        let promise = XCTestExpectation(description: "Checking for no error")
        
        emp2.fetchEmployees { result in
            switch (result) {
            case .failure(let error):
                requestError = error
                employees = nil
            case .success(let emps):
                employees = emps
                requestError = nil
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssert(requestError == nil, "Request error not nil")
        XCTAssert(employees != nil, "Employees result is nil")
    }
    
    func testFetchAllShifts() {
        var shifts : [Shift]?
        var requestError : ApiRequestError?
        let promise = XCTestExpectation(description: "Checking for no error")
        
        shift1.fetchShifts { result in
            switch (result) {
            case .failure(let error):
                requestError = error
                shifts = nil
            case .success(let shiftRes):
                shifts = shiftRes
                requestError = nil
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssert(requestError == nil, "Request error not nil")
        XCTAssert(shifts != nil, "Shifts result is nil")
    }
    
    func testFetchSpecificShifts() {
        var shifts : [Shift]?
        var requestError : ApiRequestError?
        let promise = XCTestExpectation(description: "Checking for no error")
        
        shift2.fetchShifts { result in
            switch (result) {
            case .failure(let error):
                requestError = error
                shifts = nil
            case .success(let shiftRes):
                shifts = shiftRes
                requestError = nil
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssert(requestError == nil, "Request error not nil")
        XCTAssert(shifts != nil, "Shifts result is nil")
    }

}
