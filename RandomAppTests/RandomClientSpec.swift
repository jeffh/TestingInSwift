// An example of tests without UI code. As with all tests, you want to keep
// it repeatable. Here we use a fake http client to ensure our test does not
// run out to the network to make a connection.
//
// For HTTP, it is possible to use a third-party library:
//  - Nocilla: https://github.com/luisobo/Nocilla
//  - OHHTTPStubs: https://github.com/AliSoftware/OHHTTPStubs
//
// They're useful since they ensure no accidental network requests escape by
// stubbing/swizzling system API calls. But stubbing external APIs are not
// widely regarded as best practices:
//
//  http://www.davesquared.net/2011/04/dont-mock-types-you-dont-own.html
//
// The technique shown here follows more of hexagonal architecture style (or
// Domain-Driven Design, or Functional Core-Imperative Shell), by using a
// protocol for any external interactions / side effects.
//
// This technique can be used for more than just HTTP requests (eg - logging),
// and allows you to easily swap implementations as needed. It also creates a
// convenient way to insert a fake to test behaviors of your domain.
//
// This leads to interesting ideas beyond this discussion:
//
//  - UI has side effects / is external and should be treated like an adapter.
//  - Data persistence (eg - Core Data) is also external and should be an
//    adapter.
//
// Both are logical conclusions if you strictly follow hexagonal architecture,
// Domain-Driven Design, Functional Core-Imperative Shell.
//
// This file uses custom matchers found in the Support/Matchers folder

import RandomApp
import Quick
import Nimble

class RandomClientSpec: QuickSpec {
    override func spec() {
        describe("RandomClient") {
            var client: RandomClient!
            var fakeHTTPClient: FakeHTTPClient!

            beforeEach {
                fakeHTTPClient = FakeHTTPClient()
                client = RandomClient(httpClient: fakeHTTPClient, apiKey: "my-api-key")
            }

            describe("requesting a random number between 0 and 100") {
                var number: Int?
                var error: NSError?
                var lastRequest: RecordedRequest!
                // pre-defining a closure since it's used throughout this
                // test group.
                var captureValues: (Int?, NSError?) -> Void = { n, err in
                    number = n
                    error = err
                }

                beforeEach {
                    client.randomInteger(captureValues)

                    lastRequest = fakeHTTPClient.recordedRequests.last!
                }

                it("should make a batched HTTP request for 10 numbers") {
                    expect(lastRequest.request.URL?.absoluteString).to(equal("https://api.random.org/json-rpc/1/invoke"))
                    expect(lastRequest.request.URL).to(equalURLString("https://api.random.org/json-rpc/1/invoke"))
                    expect(lastRequest.request).to(haveJSONBody([
                        "jsonrpc": "2.0",
                        "method": "generateIntegers",
                        "params": [
                            "apiKey": "my-api-key",
                            "n": 10,
                            "min": 0,
                            "max": 100
                        ],
                        "id": 1,
                        ]))
                }

                context("when the request succeeds") {
                    beforeEach {
                        lastRequest.resolve(200,
                            JSONData: randomNumberResponse([3, 7, 3, 7, 7, 6, 9, 4, 1, 8]))
                    }

                    it("should return the first number with no errors") {
                        expect(number).to(equal(3))
                        expect(error).to(beNil())
                    }

                    describe("repeated calls while there are still numbers remaining") {
                        it("should return subsequent numbers without making requests") {
                            fakeHTTPClient.clearRecordedRequests()

                            client.randomInteger(captureValues)

                            expect(number).to(equal(7))
                            expect(error).to(beNil())

                            client.randomInteger(captureValues)

                            expect(number).to(equal(3))
                            expect(error).to(beNil())

                            expect(fakeHTTPClient.recordedRequests).to(beEmpty())
                        }
                    }
                }

                context("when the request fails") {
                    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)

                    beforeEach {
                        lastRequest.reject(error)
                    }

                    it("should return the error with no number") {
                        expect(number).to(beNil())
                        expect(error).to(equal(error))
                    }
                }
            }
        }
    }
}
