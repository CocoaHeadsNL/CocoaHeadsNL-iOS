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

class DetailTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var selectedObject: PFObject?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        //Can be used to hide masterViewController and increase size of detailView if wanted
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillAppear(animated: Bool) {
        if let company = selectedObject as? Company {
            if let name = company.name {
                self.navigationItem.title = name
            }
        } else if let meetup = selectedObject as? Meetup {
            if let title = meetup.name{
                self.navigationItem.title = title
            }
        } else if let job = selectedObject as? Job {
            if let title = job.title{
                self.navigationItem.title = title
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let company = selectedObject as? Company {
            return 4
            // no map
            // no web
        } else if let meetup = selectedObject as? Meetup {
            return 6
        } else if let job = selectedObject as? Job {
            return 3
            //no map
            //no descriptiveTitle
            //no dateLabel
        }

        return 6
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var actualRow = indexPath.row
        
        if let company = selectedObject as? Company {
            if actualRow > 0 {
                // no map
                actualRow++
            }
            if actualRow > 4 {
                // no web
                actualRow++
            }

        } else if let meetup = selectedObject as? Meetup {
        } else if let job = selectedObject as? Job {
            if actualRow > 0 {
                // no map
                actualRow++
            }
            if actualRow > 2 {
                //no descriptiveTitle
                actualRow++
            }
            if actualRow > 3 {
                //no dateLabel
                actualRow++
            }
        }
        switch actualRow {
        case 0:
            if let cell = tableView.dequeueReusableCellWithIdentifier("logoCell") as? LogoCell {
                cell.selectedObject = selectedObject
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCellWithIdentifier("mapViewCell") as? MapViewCell {
                cell.selectedObject = selectedObject
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as? TitleCell {
                cell.cellMode = .Line1
                cell.selectedObject = selectedObject
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as? TitleCell {
                cell.cellMode = .Line2
                cell.selectedObject = selectedObject
                return cell
            }
        case 4:
            if let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as? TitleCell {
                cell.cellMode = .Line3
                cell.selectedObject = selectedObject
                return cell
            }
        case 5:
            if let cell = tableView.dequeueReusableCellWithIdentifier("webViewCell") as? WebViewCell {
                cell.selectedObject = selectedObject
                return cell
            }
        default:
            assertionFailure("This should not happen.")
            return UITableViewCell()
        }

        assertionFailure("This should not happen.")
        return UITableViewCell()
    }
    
    override func reloadCell(cell:UITableViewCell) {
        if cell.frame.height < 100 {
            println("test")
            self.tableView.reloadData()
        }
    }

}

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
                    self.logoImageView.loadInBackground(nil)
                }

            } else if let meetup = selectedObject as? Meetup {
                if let logoFile = meetup.logo {
                    self.logoImageView.file = logoFile
                    self.logoImageView.loadInBackground(nil)
                }
            } else if let job = selectedObject as? Job {
                if let logoFile = job.logo {
                    self.logoImageView.file = logoFile
                    self.logoImageView.loadInBackground(nil)
                }
            }
        }
    }
}

class  MapViewCell: UITableViewCell, MKMapViewDelegate {
    @IBOutlet weak var littleMap: MKMapView!
    
    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }
            
            if let company = selectedObject as? Company {
            } else if let meetup = selectedObject as? Meetup {
                if let geoLoc = meetup.geoLocation {
                    let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), span: MKCoordinateSpanMake(0.01, 0.01))
                    littleMap.region = mapRegion;
                    
                    if let nameOfLocation = meetup.locationName {
                        var annotation = MapAnnotation(coordinate: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), title: "Here it is!", subtitle: nameOfLocation) as MapAnnotation
                        littleMap.addAnnotation(annotation)
                    }
                }
            } else if let job = selectedObject as? Job {
            }
        }
    }
    
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


enum CellMode {
    case Line1
    case Line2
    case Line3
}

class  TitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var cellMode = CellMode.Line1

    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }
            
            if let company = selectedObject as? Company {
                switch cellMode {
                case .Line1:
                    if let email = company.emailAddress {
                        self.titleLabel.text = email
                    }
                case .Line2:
                    if let address = company.streetAddress {
                        self.titleLabel.text = address
                    }
                case .Line3:
                    if let zipcode = company.zipCode {
                        self.titleLabel.text = zipcode
                    }
                }
            } else if let meetup = selectedObject as? Meetup {
                switch cellMode {
                case .Line1:
                    if let nameOfHost = meetup.name {
                        titleLabel.text = nameOfHost
                    }
                case .Line2:
                    titleLabel.text = String("Number of Cocoaheads: \(meetup.yes_rsvp_count)")
                case .Line3:
                    if let date = meetup.time {
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = .MediumStyle
                        dateFormatter.timeStyle = .ShortStyle
                        dateFormatter.dateFormat = "d MMMM, HH:mm a"
                        self.titleLabel.text = dateFormatter.stringFromDate(date)
                    }
                }
            } else if let job = selectedObject as? Job {
                switch cellMode {
                case .Line1:
                    if let jobTitle = job.title {
                        self.titleLabel.text = jobTitle
                    }
                case .Line2:
                    self.titleLabel.text = ""
                case .Line3:
                    self.titleLabel.text = ""
                }

            }
        }
    }
}

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
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.sizeToFit()
        
        heighLayoutConstraint.constant =  webView.frame.height
        reloadCell(self)
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        
        return true
    }
}

extension UIResponder {
    func reloadCell(cell:UITableViewCell) {
        self.nextResponder()?.reloadCell(cell)
    }
}

