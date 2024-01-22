//
//  SheduletyTests.swift
//  SheduletyTests
//
//  Created by Мельник Дмитрий on 21.01.2024.
//

import XCTest
@testable import Shedulety

final class SheduletyTests: XCTestCase {

    var calendarService: CalendarService!

    override func setUp() {
        super.setUp()
        calendarService = CalendarService()
    }
    override func tearDown() {
        calendarService = nil
        super.tearDown()
    }

    func testSaveTaskToRealm() {
        let taskObject = TaskObject()
        taskObject.name = "text"
        taskObject.descriptionTask = "description"
        taskObject.dateStart = Date()
        taskObject.dateFinish = Date()
        // Set up the taskObject with necessary data for testing
        calendarService.saveTaskToRealm(taskObject: taskObject)
        let tasks = calendarService.getTasksFromRealm()
        XCTAssertTrue(tasks.contains(taskObject), "Saved task should be in Realm")
    }

    func testParsingFromJsonTasks() {
        calendarService.parsingFromJsonTasks()
        let tasks = calendarService.getTasksFromRealm()
        XCTAssertFalse(tasks.isEmpty, "Tasks should be parsed and saved in the Realm")
    }

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func testExample() throws {

    }

    func testPerformanceExample() throws {
        self.measure {
           
        }
    }

}
