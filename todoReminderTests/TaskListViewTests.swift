//
//  TaskListViewTests.swift
//  todoReminderTests
//
//

import XCTest
@testable import todoReminder

class TaskListViewTests: XCTestCase {
    
    override func setUp() {
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let vc = TaskListViewController()
    
    func test_sreingDate_001() {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2019, month: 5, day: 11, hour: 13, minute: 15))!
        XCTAssertEqual(vc.stringFromDate(date: date, format: "yyyy/MM/dd HH:mm"), "2019/05/11 13:15")
    }
    
    func test_sreingDate_002() {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2019, month: 5, day: 11, hour: 13, minute: 00))!
        XCTAssertEqual(vc.stringFromDate(date: date, format: "yyyy/MM/dd HH:mm"), "2019/05/11 13:00")
    }
    
    func test_sreingDate_003() {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2019, month: 5, day: 11, hour: 13))!
        XCTAssertEqual(vc.stringFromDate(date: date, format: "yyyy/MM/dd HH:mm"), "2019/05/11 13:00")
    }
    
    func test_sreingDate_004() {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2019, month: 5, day: 11, hour: 13))!
        XCTAssertEqual(vc.stringFromDate(date: date, format: "yyyy/MM/dd"), "2019/05/11")
    }

}
