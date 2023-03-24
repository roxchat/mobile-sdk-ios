
import UIKit

extension UIButton {

    public func makeMultiLineSupport() {
        guard let titleLabel = titleLabel else {
            return
        }
        titleLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addConstraints([
            .init(item: titleLabel,
                  attribute: .top,
                  relatedBy: .greaterThanOrEqual,
                  toItem: self,
                  attribute: .top,
                  multiplier: 1.0,
                  constant: contentEdgeInsets.top),
            .init(item: titleLabel,
                  attribute: .bottom,
                  relatedBy: .greaterThanOrEqual,
                  toItem: self,
                  attribute: .bottom,
                  multiplier: 1.0,
                  constant: contentEdgeInsets.bottom),
            .init(item: titleLabel,
                  attribute: .left,
                  relatedBy: .greaterThanOrEqual,
                  toItem: self,
                  attribute: .left,
                  multiplier: 1.0,
                  constant: contentEdgeInsets.left),
            .init(item: titleLabel,
                  attribute: .right,
                  relatedBy: .greaterThanOrEqual,
                  toItem: self,
                  attribute: .right,
                  multiplier: 1.0,
                  constant: contentEdgeInsets.right)
            ])
    }

}
