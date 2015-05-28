
import UIKit

class  WebViewCell: UITableViewCell, UIWebViewDelegate {
    @IBOutlet weak var htmlWebView: UIWebView!

    @IBOutlet weak var heighLayoutConstraint: NSLayoutConstraint!
    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }

            if let company = selectedObject as? Company {
                //                if let webSite = company.website {
                //                    let webString = "http://\(webSite)"
                //
                //                    let url = NSURL(string: webString)
                //                    let urlRequest = NSURLRequest(URL: url!)
                //                    self.htmlWebView.loadRequest(urlRequest)
                //                    self.htmlWebView.scrollView.scrollEnabled = true
                //                    tableView.reloadData()
                //                }
            } else if let meetup = selectedObject as? Meetup {
                if let meetupDescription = meetup.meetup_description {
                    self.htmlWebView.loadHTMLString(meetupDescription, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
                    self.htmlWebView.scrollView.scrollEnabled = false
                }
            } else if let job = selectedObject as? Job {
                if let vacanyContent = job.content {
                    self.htmlWebView.loadHTMLString(vacanyContent, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
                    self.htmlWebView.scrollView.scrollEnabled = false
                }
            }
        }
    }

    func layoutWebView() {
        let size = htmlWebView.sizeThatFits(CGSize(width:htmlWebView.frame.width, height: 10000.0))

        if size.height != heighLayoutConstraint.constant {
            heighLayoutConstraint.constant =  size.height
            reloadCell(self)
        }
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        layoutWebView()
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }

        return true
    }
}

