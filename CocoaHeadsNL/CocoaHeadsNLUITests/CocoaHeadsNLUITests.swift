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

        app.tables.cells.element(boundBy: 0).tap()
        snapshot("02Meetup-details")

        app.tabBars.buttons["Jobs"].tap()
        waitForNotHittable(app.activityIndicators.element(boundBy: 0), waitSeconds: 10)
        snapshot("03Jobs")

        app.tabBars.buttons["About"].tap()
        waitForNotHittable(app.activityIndicators.element(boundBy: 0), waitSeconds: 10)
        snapshot("04About")
    }

}

extension XCTestCase {
    func waitForHittable(_ element: XCUIElement, waitSeconds: Double, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "hittable == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)

        waitForExpectations(timeout: waitSeconds) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(waitSeconds) seconds."
                self.recordFailure(withDescription: message,
                                                  inFile: file, atLine: Int(line), expected: true)
            }
        }
    }

    func waitForNotHittable(_ element: XCUIElement, waitSeconds: Double, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "hittable == false")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)

        waitForExpectations(timeout: waitSeconds) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(waitSeconds) seconds."
                self.recordFailure(withDescription: message,
                                                  inFile: file, atLine: Int(line), expected: true)
            }
        }
    }

    func waitForExists(_ element: XCUIElement, waitSeconds: Double, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)

        waitForExpectations(timeout: waitSeconds) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(waitSeconds) seconds."
                self.recordFailure(withDescription: message,
                                                  inFile: file, atLine: Int(line), expected: true)
            }
        }
    }
}
