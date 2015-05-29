import UIKit
import MapKit

class MapViewCell: UITableViewCell, MKMapViewDelegate {
    @IBOutlet weak var littleMap: MKMapView!

    var geoLocation: PFGeoPoint? {
        didSet {
            if geoLocation != oldValue, let geoLocation = geoLocation {
                let mapRegion = MKCoordinateRegion(center: self.coordinate, span: MKCoordinateSpanMake(0.01, 0.01))
                littleMap.region = mapRegion
            }
        }
    }

    var locationName: String? {
        didSet {
            if locationName != oldValue, let locationName = locationName {
                var annotation = MapAnnotation(coordinate: self.coordinate, title: "Here it is!", subtitle: locationName)
                littleMap.addAnnotation(annotation)
            }
        }
    }

    private var coordinate: CLLocationCoordinate2D {
        if let geoLocation = geoLocation {
            return CLLocationCoordinate2D(latitude: geoLocation.latitude, longitude: geoLocation.longitude)
        } else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinAnnotationView")
        annotationView.animatesDrop = true
        return annotationView
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        self.openMapWithCoordinate(coordinate)
    }

    private func openMapWithCoordinate(coordinate: CLLocationCoordinate2D) {
        var placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        var mapItem = MKMapItem(placemark: placemark)

        if let locationName = locationName {
            mapItem.name = locationName
        }

        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        var currentLocationMapItem = MKMapItem.mapItemForCurrentLocation()

        MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem], launchOptions: launchOptions)
    }
}
