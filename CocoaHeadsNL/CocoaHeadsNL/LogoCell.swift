import UIKit

class LogoCell: UITableViewCell {
    @IBOutlet weak var logoImageView: PFImageView!

    var logoFile: PFFile? {
        didSet {
            if logoFile != oldValue {
                self.logoImageView.image = nil
                self.logoImageView.contentMode = .ScaleAspectFit

                if let logoFile = logoFile {
                    self.logoImageView.file = logoFile
                    self.logoImageView.loadInBackground({[weak self] (image, error) -> Void in
                        if error == nil {
                            self?.setNeedsLayout()
                        }
                    })
                }
            }
        }
    }
}
