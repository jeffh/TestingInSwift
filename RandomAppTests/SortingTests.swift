// This file just shows how XCTestCases and Quick Specs differ in style.
// They are translatable to each other if needed. Quick allows nested
// setups to allow drilling through to a specific case while covering
// other related assertions between the setups.
//
// In the end, they're all personal preference. Some choose XCTest because
// it's built-in and easy to get started. Others choose Quick/Nimble because
// it encourages writing tests in a proper style (behaviors instead of
// testing implementation details while communicating specifications).
//
// If you're relatively new to testing. Here's some constraints that are good
// to follow until you're comfortable to know when you can break them:
//
//  - One assertion per test case.
//  - Test cases should describe an example of a code path that can occur.
//  - Don't test private code. Testing via public APIs only whenever possible.
//  - Avoid stubbing and mocking code as much as possible. A stub-heavy
//    test suite tightly couples to production code's implementation more.
//  - Have a failing test for each regression / bug before fixing it.
//  - Avoid checking types as an assertion. They are indirect / lazy ways to
//    verifying behavior. I've personally made the choice that transitions
//    between controllers are the seams where I do this, and accept the less
//    thorough coverage in the test suite.
//  - Avoid test-specific code in production.

import XCTest
import Quick
import Nimble

class TestSort : XCTestCase {
    var values: [Int] = []

    // Shared setup goes here
    override func setUp() {
        values = [2, 5, 3]
    }

    // Test case. XCTest will run methods starting with 'test'
    // There are several styles better than this for naming
    // test methods.
    //
    // - "merge" all the parent describes and contexts into the it for what
    //   would normally be a BDD-styled test.
    // - testWhen<stateOfWorld>Then<desiredBehavior>
    // - test<UnitOfWork>_<StateUnderTest>_<ExpectedBehavior>
    func testReorderingOfSmallerIntegersFirst() {
        // Performing an action
        sort(&values)

        // Assertion
        XCTAssertEqual(values, [2, 3, 5],
            "Expected \(values) to equal [2, 3, 5]")
    }
}

class SortSpec : QuickSpec {
    override func spec() {
        describe("sorting integers") {
            var values: [Int] = []

            // Shared setup goes here. beforeEach is associated to
            // each describe or context it's placed within.
            //
            // The ordering of execution is outside-in for beforeEaches.
            beforeEach {
                values = [2, 5, 3]

                // Performing the action to test against.
                // Some developers prefer to move this to the first
                // line in an 'it' closure.
                sort(&values)
            }

            // test case - aka "an example"
            it("reorders smaller integers first in the array") {
                // assertions
                expect(values).to(equal([2, 3, 5]))
            }
        }
    }
}