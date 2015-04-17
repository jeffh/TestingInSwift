import UIKit

// Storyboards make this more difficult to test because we no longer control
// object construction. There are several techniques to work with view
// controllers from storyboards:
//
// - Use a wrapped version of UIStoryboard that injects dependencies. This
//   is a common technique for dependency injection frameworks / libraries
// - Have a configuration method that does dependency injection, use that
//   to inject and pass along values in prepareWithSegue.
public class ListViewController: UITableViewController {
    var client: RandomClient
    var numbers: [Int]
    var spinner: UIActivityIndicatorView?
    var spinnerController: NetworkActivityController!

    public init(client: RandomClient) {
        self.client = client
        self.numbers = []
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        title = "Random as a Service"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Roll", style: .Plain, target: self, action: "roll")

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinnerController = NetworkActivityController { [weak self] (showSpinner: Bool) -> Void in
            if let strongSelf = self, spinner = strongSelf.spinner {
                if showSpinner {
                    strongSelf.navigationItem.titleView = spinner
                    spinner.startAnimating()
                } else {
                    spinner.removeFromSuperview()
                    spinner.stopAnimating()
                    strongSelf.navigationItem.titleView = nil
                }
            }
        }

        roll()
    }

    // MARK: Actions

    @IBAction func roll() {
        spinnerController.incrementNumberOfActiveRequests()
        client.randomInteger { number, error in
            if let number = number {
                self.numbers.insert(number, atIndex: 0)
                self.tableView.reloadData()
            }
            self.spinnerController.decrementNumberOfActiveRequests()
        }
    }

    // MARK: UITableViewDataSource

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell.textLabel!.text = "\(self.numbers[indexPath.row])"
        return cell
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }

    // MARK: UITableViewDelegate

    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let number = numbers[indexPath.row]
        var pushedController = DetailViewController(number: number)
        navigationController?.pushViewController(pushedController, animated: true)
    }
}
