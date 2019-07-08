import UIKit
import MapKit

class MapViewCell: UITableViewCell, MKMapViewDelegate {
    @IBOutlet weak var littleMap: MKMapView!

    var geoLocation: CLLocation? {
        didSet {
            if geoLocation != oldValue {
                let mapRegion = MKCoordinateRegion(center: self.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
                littleMap.region = mapRegion
            }
        }
    }

    var locationName: String? {
        didSet {
            if let locationName = locationName, locationName != oldValue {
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
    }

    func openMapWithCoordinate(_ coordinate: CLLocationCoordinate2D? = nil) {
        let placemark = MKPlacemark(coordinate: coordinate ?? self.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)

        if let locationName = locationName {
            mapItem.name = locationName
        }

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let currentLocationMapItem = MKMapItem.forCurrentLocation()

        MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions)
    }
}
