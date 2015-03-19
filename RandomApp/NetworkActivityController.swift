import Foundation

// Are we testing this class? No. This is simply an implementation detail.
// Testing this directly is a tradeoff to make:
//
//  - It allows refactoring without having to update tests
//  - It's implementation isn't complex enough to warrant its own tests
//    (eg - complex domain logic)
//  - This is on a fine line between UI code and domain logic. Domain-specific
//    code should probably have tests if they are accessed via UI.
//
// In fact, this code was originally in ListViewController before it was
// refactored into its own object.
class NetworkActivityController {
    private var showSpinner: (Bool) -> Void
    private var numberOfActiveRequests: Int

    init(showSpinner: (Bool) -> Void) {
        self.showSpinner = showSpinner
        self.numberOfActiveRequests = 0
    }

    func incrementNumberOfActiveRequests() {
        numberOfActiveRequests += 1
        updateSpinner()
    }

    func decrementNumberOfActiveRequests() {
        numberOfActiveRequests -= 1
        assert(numberOfActiveRequests >= 0, "Oops, counting negative network requests")
        updateSpinner()
    }

    private func updateSpinner() {
        showSpinner(numberOfActiveRequests > 0)
    }
}
