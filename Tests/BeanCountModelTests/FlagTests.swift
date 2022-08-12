//
//  FlagTests.swift
//  
//
//  Created by Liu Wei on 8/12/22.
//

@testable import BeanCountModel
import XCTest

class FlagTests: XCTestCase {

    func testDescription() {
            let complete = Flag.complete
            XCTAssertEqual(String(describing: complete), "*")
            let incomplete = Flag.incomplete
            XCTAssertEqual(String(describing: incomplete), "!")
        }

}
