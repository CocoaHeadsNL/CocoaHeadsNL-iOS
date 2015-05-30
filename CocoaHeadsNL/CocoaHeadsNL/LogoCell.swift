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
                    self.logoImageView.loadInBackground().continueWithSuccessBlock({[weak self] (task: BFTask!) -> AnyObject! in
                        self?.setNeedsLayout()
                        return nil
                        })                }
            }
        }
    }
}
