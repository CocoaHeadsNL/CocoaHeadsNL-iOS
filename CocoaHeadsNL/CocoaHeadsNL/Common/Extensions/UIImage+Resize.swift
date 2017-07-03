import UIKit

extension UIImage {
  func resizedImageWithBounds(_ bounds: CGSize) -> UIImage {
    let horizontalRatio = bounds.width / size.width
    let verticalRatio = bounds.height / size.height
    let ratio = min(horizontalRatio, verticalRatio)
    let newSize = CGSize(width: ceil(size.width * ratio), height: ceil(size.height * ratio))

    UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
    draw(in: CGRect(origin: CGPoint.zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}
