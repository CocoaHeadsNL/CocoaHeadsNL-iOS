//
//  MapViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    var companyModel = CompaniesModel()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showLocationList"
        {
            let vc = segue.destinationViewController as LocationListViewController
            vc.companies = self.companyModel.companiesArray;
        }
    }
    
}
