//
//  MapAnnotation.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 14/03/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
