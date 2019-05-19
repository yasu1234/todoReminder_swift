//
//  TaskListViewUITests.swift
//  todoReminderUITests
//
//

import XCTest

class TaskListViewControllerUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // セルをタップして、画面遷移するかの確認
    func testCellTap() {
        let app = XCUIApplication()
        
        let cell = app.cells.matching(.cell, identifier: "cell").element(boundBy: 0)
        
        cell.tap()
        
        // 画面遷移して、セルが存在しないこと
        expectation(for: NSPredicate(format: "exists ==false"), evaluatedWith: cell, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    // 登録ボタンを押下して、画面遷移するかの確認
    func testRegisterButtonTap() {
        let app = XCUIApplication()
        let cell = app.cells.matching(.cell, identifier: "cell").element(boundBy: 0)
        
        app.buttons["registerButton"].tap()

        // 画面遷移して、セルが存在しないこと
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: cell, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

}
