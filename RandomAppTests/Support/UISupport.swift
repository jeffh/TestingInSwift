// All of these functions here are inspired/ported from PivotalCoreKit
// https://github.com/pivotal/PivotalCoreKit
import UIKit
import Nimble

// emulates a tap on a bar button item. Does not support customViews
func tap(barButtonItem: UIBarButtonItem) {
    SelectorProxy(target: barButtonItem.target).performAction(barButtonItem.action, withObject: barButtonItem)
}

// emulates a button tap. Does not support gesture recognizers
// not used here, but just to demonstrate it.
func tap(button: UIButton) {
    button.sendActionsForControlEvents(.TouchUpInside)
}

// emulates a tap on a tableView cell. Conforms to the delegate call-chain
// for selecting cells (not deselecting).
//
// It's enough to get the job done, but you might want to look at
// PivotalCoreKit for a more proper implementation.
func tap(cell: UITableViewCell, file: String=__FILE__, line: UInt=__LINE__) {
    var parentView = cell.superview
    var tableView: UITableView?

    // find the tableView we belong to
    while parentView != nil{
        if let parentView = parentView as? UITableView {
            tableView = parentView
            break
        } else if let view = parentView {
            parentView = view.superview
        }
    }

    if let tableView = tableView {
        if let indexPath = tableView.indexPathForCell(cell) {
            var newIndexPath: NSIndexPath?
            if tableView.delegate?.respondsToSelector("tableView:willSelectRowAtIndexPath:") == true {
                newIndexPath = tableView.delegate?.tableView!(tableView, willSelectRowAtIndexPath: indexPath)
            } else {
                newIndexPath = indexPath
            }
            if let newIndexPath = newIndexPath {
                tableView.selectRowAtIndexPath(newIndexPath, animated: false, scrollPosition: .Middle)
                tableView.delegate?.tableView?(tableView, didSelectRowAtIndexPath: newIndexPath)
            }
            return
        }
    }
    fail("Could not find table view for cell: \(cell)", file: file, line: line)
}


// Short-hand for fetching a cell from a tableView by scrolling to it.
func cellAt(tableView: UITableView, indexPath: NSIndexPath)
    -> UITableViewCell {
    tableView.layoutIfNeeded()
    tableView.scrollToRowAtIndexPath(indexPath,
        atScrollPosition: UITableViewScrollPosition.Middle,
        animated: false)
    return tableView.cellForRowAtIndexPath(indexPath)!
}

// Short-hand for fetching a cell from a tableView by scrolling to it.
func cellAt(tableView: UITableView, #row: Int, section: Int = 0) -> UITableViewCell {
    let indexPath = NSIndexPath(forRow: row, inSection: section)
    return cellAt(tableView, indexPath)
}
