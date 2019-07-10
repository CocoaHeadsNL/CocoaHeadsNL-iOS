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
            if let imageView = imageView, let affiliateId = affiliateId {
                imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                imageView.contentMode = .scaleAspectFit
                fetchIconURL(affiliateId)
            }
        }
    }

    fileprivate func fetchIconURL(_ affiliateId: String) {
        if let url = URL(string: "https://itunes.apple.com/lookup?id=\(affiliateId)") {
            let request = URLRequest(url: url)
            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, _, _ in
                if let s = self, let data = data, let url = s.parseIconURL(data) {
                    s.loadIconWithURL(url)
                }
            })
            dataTask.resume()
        }
    }

    fileprivate func parseIconURL(_ data: Data) -> URL? {
        let parsedObject: Any?
        do {
            parsedObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch let error as NSError {
            print("error \(error)")
            parsedObject = nil
        }
        if let root = parsedObject as? [String: AnyObject], let results = root["results"] as? [AnyObject], !results.isEmpty {
            if let result = results[0] as? [String: AnyObject],
                let iconUrlString = result["artworkUrl60"] as? String {
                    return URL(string: iconUrlString)
            }
        }
        return nil
    }

    fileprivate func loadIconWithURL(_ url: URL) {
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, _, _ in
            DispatchQueue.main.async {
                if let s = self, let imageView = s.imageView, let data = data {
                    imageView.image = UIImage(data: data)
                    s.setNeedsLayout()
                }
            }
        })
        dataTask.resume()
    }
}
