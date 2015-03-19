// FakeHTTPClient for testing.
// This allows us to emulate http request / responses from tests.
//
// Most of the code in RecordedRequest can be removed, but are simply
// conveniences built from writing tests.
import Foundation
import RandomApp

struct RecordedRequest {
    let request: NSURLRequest
    let callback: (NSURLResponse?, NSData?, NSError?) -> Void

    func resolve(statusCode: Int, data: NSData) {
        var response = NSHTTPURLResponse(URL: request.URL!, statusCode: statusCode, HTTPVersion: "1.1", headerFields: nil)
        callback(response, data, nil)
    }

    func resolve(statusCode: Int, JSONData: AnyObject) {
        var error: NSError?
        var data = NSJSONSerialization.dataWithJSONObject(JSONData, options: .allZeros, error: &error)
        assert(error == nil, "Failed to convert JSONData into JSON: \(error)")
        resolve(statusCode, data: data!)
    }

    func reject(error: NSError) {
        callback(nil, nil, error)
    }
}

class FakeHTTPClient: HTTPClient {
    var recordedRequests: [RecordedRequest]

    init() {
        recordedRequests = []
    }

    func sendRequest(request: NSURLRequest, complete: (NSURLResponse?, NSData?, NSError?) -> Void) {
        recordedRequests.append(RecordedRequest(
            request: request,
            callback: complete))
    }

    func clearRecordedRequests() {
        recordedRequests = []
    }
}
