//
//  DetailViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIkit

class DetailViewController : UIViewController, UIWebViewDelegate {
    var selectedObject: PFObject?
    
    @IBOutlet weak var sponsorTitle: UILabel!
    @IBOutlet weak var sponsorLocation: UILabel!
    @IBOutlet weak var descriptiveTitle: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var logoView: UIImageView!
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.printSelectedObject()
        
        //selectedObject can either be vacancy or meetup info or company info possibly
        //Need to make distinction for setting up UI between vacancy and meetup info.
        
        
        self.sponsorTitle.text = selectedObject?.valueForKey("time") as? String
        self.sponsorLocation.text = selectedObject?.valueForKey("place") as? String
        self.descriptiveTitle.text = selectedObject?.valueForKey("name") as? String
        
        if var meetupDescription = selectedObject?.valueForKey("meetup_description") as? String {
            self.webView.loadHTMLString(meetupDescription, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
        } else if var vacancyDescription = selectedObject?.valueForKey("content") as? String {
            self.webView.loadHTMLString(vacancyDescription, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
        } else if var companyDescription = selectedObject?.valueForKey("companyDescription") as? String {
            self.webView.loadHTMLString(companyDescription, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
        } else {
            self.webView.loadHTMLString("", baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
        }
        
        //Missing logo of sponsor on meetup. Needs to be added somehow (atm through parse)
        if let logoFile = selectedObject?.objectForKey("logo") as? PFFile {
            logoFile.getDataInBackgroundWithBlock({ (imageData: NSData!, error: NSError!) -> Void in
                let logoData = UIImage(data: imageData)
                self.logoView.image = logoData
            })
        }
        
        if let date = selectedObject?.valueForKey("time") as? NSDate {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .ShortStyle
            dateFormatter.dateFormat = "d MMMM, HH:mm a"
            self.sponsorTitle.text = dateFormatter.stringFromDate(date)
        }
    }
    
    func printSelectedObject()
    {
        if let object = selectedObject {
        println(selectedObject)
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        
        return true
    }
}
