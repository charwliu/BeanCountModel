//
//  OptionTests.swift
//  
//
//  Created by Liu Wei on 8/12/22.
//

@testable import BeanCountModel
import XCTest

class OptionTests: XCTestCase {
    
    func testDescription() {
        let option = Option(name: "name", value: "value1")
        XCTAssertEqual(String(describing: option), "option \"name\" \"value1\"")
        
        let optionSpecialCharacters = Option(name: "😂", value: "😀")
        XCTAssertEqual(String(describing: optionSpecialCharacters), "option \"😂\" \"😀\"")
    }
    
    func testComparable() {
        let option1 = Option(name: "name", value: "value1")
        let option2 = Option(name: "name", value: "value1")
        let option3 = Option(name: "name1", value: "value1") // check name
        let option4 = Option(name: "name", value: "value2") // check value
        XCTAssertEqual(option1, option2)
        XCTAssertNotEqual(option1, option3)
        XCTAssertNotEqual(option1, option4)
    }
    
}
