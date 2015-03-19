// A full controller test. If you're new to testing, check out
// SortingTests.swift.
//
// This uses UIKit methods to verify behaviors that the controller should be
// handling. Th

import RandomApp
import Quick
import Nimble

class ListViewControllerSpec: QuickSpec {
    override func setUp() {
        // When a failure occurs for an example, throw an exception
        // to bail out of execution instead of continuing to run.
        //
        // Setting this to false makes this group of tests behave more like
        // other testing frameworks (jUnit, rspec, etc.)
        continueAfterFailure = false
    }

    override func spec() {
        describe("Viewing the list of numbers") {
            var subject: ListViewController!
            var randomClient: RandomClient!
            var fakeHTTPClient: FakeHTTPClient!
            var navigationController: UINavigationController!

            beforeEach {
                fakeHTTPClient = FakeHTTPClient()
                randomClient = RandomClient(httpClient: fakeHTTPClient, apiKey: "my-api-key")

                subject = ListViewController(client: randomClient)
                subject.beginAppearanceTransition(true, animated: false)
                subject.endAppearanceTransition()

                navigationController = UINavigationController(rootViewController: subject)
            }

            it("makes a request for random numbers") {
                var lastRequest = fakeHTTPClient.recordedRequests[0]
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

            it("shows a spinner") {
                expect(subject.navigationItem.titleView).to(beAnInstanceOf(UIActivityIndicatorView))
                var activityView = subject.navigationItem.titleView as! UIActivityIndicatorView

                expect(activityView.isAnimating()).to(beTruthy())
            }

            context("when the numbers are returned from the network") {
                beforeEach {
                    fakeHTTPClient.recordedRequests[0].resolve(200, JSONData: randomNumberResponse([1, 2, 3]))
                }

                it("hides the spinner") {
                    expect(subject.navigationItem.titleView).to(beNil())
                }

                it("should display the first number to the user") {
                    expect(subject.tableView.numberOfSections()).to(equal(1))
                    expect(subject.tableView.numberOfRowsInSection(0)).to(equal(1))

                    var cell = cellAt(subject.tableView, row: 0)
                    expect(cell.textLabel!.text).to(equal("1"))
                }

                describe("tapping on the roll button") {
                    beforeEach {
                        tap(subject.navigationItem.rightBarButtonItem!)
                    }

                    it("should add the next random number to the top of the list") {
                        expect(subject.tableView.numberOfSections()).to(equal(1))
                        expect(subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                        var cell0 = cellAt(subject.tableView, row: 0)
                        expect(cell0.textLabel!.text).to(equal("2"))

                        var cell1 = cellAt(subject.tableView, row: 1)
                        expect(cell1.textLabel!.text).to(equal("1"))
                    }
                }

                describe("tapping on a randomly generated number") {
                    beforeEach {
                        tap(cellAt(subject.tableView, row: 0))
                        // pushing a controller onto the nav stack is async
                        NSRunLoop.mainRunLoop().runUntilDate(NSDate())
                    }
                    
                    it("should push the a detail controller on the navigation stack") {
                        expect(navigationController.visibleViewController).to(beAnInstanceOf(DetailViewController))
                        
                        var pushedController = navigationController.visibleViewController as! DetailViewController
                        expect(pushedController.number).to(equal(1))
                    }
                }
            }
        }
    }
}
