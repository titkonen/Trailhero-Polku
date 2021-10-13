import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet var mapView: MKMapView!

    //MARK: PROPERTIES
    /// Updates MapView Pin content when editing content is happened.
    var managedObjectContext: NSManagedObjectContext! {
      didSet {
        NotificationCenter.default.addObserver(
          forName: Notification.Name.NSManagedObjectContextObjectsDidChange,
          object: managedObjectContext,
          queue: OperationQueue.main
        ) { _ in
          if self.isViewLoaded {
            self.updateLocations()
          }
        }
      }
    }
    var locations = [Location]()

    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
      super.viewDidLoad()
      updateLocations()
      
      /// Shows user location for the first time when user opens the map
      if !locations.isEmpty {
        showLocations()
      }
    }
    
    // MARK: ACTIONS
      @IBAction func showUser() {
        let region = MKCoordinateRegion(
          center: mapView.userLocation.coordinate,
          latitudinalMeters: 1000,
          longitudinalMeters: 1000)
        mapView.setRegion(
          mapView.regionThatFits(region),
          animated: true)
      }

      @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
      }
    
    // MARK: SHOW PINS IN MAP "User button"
    func updateLocations() {
      mapView.removeAnnotations(locations)
      let entity = Location.entity()
      let fetchRequest = NSFetchRequest<Location>()
      fetchRequest.entity = entity

      locations = try! managedObjectContext.fetch(fetchRequest)
      mapView.addAnnotations(locations)
    }
    
    // MARK: SHOW LOCATIONS IN MAP "Locations button"
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
      let region: MKCoordinateRegion

      switch annotations.count {
      case 0: /// There is now pins
        region = MKCoordinateRegion(
          center: mapView.userLocation.coordinate,
          latitudinalMeters: 1000,
          longitudinalMeters: 1000)

      case 1: /// There is one pin
        let annotation = annotations[annotations.count - 1]
        region = MKCoordinateRegion(
          center: annotation.coordinate,
          latitudinalMeters: 1000,
          longitudinalMeters: 1000)

      default: /// There is multiple pins
        var topLeft = CLLocationCoordinate2D(
          latitude: -90,
          longitude: 180)
        var bottomRight = CLLocationCoordinate2D(
          latitude: 90,
          longitude: -180)

        for annotation in annotations {
          topLeft.latitude = max(topLeft.latitude,annotation.coordinate.latitude)
          topLeft.longitude = min(topLeft.longitude,annotation.coordinate.longitude)
          bottomRight.latitude = min(bottomRight.latitude,annotation.coordinate.latitude)
          bottomRight.longitude = max(bottomRight.longitude,annotation.coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
          latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
          longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)

        let extraSpace = 1.1
        let span = MKCoordinateSpan(
          latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
          longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)

        region = MKCoordinateRegion(center: center, span: span)
      }

      return mapView.regionThatFits(region)
    }
    
    // MARK: SHOWLOCATIONDETAILS MODAL
    @objc func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }
    
    // MARK: - Navigation
    override func prepare(
      for segue: UIStoryboardSegue,
      sender: Any?
    ) {
      if segue.identifier == "EditLocation" {
        let controller = segue.destination as! LocationDetailsViewController
        controller.managedObjectContext = managedObjectContext

        let button = sender as! UIButton
        let location = locations[button.tag]
        controller.locationToEdit = location
      }
    }
    
}

// MARK: CUSTOM MAP ANNOTATIONS
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      // 1
      guard annotation is Location else {
        return nil
      }
      // 2
      let identifier = "Location"
      var annotationView = mapView.dequeueReusableAnnotationView(
        withIdentifier: identifier)
      if annotationView == nil {
        let pinView = MKPinAnnotationView(
          annotation: annotation,
          reuseIdentifier: identifier)
        // 3
        pinView.isEnabled = true
        pinView.canShowCallout = true
        pinView.animatesDrop = false
        pinView.pinTintColor = UIColor(
          red: 0.32,
          green: 0.82,
          blue: 0.4,
          alpha: 1)

        // 4
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.addTarget(
          self,
          action: #selector(showLocationDetails(_:)),
          for: .touchUpInside)
        pinView.rightCalloutAccessoryView = rightButton

        annotationView = pinView
      }

      if let annotationView = annotationView {
        annotationView.annotation = annotation

        // 5
        let button = annotationView.rightCalloutAccessoryView as! UIButton
        if let index = locations.firstIndex(of: annotation as! Location) {
          button.tag = index
        }
      }

      return annotationView
    }
    
}
