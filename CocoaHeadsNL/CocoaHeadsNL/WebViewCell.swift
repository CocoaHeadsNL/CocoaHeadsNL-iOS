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
                                                baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
                self.htmlWebView.scrollView.scrollEnabled = false
            }
        }
    }

    private func layoutWebView() {
        let size = htmlWebView.sizeThatFits(CGSize(width:htmlWebView.frame.width, height: 10000))
        if size.height != heighLayoutConstraint.constant {
            heighLayoutConstraint.constant = size.height
            reloadCell(self)
        }
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        layoutWebView()
    }

    func webView(webView: UIWebView,
                 shouldStartLoadWithRequest request: NSURLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        } else {
            return true
        }
    }
}
