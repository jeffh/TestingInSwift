// More interesting this over at ListViewControllerSpec.swift
import RandomApp
import Quick
import Nimble

class DetailViewControllerSpec: QuickSpec {
    override func spec() {
        describe("Viewing random number details") {
            var subject: DetailViewController!
            beforeEach {
                subject = DetailViewController(number: 1)
                subject.beginAppearanceTransition(true, animated: false)
                subject.endAppearanceTransition()
            }

            it("should display the number it was given") {
                expect(subject.numberLabel.text).to(equal("1"))
            }
        }
    }
}
