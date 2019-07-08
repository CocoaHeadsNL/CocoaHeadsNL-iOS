import UIKit

public extension UINavigationItem {

    func setupForRootViewController(withTitle title: String) {

        let imageView = UIImageView(image: UIImage(named: "Banner"))
        imageView.accessibilityTraits = UIAccessibilityTraits(rawValue: imageView.accessibilityTraits.rawValue & ~UIAccessibilityTraits.image.rawValue)
        imageView.accessibilityTraits = UIAccessibilityTraits(rawValue: imageView.accessibilityTraits.rawValue | UIAccessibilityTraits.header.rawValue)
        self.titleView = imageView

        self.title = title
    }
}
