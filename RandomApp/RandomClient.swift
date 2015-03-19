import Foundation

public class RandomClient {
    let apiURL = NSURL(string: "https://api.random.org/json-rpc/1/invoke")!
    let apiKey: String
    var buffer: [Int]
    var rpcId = 0
    var client: HTTPClient

    public init(httpClient: HTTPClient, apiKey: String) {
        assert(apiKey.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0,
            "API Key is required")
        self.apiKey = apiKey
        self.buffer = []
        self.rpcId = 0
        self.client = httpClient
    }

    public func randomInteger(callback: (Int?, NSError?) -> Void) {
        if self.buffer.count == 0 {
            fillBuffer(callback)
        } else {
            return callback(self.buffer.removeAtIndex(0), nil)
        }
    }

    private func fillBuffer(callback: (Int?, NSError?) -> Void) {
        invoke("generateIntegers", arguments: ["n": 10, "min": 0, "max": 100]) { result, error in
            if let error = error {
                callback(nil, error)
            } else if let
                result = result,
            	random = result["random"] as? [String: AnyObject],
                data: [Int] = random["data"] as? [Int] {
                    self.buffer = data
                    callback(self.buffer.removeAtIndex(0), error)
            }
        }
    }

    private func invoke(method: String, arguments: [String: AnyObject], complete: ([String: AnyObject]?, NSError?) -> Void) {
        var error: NSError?
        var request = NSMutableURLRequest(URL: apiURL)
        request.HTTPMethod = "POST"

        var args = arguments
        args["apiKey"] = apiKey
        rpcId += 1
        var body: [String: AnyObject] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": args,
            "id": rpcId,
        ]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: .allZeros, error: &error)

        if let error = error {
            complete(nil, error)
            return
        }

        client.sendRequest(request) { response, data, error in
            if let data = data where error == nil {
                var result: [String: AnyObject]?
                var jsonError: NSError?
                var value: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &jsonError)

                if let value = value as? [String: AnyObject], res = value["result"] as? [String: AnyObject] {
                    result = res
                } else {
                    jsonError = NSError(domain: "SemanticError", code: 1, userInfo: nil)
                }
                complete(result, jsonError)
            } else {
                complete(nil, error)
            }
        }
    }
}
