import UIKit

class AffiliateCell: UITableViewCell {
    var productName: String? {
        didSet {
            if let textLabel = textLabel {
                textLabel.adjustsFontSizeToFitWidth = true
                textLabel.text = productName
            }
        }
    }

    var affiliateId: String? {
        didSet {
            if let imageView = imageView, affiliateId = affiliateId {
                imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                imageView.contentMode = .ScaleAspectFit
                fetchIconURL(affiliateId)
            }
        }
    }

    private func fetchIconURL(affiliateId: String) {
        if let url = NSURL(string: "https://itunes.apple.com/lookup?id=\(affiliateId)") {
            let request = NSURLRequest(URL: url)
            let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { [weak self] data, response, error in
                if let s = self, data = data, url = s.parseIconURL(data) {
                    s.loadIconWithURL(url)
                }
            }
            dataTask.resume()
        }
    }

    private func parseIconURL(data: NSData) -> NSURL? {
        let parsedObject: AnyObject?
        do {
            parsedObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            print("error \(error)")
            parsedObject = nil
        }
        if let root = parsedObject as? NSDictionary, results = root["results"] as? NSArray where results.count > 0 {
            if let result = results[0] as? NSDictionary,
                iconUrlString = result["artworkUrl100"] as? String {
                    return NSURL(string: iconUrlString)
            }
        }
        
        return nil
    }

    private func loadIconWithURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { [weak self] data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let s = self, imageView = s.imageView, data = data {
                    imageView.image = UIImage(data: data)
                    s.setNeedsLayout()
                }
            }
        }
        dataTask.resume()
    }
}
