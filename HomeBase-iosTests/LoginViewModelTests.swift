//
//  LoginViewModelTests.swift
//  HomeBase-iosTests
//
//  Created by Casey Turczynski on 9/25/22.
//

import XCTest
@testable import HomeBase_ios

final class LoginViewModelTests: XCTestCase {
    
    var sut : LoginViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = LoginViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogin() {
        sut.login = {
            XCTAssert(self.sut.employees?.count ?? 0 > 0, "All employees not returned correctly")
            XCTAssert(self.sut.shifts?.count ?? 0 > 0, "Employee shifts not returned correctly")
            XCTAssert(self.sut.user?.username == "casey", "User not returned correctly")
        }
        sut.loginUser(username: "casey", newUser: false)
    }

}
