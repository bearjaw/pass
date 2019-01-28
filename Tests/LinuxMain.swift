import XCTest

import passTests

var tests = [XCTestCaseEntry]()
tests += passTests.allTests()
XCTMain(tests)
