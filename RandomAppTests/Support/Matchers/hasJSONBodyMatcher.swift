import Foundation
import Quick
import Nimble

// provides a way to check JSON body of a request
func haveJSONBody(body: NSObject) -> NonNilMatcherFunc<NSURLRequest> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "have JSON body"
        failureMessage.expected = "\(body)"

        var request = actualExpression.evaluate()
        var error: NSError?
        if let request = request {
            var actualBody: AnyObject? = NSJSONSerialization.JSONObjectWithData(request.HTTPBody!, options: .allZeros, error: &error)
            failureMessage.actualValue = "\(actualBody)"
            if let actualBody: NSObject = actualBody as! NSObject? {
                return actualBody == body
            }
        }
        return false
    }
}
