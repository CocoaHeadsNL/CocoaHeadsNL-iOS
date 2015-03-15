//
//  DetailTableViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 14/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DetailTableViewController: UITableViewController, UIWebViewDelegate {
    
    var selectedObject: PFObject?
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptiveTitle: UILabel!
    @IBOutlet weak var htmlWebView: UIWebView!
    @IBOutlet weak var littleMap: MKMapView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        //Can be used to hide masterViewController and increase size of detailView if wanted
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.printSelectedObject()
        
        tableView.frame = CGRect(origin: tableView.frame.origin, size: tableView.contentSize)
        
        if let nameOfHost = selectedObject?.valueForKey("name") as? String {
            titleLabel.text = nameOfHost
        }
        
        if let geoLoc = selectedObject?.valueForKey("geoLocation") as? PFGeoPoint {
            let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), span: MKCoordinateSpanMake(0.01, 0.01))
            littleMap.region = mapRegion;
            
            if let nameOfLocation = selectedObject?.valueForKey("locationName") as? String {
                var annotation = MapAnnotation(coordinate: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), title: "Here it is!", subtitle: nameOfLocation) as MapAnnotation
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinAnnotationView")
                annotationView.backgroundColor = UIColor.whiteColor()
                annotationView.alpha = 0.9
                littleMap.addAnnotation(annotation)
            }
        }
        
        if let numberOfPeople = selectedObject?.valueForKey("yes_rsvp_count") as? Int {
            descriptiveTitle.text = String("Number of Cocoaheads: \(numberOfPeople)")
        }
        
        if let date = selectedObject?.valueForKey("time") as? NSDate {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .ShortStyle
            dateFormatter.dateFormat = "d MMMM, HH:mm a"
            self.dateLabel.text = dateFormatter.stringFromDate(date)
        }
        
        if let meetupDescription = selectedObject?.valueForKey("meetup_description") as? String {
            self.htmlWebView.loadHTMLString(meetupDescription, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
            self.htmlWebView.scrollView.scrollEnabled = false
        }
        
        if let logoFile = selectedObject?.objectForKey("logo") as? PFFile {
            logoFile.getDataInBackgroundWithBlock({ (imageData: NSData!, error: NSError!) -> Void in
                let logoData = UIImage(data: imageData)
                self.logoImageView.image = logoData
            })
        }
        
        tableView.reloadData()
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
