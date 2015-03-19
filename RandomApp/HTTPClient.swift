// This file happens to be untested, so we try to keep this as straight forward
// as possible.
//
// A possible way to test this would be to integrate it against a fake 
// in-process web server.
//
// Fortunately, this is relatively straight-forward to verify by running the
// app. If regressions are common during development for this code, it would
// be worth investing in having tests that start an in-process web server
// to test against.

import Foundation

public protocol HTTPClient {
    func sendRequest(request: NSURLRequest, complete: (NSURLResponse?, NSData?, NSError?) -> Void)
}

public class URLConnectionHTTPClient: HTTPClient {
    let queue: NSOperationQueue

    public init() {
        queue = NSOperationQueue.mainQueue()
    }

    public init(callbackQueue: NSOperationQueue) {
        queue = callbackQueue
    }

    public func sendRequest(request: NSURLRequest, complete: (NSURLResponse?, NSData?, NSError?) -> Void) {
        NSURLConnection.sendAsynchronousRequest(request,
            queue: queue,
            completionHandler: complete)
    }
}
