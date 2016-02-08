import UIKit
import CloudKit

class LogoCell: UITableViewCell {
    @IBOutlet weak var logoImageView: UIImageView!

    var logoFile: CKAsset? {
        didSet {
            if logoFile != oldValue {
                self.logoImageView.image = nil
                self.logoImageView.contentMode = .ScaleAspectFit

                if let logoFile = logoFile {
                    
                    if let data = NSData(contentsOfURL: logoFile.fileURL) {
                        self.logoImageView.image =  UIImage(data: data)!
                        self.setNeedsLayout()
                    }
                }
            }
        }
    }
}
