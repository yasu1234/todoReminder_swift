//
//  TaskEditViewTests.swift
//  todoReminderTests
//
//

import XCTest
@testable import todoReminder

class TaskEditViewTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let vc = TaskEditViewController()
    
    func test_stringToDate_001() {
        let date = vc.dateFormat(stringDate: "2019/05/11 13:55")!
        XCTAssertEqual(date.description, "2019-05-11 04:55:00 +0000")
    }
    
    func test_stringToDate_002() {
        XCTAssertNil(vc.dateFormat(stringDate: "2019/05/11"))
    }
    
    func test_stringToDate_003() {
        let date = vc.dateFormat(stringDate: "2019/05/11 11:00")!
        XCTAssertEqual(date.description, "2019-05-11 02:00:00 +0000")
    }
    
    func test_stringToDate_004() {
        XCTAssertNil(vc.dateFormat(stringDate: "2019/05"))
    }

}
