import XCTest

import dotTests

var tests = [XCTestCaseEntry]()
tests += dotTests.allTests()
XCTMain(tests)