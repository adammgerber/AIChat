//
//  AIChatCourseUITests2.swift
//  AIChatCourseUITests2
//
//  Created by Adam Gerber on 25/04/2026.
//

import XCTest

@MainActor
final class AIChatCourseUITests2: XCTestCase {

    override func setUpWithError() throws {
   
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {

    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"] /*"SIGNED_IN"*/
        app.launch()
    }
}
