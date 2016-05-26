//
//  CocoaHeadsNLUITests.swift
//  CocoaHeadsNLUITests
//
//  Created by Jeroen Leenarts on 25-05-16.
//  Copyright © 2016 Stichting CocoaheadsNL. All rights reserved.
//

import XCTest

class CocoaHeadsNLUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testApp() {
        let app = XCUIApplication()

        waitForHittable(app.tables.staticTexts["Amsterdam 18:00"], waitSeconds: 10)
        snapshot("01Meetups")

        app.tables.cells.elementBoundByIndex(0).tap()
        snapshot("02Meetup-details")

        app.tabBars.buttons["Jobs"].tap()
        waitForNotHittable(app.activityIndicators.elementBoundByIndex(0), waitSeconds: 10)
        snapshot("03Jobs")

        app.tabBars.buttons["Companies"].tap()
        waitForNotHittable(app.activityIndicators.elementBoundByIndex(0), waitSeconds: 10)
        snapshot("04Companies")

        app.tabBars.buttons["About"].tap()
        waitForNotHittable(app.activityIndicators.elementBoundByIndex(0), waitSeconds: 10)
        snapshot("06About")
    }

}

extension XCTestCase {
    func waitForHittable(element: XCUIElement, waitSeconds: Double, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "hittable == true")
        expectationForPredicate(existsPredicate, evaluatedWithObject: element, handler: nil)

        waitForExpectationsWithTimeout(waitSeconds) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(waitSeconds) seconds."
                self.recordFailureWithDescription(message,
                                                  inFile: file, atLine: line, expected: true)
            }
        }
    }

    func waitForNotHittable(element: XCUIElement, waitSeconds: Double, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "hittable == false")
        expectationForPredicate(existsPredicate, evaluatedWithObject: element, handler: nil)

        waitForExpectationsWithTimeout(waitSeconds) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(waitSeconds) seconds."
                self.recordFailureWithDescription(message,
                                                  inFile: file, atLine: line, expected: true)
            }
        }
    }

    func waitForExists(element: XCUIElement, waitSeconds: Double, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectationForPredicate(existsPredicate, evaluatedWithObject: element, handler: nil)

        waitForExpectationsWithTimeout(waitSeconds) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(waitSeconds) seconds."
                self.recordFailureWithDescription(message,
                                                  inFile: file, atLine: line, expected: true)
            }
        }
    }
}
