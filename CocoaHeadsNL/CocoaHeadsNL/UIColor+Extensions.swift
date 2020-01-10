import UIKit

public func UIColorWithRGB(_ red: Int, green: Int, blue: Int) -> UIColor {
    return UIColor(red: CGFloat(red) / 255.0,
                   green: CGFloat(green) / 255.0,
                   blue: CGFloat(blue) / 255.0,
                   alpha: 1.0)
}
