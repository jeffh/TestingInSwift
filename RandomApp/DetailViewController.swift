import UIKit

// A sample controller that uses a nib, nothing special here otherwise.
// The ListViewController tests also demonstrate a way to verify controller
// transitions.
public class DetailViewController: UIViewController {
    public private(set) var number: Int
    @IBOutlet public private(set) var numberLabel: UILabel!

    public init(number: Int) {
        self.number = number
        super.init(nibName: "DetailViewController", bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "A Random Number"
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.numberLabel.text = "\(number)"
    }
}
