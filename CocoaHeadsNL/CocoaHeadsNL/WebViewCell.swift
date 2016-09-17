import UIKit

class WebViewCell: UITableViewCell, UIWebViewDelegate {
    @IBOutlet weak var htmlWebView: UIWebView!
    @IBOutlet weak var heighLayoutConstraint: NSLayoutConstraint!

    var html: String? {
        didSet {
            if html == oldValue {
                return
            }

            if let html = html {
                self.htmlWebView.loadHTMLString(html,
                                                baseURL: URL(string:"http://jobs.cocoaheads.nl"))
                self.htmlWebView.scrollView.isScrollEnabled = false
            }
        }
    }

    fileprivate func layoutWebView() {
        let size = htmlWebView.sizeThatFits(CGSize(width:htmlWebView.frame.width, height: 10000))
        if size.height != heighLayoutConstraint.constant {
            heighLayoutConstraint.constant = size.height
            reloadCell(self)
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        layoutWebView()
    }

    func webView(_ webView: UIWebView,
                 shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        } else {
            return true
        }
    }
}
