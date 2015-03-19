// A simple way to define HTTP responses. Only the import data is specified
// to help call out the important data in the response.
//
// The remaining JSON data is simply for completeness of an API response.
import Foundation

func randomNumberResponse(n: [Int]) -> AnyObject {
    return [
        "jsonrpc": "2.0",
        "result": [
            "random": [
                "data": n,
                "completionTime": "2015-03-08 09:14:26Z",
            ],
            "bitsUsed": 33,
            "bitsLeft": 249900,
            "requestsLeft": 998,
            "advisoryDelay": 0,
        ],
        "id": 1,
    ]
}