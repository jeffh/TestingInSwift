// Generative Testing.
// This is a simple data-generation of tests cases. If you're not familiar with
// traditional test writing, writing generative tests will be more difficult.
//
// Generative tests use the testing library's data generation mechanisms to
// create random input data to verify the code under test.
//
// This constraints what you can test on, but allows an easy lever to scale
// test cases on a variety of inputs.
//
// A common problem to generative testing is writing the tests themselves.
// Generative tests usually fall into one of the following styles:
//
//  - Test against some relationship between the inputs and outputs.
//    (eg - concat preserves the total number of elements in arrays involved)
//  - Test using another implementation. The goal of your implementation is
//    to be more performant in some way. (eg - Use an array to test a linked
//    list)
//  - Test a collection of code that have a round-trip property.
//    (eg - test encode / decode together).
//
// Generative testing works well if you have two ways of computing the same
// result and want to verify that both implementations match in behavior.
//
// They do not replace traditional unit tests.

import XCTest
import Fox

func customSort<T: Comparable>(array: [T]) -> [T] {
    var items = sorted(array)
    // uncomment for nefarious sort:
//    if items.count == 3 {
//        let t = items[0]
//        items[0] = items[2]
//        items[2] = t
//    }
    return items
}

class SortingGenerativeTest: XCTestCase {
    func testRandomSorts() {
        Assert(forAll(array(positiveInteger())) { numbers in
            var nums = customSort(numbers as! [Int])

            var n = 0
            for i in 0..<nums.count {
                if n > nums[i] {
                    return false
                }
                n = nums[i]
            }
            return true
        })
    }
}
