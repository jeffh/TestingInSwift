import Foundation
import Quick
import Nimble

// A way to compare NSURL to a uri string.
func equalURLString(uri: String) -> NonNilMatcherFunc<NSURL> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        let url = NSURL(string: uri)

        failureMessage.postfixMessage = "equal URL"
        if let url = url {
            failureMessage.postfixMessage += " to <\(url)>"
        }

        return actualExpression.evaluate() == url
    }
}
