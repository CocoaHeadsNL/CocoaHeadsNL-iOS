import UIKit

public extension UINavigationItem {

    public func setupForRootViewController(withTitle title: String) {

        let imageView = UIImageView(image: UIImage(named: "Banner"))
        imageView.accessibilityTraits = imageView.accessibilityTraits & ~UIAccessibilityTraitImage
        imageView.accessibilityTraits = imageView.accessibilityTraits | UIAccessibilityTraitHeader
        self.titleView = imageView

        self.title = title
    }
}
