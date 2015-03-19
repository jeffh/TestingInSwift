// Based on the dicussion in SortingGenerativeTest.swift, this includes a basic
// reimplementation of part of the RandomApp that does not utilize other
// libraries (no UIKit, Foundatino, etc.).
//
//
// AppState is the reimplementation that is UI-independent for the most part.
// AppDriver is an adapter for Fox to interact with the true implementation.
//
// Transitions describe metadata of AppDriver methods for Fox to use.
//
// Having an AppDriver makes it easy to port a failing test case into a
// unit test case.

import Quick
import Nimble
import Fox
import RandomApp
import UIKit


@objc class AppState: NSObject, Printable {
    let visibleNumbers: [Int]
    let precomputedNumbers: [Int]
    let numberOfActiveRequests: UInt

    init(visibleNumbers: [Int], precomputedNumbers: [Int], numberOfActiveRequests: UInt) {
        self.visibleNumbers = visibleNumbers
        self.precomputedNumbers = precomputedNumbers
        self.numberOfActiveRequests = numberOfActiveRequests
    }

    override init() {
        visibleNumbers = []
        precomputedNumbers = []
        numberOfActiveRequests = 1 // App launch causes one request
        super.init()
    }

    func roll() -> AppState {
        if precomputedNumbers.count > 0 {
            return revealNextNumber()
        } else {
            return sendRequest()
        }
    }

    override var description: String {
        return "AppState { numbers: \(visibleNumbers), buffer: \(precomputedNumbers), numActiveReqs: \(numberOfActiveRequests) }"
    }

    func revealNextNumber() -> AppState {
        var newVisibleNumbers = visibleNumbers
        newVisibleNumbers.append(precomputedNumbers[0])
        return AppState(
            visibleNumbers: newVisibleNumbers,
            precomputedNumbers: Array(precomputedNumbers[1..<precomputedNumbers.count]),
            numberOfActiveRequests: numberOfActiveRequests)
    }

    func sendRequest() -> AppState {
        return AppState(
            visibleNumbers: visibleNumbers,
            precomputedNumbers: precomputedNumbers,
            numberOfActiveRequests: numberOfActiveRequests + 1)
    }

    func receivedNumbers(numbers: [Int]) -> AppState {
        return AppState(
            visibleNumbers: visibleNumbers,
            precomputedNumbers: precomputedNumbers + numbers,
            numberOfActiveRequests: numberOfActiveRequests - 1)
    }
}

class AppDriver: NSObject {
    var httpClient: FakeHTTPClient
    var appDelegate: AppDelegate
    var window: UIWindow

    init(window: UIWindow) {
        self.window = window
        self.httpClient = FakeHTTPClient()
        self.appDelegate = AppDelegate(window: window, httpClient: httpClient)
        super.init()
    }

    func setup() {
        window.rootViewController = nil
        var app = UIApplication.sharedApplication()
        appDelegate.application(app, didFinishLaunchingWithOptions: nil)
        window.makeKeyAndVisible()

        var controller = visibleViewController() as! ListViewController
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()
    }

    func isSpinnerVisible() -> Bool {
        return visibleViewController().navigationItem.titleView?.isKindOfClass(UIActivityIndicatorView) == true
    }

    func roll() {
        var controller = visibleViewController() as! ListViewController
        tap(controller.navigationItem.rightBarButtonItem!)
    }

    func resolveRequest(numbers: [Int]) {
        // ideally, it would be better to test resolving random active requests.
        var request = httpClient.recordedRequests.last!
        request.resolve(200, JSONData: [
            "jsonrpc": "2.0",
            "method": "generateIntegers",
            "params": [
                "apiKey": "my-api-key",
                "n": 10,
                "min": 0,
                "max": 100
            ],
            "id": 1,
        ])
    }

    private func visibleViewController() -> UIViewController {
        var navController = window.rootViewController as! UINavigationController
        return navController.visibleViewController
    }
}

@objc class ResolveRequestTransition: NSObject, FOXStateTransition {
    func descriptionWithGeneratedValue(generatedValue: AnyObject!) -> String! {
        return "request was resolved"
    }

    func satisfiesPreConditionForModelState(modelState: AnyObject!) -> Bool {
        let state = modelState as! AppState
        return state.numberOfActiveRequests > 0
    }

    func generator() -> FOXGenerator! {
        return FOXArrayOfSize(FOXInteger(), 10)
    }

    func nextModelStateFromModelState(previousModelState: AnyObject!, generatedValue: AnyObject!) -> AnyObject! {
        let state = previousModelState as! AppState
        return state.receivedNumbers(generatedValue as! [Int])
    }

    func objectReturnedByInvokingSubject(subject: AnyObject!, generatedValue: AnyObject!) -> AnyObject! {
        var driver = subject as! AppDriver
        driver.resolveRequest(generatedValue as! [Int])
        return nil
    }

    func satisfiesPostConditionInModelState(currentModelState: AnyObject!, fromModelState previousModelState: AnyObject!, subject: AnyObject!, generatedValue: AnyObject!, objectReturnedBySubject returnedObject: AnyObject!) -> Bool {
        var state = currentModelState as! AppState
        var driver = subject as! AppDriver
        if state.numberOfActiveRequests > 0 {
            if driver.isSpinnerVisible() {
                return true
            } else {
                println("Spinner isn't visible!")
                return false
            }
        }
        return true
    }
}

class RollTransition: NSObject, FOXStateTransition {
    func descriptionWithGeneratedValue(generatedValue: AnyObject!) -> String! {
        return "tap roll button"
    }

    func nextModelStateFromModelState(previousModelState: AnyObject!, generatedValue: AnyObject!) -> AnyObject! {
        let state = previousModelState as! AppState
        return state.roll()
    }

    func objectReturnedByInvokingSubject(subject: AnyObject!, generatedValue: AnyObject!) -> AnyObject! {
        var driver = subject as! AppDriver
        driver.roll()
        return nil
    }

    func satisfiesPostConditionInModelState(currentModelState: AnyObject!, fromModelState previousModelState: AnyObject!, subject: AnyObject!, generatedValue: AnyObject!, objectReturnedBySubject returnedObject: AnyObject!) -> Bool {
        var state = currentModelState as! AppState
        var driver = subject as! AppDriver
        if state.numberOfActiveRequests > 0 {
            if driver.isSpinnerVisible() {
                return true
            } else {
                println("Spinner isn't visible!")
                return false
            }
        }
        return true
    }
}


class RollingGenerativeTest: QuickSpec {
    override func spec() {
        describe("Rolling for numbers") {
            it("should be safe for the user to spawn multiple requests") {
                var stateMachine = FOXFiniteStateMachine(initialModelState: AppState())

                stateMachine.addTransition(ResolveRequestTransition())
                stateMachine.addTransition(RollTransition())

                var window = UIWindow(frame: UIScreen.mainScreen().bounds)
                var commands = executeCommands(stateMachine) {
                    var driver = AppDriver(window: window)
                    driver.setup()
                    return driver
                }

                var property = forAll(commands) { commands in
                    return executedSuccessfully(commands as! NSArray)
                }

                // reduced number of tests for the impatient
                Assert(property, numberOfTests: 100)
            }
        }
    }
}
