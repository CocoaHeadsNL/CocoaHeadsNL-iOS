import UIKit
import MapKit
import Crashlytics

class MapViewCell: UITableViewCell, MKMapViewDelegate {
    @IBOutlet weak var littleMap: MKMapView!

    var geoLocation: CLLocation? {
        didSet {
            if geoLocation != oldValue {
                let mapRegion = MKCoordinateRegion(center: self.coordinate, span: MKCoordinateSpanMake(0.01, 0.01))
                littleMap.region = mapRegion
            }
        }
    }

    var locationName: String? {
        didSet {
            if let locationName = locationName , locationName != oldValue {
                let annotation = MapAnnotation(coordinate: self.coordinate, title: NSLocalizedString("Here it is!"), subtitle: locationName)
                littleMap.addAnnotation(annotation)
            }
        }
    }

    fileprivate var coordinate: CLLocationCoordinate2D {
        if let geoLocation = geoLocation {
            return CLLocationCoordinate2D(latitude: geoLocation.coordinate.latitude, longitude: geoLocation.coordinate.longitude)
        } else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinAnnotationView")
        annotationView.animatesDrop = true
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.openMapWithCoordinate(coordinate)

        Answers.logContentView(withName: "Show map",
                                       contentType: "Company",
                                       contentId: "\(coordinate)",
                                       customAttributes: nil)

    }

    fileprivate func openMapWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)

        if let locationName = locationName {
            mapItem.name = locationName
        }

        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        let currentLocationMapItem = MKMapItem.forCurrentLocation()

        MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions)
    }
}
