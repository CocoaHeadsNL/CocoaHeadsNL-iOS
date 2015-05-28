
import UIKit
import MapKit

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

            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]

            var currentLocationMapItem:MKMapItem = MKMapItem.mapItemForCurrentLocation()

            MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem], launchOptions: launchOptions)
        }
    }
}

