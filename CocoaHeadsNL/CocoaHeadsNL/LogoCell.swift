
import UIKit

class LogoCell: UITableViewCell {
    @IBOutlet weak var logoImageView: PFImageView!

    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }

            self.logoImageView.image = nil

            if let company = selectedObject as? Company {
                if let logo = company.logo {
                    self.logoImageView.file = logo
                }

            } else if let meetup = selectedObject as? Meetup {
                if let logoFile = meetup.logo {
                    self.logoImageView.file = logoFile
                    self.logoImageView.loadInBackground(nil)
                    self.logoImageView.contentMode = .ScaleAspectFit
                }
            } else if let job = selectedObject as? Job {
                if let logoFile = job.logo {
                    self.logoImageView.file = logoFile
                }
            }

            if (self.logoImageView.image != nil) {
                self.logoImageView.loadInBackground({ (image, error) -> Void in
                    self.logoImageView.contentMode = .ScaleAspectFit
                })
            }
        }
    }
}
