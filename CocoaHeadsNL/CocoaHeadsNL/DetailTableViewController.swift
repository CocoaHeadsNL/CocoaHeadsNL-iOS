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

class DetailTableViewController: UITableViewController, UIWebViewDelegate, MKMapViewDelegate {
    
    var selectedObject: PFObject?
    
    @IBOutlet weak var logoImageView: PFImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptiveTitle: UILabel!
    @IBOutlet weak var htmlWebView: UIWebView!
    @IBOutlet weak var littleMap: MKMapView!
    
    
    @IBOutlet weak var logoCell: UITableViewCell!
    @IBOutlet weak var mapViewCell: UITableViewCell!
    @IBOutlet weak var titleCell: UITableViewCell!
    @IBOutlet weak var descriptiveTitleCell: UITableViewCell!
    @IBOutlet weak var dateLabelCell: UITableViewCell!
    @IBOutlet weak var webViewCell: UITableViewCell!


    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        //Can be used to hide masterViewController and increase size of detailView if wanted
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        self.navigationItem.leftItemsSupplementBackButton = true
        littleMap.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        //tableView.frame = CGRect(origin: tableView.frame.origin, size: tableView.contentSize)
        

        if let company = selectedObject as? Company {
            self.setupCompany()
        } else if let meetup = selectedObject as? Meetup {
            self.setupMeeting()
        } else if let job = selectedObject as? Job {
            self.setupVacancy()
        }
    
        tableView.reloadData()
    }
    
    func setupCompany() {
    
        self.logoImageView.image = nil

        if let company = self.selectedObject as? Company {

        if let logo = company.logo {
            self.logoImageView.file = logo
            self.logoImageView.loadInBackground(nil)
        }
        
        if let name = company.name {
            self.navigationItem.title = name
        }
        
        if let email = company.emailAddress {
            self.titleLabel.text = email
        }
        
        if let address = company.streetAddress {
            self.descriptiveTitle.text = address
        }
        
        if let zipcode = company.zipCode {
            self.dateLabel.text = zipcode
        }
        
//        if let webSite = company.website {
//            let webString = "http://\(webSite)"
//            
//            let url = NSURL(string: webString)
//            let urlRequest = NSURLRequest(URL: url!)
//            self.htmlWebView.loadRequest(urlRequest)
//            self.htmlWebView.scrollView.scrollEnabled = true
//            tableView.reloadData()
//        }
        }
    }
    
    func setupVacancy() {
        if let job = selectedObject as? Job {
            if let title = job.title{
                self.navigationItem.title = title
            }

            self.logoImageView.image = nil

            if let logoFile = job.logo {
                self.logoImageView.file = logoFile
                self.logoImageView.loadInBackground(nil)
            }

            if let jobTitle = job.title {
                self.titleLabel.text = jobTitle
            }

            if let vacanyContent = job.content {
                self.htmlWebView.loadHTMLString(vacanyContent, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
                self.htmlWebView.scrollView.scrollEnabled = false
            }
        }
    }
    
    func setupMeeting() {
        if let meetup = selectedObject as? Meetup {
            if let nameOfHost = meetup.name {
                titleLabel.text = nameOfHost
            }
            
            if let geoLoc = meetup.geoLocation {
                let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), span: MKCoordinateSpanMake(0.01, 0.01))
                littleMap.region = mapRegion;

                if let nameOfLocation = meetup.locationName {
                    var annotation = MapAnnotation(coordinate: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), title: "Here it is!", subtitle: nameOfLocation) as MapAnnotation
                    littleMap.addAnnotation(annotation)
                }
            }

            descriptiveTitle.text = String("Number of Cocoaheads: \(meetup.yes_rsvp_count)")

            if let date = meetup.time {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .MediumStyle
                dateFormatter.timeStyle = .ShortStyle
                dateFormatter.dateFormat = "d MMMM, HH:mm a"
                self.dateLabel.text = dateFormatter.stringFromDate(date)
            }

            if let meetupDescription = meetup.meetup_description {
                self.htmlWebView.loadHTMLString(meetupDescription, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
                self.htmlWebView.scrollView.scrollEnabled = false
            }

            self.logoImageView.image = nil

            if let logoFile = meetup.logo {
                self.logoImageView.file = logoFile
                self.logoImageView.loadInBackground(nil)
            }
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
    
    //MARK: -MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinAnnotationView")
        annotationView.animatesDrop = true
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let meetup = selectedObject as? Meetup {
            if let geoLoc = meetup.geoLocation {
                self.openMapWithCoordinates(geoLoc.longitude, theLat: geoLoc.latitude)
            }
        }
    }
    
    //self.openMapWithCoordinates(geoLoc.longitude, theLat: geoLoc.latitude)
    
    func openMapWithCoordinates(theLon:Double, theLat:Double){
        if let meetup = selectedObject as? Meetup {
            var coordinate = CLLocationCoordinate2DMake(theLat, theLon)
            var placemark:MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary:nil)

            var mapItem:MKMapItem = MKMapItem(placemark: placemark)

            if let nameOfLocation = meetup.locationName {
                mapItem.name = nameOfLocation
            }

            let launchOptions:NSDictionary = NSDictionary(object: MKLaunchOptionsDirectionsModeDriving, forKey: MKLaunchOptionsDirectionsModeKey)

            var currentLocationMapItem:MKMapItem = MKMapItem.mapItemForCurrentLocation()

            MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem], launchOptions: launchOptions)
        }
    }
    
    
    
}
