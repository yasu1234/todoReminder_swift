//
//  TaskEditViewUITests.swift
//  todoReminderUITests
//
//

import XCTest

class TaskEditViewUITests: XCTestCase {

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
    
    // 新規登録の際に削除ボタンが表示されていないことの確認
    func testDeleteButtonNonExist() {
        let app = XCUIApplication()
        app.buttons["registerButton"].tap()
        let deleteButton = app.buttons["deleteButton"]
        XCTAssertFalse(deleteButton.exists)
    }
    
    // 更新の際に削除ボタンが表示されていることの確認
    func testDeleteButtonExist() {
        let app = XCUIApplication()
        let cell = app.cells.matching(.cell, identifier: "cell").element(boundBy: 0)
        cell.tap()
        
        let deleteButton = app.buttons["deleteButton"]
        XCTAssertTrue(deleteButton.exists)
    }
    
    // 必須項目が入力されていないとアラートが表示されることの確認
    func testRegisterValidation001() {
        let app = XCUIApplication()
        app.buttons["registerButton"].tap()
        
        app.buttons["registButton"].tap()
        let alert = app.alerts["タスク名とタスク期限は必須です"]
        XCTAssertTrue(alert.exists)
    }
    
    // 今より前の時間の場合、アラートが表示されることの確認
    func testRegisterValidation002() {
        let app = XCUIApplication()
        app.buttons["registerButton"].tap()
        app.textFields["taskNameInput"].tap()
        app.textFields["taskNameInput"].typeText("テスト")
        app.textFields["taskLimitInput"].tap()

        app.buttons["Done"].tap()
        
        app.buttons["registButton"].tap()
        let alert = app.alerts["現在より少なくとも1分後を指定して下さい"]
        XCTAssertTrue(alert.exists)
    }
    
    // 登録できたら一覧に遷移し、セルが増えていることの確認
    func testRegister() {
        let app = XCUIApplication()
        app.buttons["registerButton"].tap()
        app.textFields["taskNameInput"].tap()
        app.textFields["taskNameInput"].typeText("テスト")
        app.textFields["taskLimitInput"].tap()
        let datePickers = XCUIApplication().datePickers
        datePickers.pickerWheels.element(boundBy: 1).tap()
        datePickers.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "23")
        datePickers.pickerWheels.element(boundBy: 1).tap()
        datePickers.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "59")
        
        app.buttons["Done"].tap()
        
        app.buttons["registButton"].tap()
        let cell = app.cells.matching(.cell, identifier: "cell").element(boundBy: 1)
        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: cell, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
    }

}
