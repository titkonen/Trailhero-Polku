import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: PROPERTIES For Location
    let locationManager = CLLocationManager()
    var location: CLLocation? ///Storing the location
    var updatingLocation = false ///Location error handling
    var lastLocationError: Error? ///Location error handling
    let geocoder = CLGeocoder() /// Reverse geocoding for the address
    var placemark: CLPlacemark? /// Reverse geocoding for the address
    var performingReverseGeocoding = false /// Reverse geocoding for the address
    var lastGeocodingError: Error? /// Reverse geocoding for the address
    var timer: Timer? /// Reverse geocoding for the address // Foundation component
    var managedObjectContext: NSManagedObjectContext! /// Passing CoreData context
    
    // MARK: PROPERTIES Trail Tracking
    var seconds = 1
    
    // MARK: OUTLETS For Location
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!

    // MARK: OUTLETS For Trail Tracking
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      navigationController?.isNavigationBarHidden = false
        
      timer?.invalidate() // Ota myöhemmin pois?
    }
    
    // MARK: ACTIONS
    @IBAction func getLocation() {
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
          locationManager.requestWhenInUseAuthorization()
          return
        }
        
        if authStatus == .denied || authStatus == .restricted {
          showLocationServicesDeniedAlert()
          return
        }
        
        if updatingLocation {
          stopLocationManager()
        } else {
          location = nil
          lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
          startLocationManager()
        }
        updateLabels()
    }
    
    @IBAction func startTimePressed(_ sender: UIButton) {
        startTracking()
        print("start pressed!")
    }
    
    @IBAction func stopTimePressed(_ sender: UIButton) {
        stopTracking()
        print("stop pressed!")
    }
    
    @IBAction func saveTimePressed(_ sender: UIButton) {
        
        let  newTrail: Trail
        newTrail = Trail(context: managedObjectContext)
        newTrail.time = Double(seconds)
        newTrail.paiva = Date()
        newTrail.distance = Double(seconds)
        newTrail.sportsType = "MTB"
        newTrail.trailDescription = "Add your text here"
        
        do {
            try managedObjectContext.save()
            print("Do! succeed")
        } catch {
            fatalError("Error: saving content to coredata \(error)")
        }
        
        print("Save time pressed!")
    }
    

    // MARK: FUNCTIONS
    func startTracking() {
        seconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in self.eachSecond()
        }
        //distance = Measurement(value: 0, unit: UnitLength.meters)
        //locationList.removeAll()
        updateView()
//        stopButton.isHidden = true
        //startLocationUpdates()
    }
    
    func stopTracking() {
        timer?.invalidate()
        updateView()
        print("Tracking stopped.Invalidate")
        //startButton.isHidden = false
        //locationManager.stopUpdatingLocation()
    }
    
    func eachSecond() {
        seconds += 1
        updateView()
    }
    
    // ONKO TÄMÄ RESET??
    func eachSecondStop() {
        seconds = 0
        updateView()
    }
    
    func updateView() {
        //let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        //distanceLabel.text = "Distance:  \(formattedDistance)"
        timeLabel.text = "Time: \(formattedTime)"
    }
    
    func updateLabels() {
      if let location = location {
        latitudeLabel.text = String(
          format: "%.8f",
          location.coordinate.latitude)
        longitudeLabel.text = String(
          format: "%.8f",
          location.coordinate.longitude)
        tagButton.isHidden = false
        messageLabel.text = ""
        
        if let placemark = placemark { /// Placemark is for address geocoder
             addressLabel.text = string(from: placemark)
           } else if performingReverseGeocoding {
             addressLabel.text = "Searching for Address..."
           } else if lastGeocodingError != nil {
             addressLabel.text = "Error Finding Address"
           } else {
             addressLabel.text = "No Address Found"
        }
        
      } else {
        latitudeLabel.text = ""
        longitudeLabel.text = ""
        addressLabel.text = ""
        tagButton.isHidden = true
        let statusMessage: String
            if let error = lastLocationError as NSError? {
              if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                statusMessage = "Location Services Disabled"
              } else {
                statusMessage = "Error Getting Location"
              }
            } else if !CLLocationManager.locationServicesEnabled() {
              statusMessage = "Location Services Disabled"
            } else if updatingLocation {
              statusMessage = "Searching..."
            } else {
              statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
      }
        configureGetButton()
    }
    
    func string(from placemark: CLPlacemark) -> String {
        ///There is additional extension in file: String+AddText.swift
      var line1 = ""
      line1.add(text: placemark.subThoroughfare)
      line1.add(text: placemark.thoroughfare, separatedBy: " ")

      var line2 = ""
      line2.add(text: placemark.locality)
      line2.add(text: placemark.administrativeArea, separatedBy: " ")
      line2.add(text: placemark.postalCode, separatedBy: " ")

      line1.add(text: line2, separatedBy: "\n")
      return line1
    }
    
    func configureGetButton() {
      if updatingLocation {
        getButton.setTitle("Stop", for: .normal)
      } else {
        getButton.setTitle("Get My Location", for: .normal)
      }
    }
    
    func startLocationManager() {
      if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        updatingLocation = true
        
        timer = Timer.scheduledTimer(
              timeInterval: 60,
              target: self,
              selector: #selector(didTimeOut),
              userInfo: nil,
              repeats: false)
      }
    }
    
    func stopLocationManager() {
      if updatingLocation {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        updatingLocation = false
        if let timer = timer {
          timer.invalidate()
        }
      }
    }
    
    @objc func didTimeOut() {
      print("*** Time out")
      if location == nil {
        stopLocationManager()
        lastLocationError = NSError(
          domain: "MyLocationsErrorDomain",
          code: 1,
          userInfo: nil)
        updateLabels()
      }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("didFailWithError \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
          lastLocationError = error
          stopLocationManager()
          updateLabels()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
          print("didUpdateLocations \(newLocation)")

          if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
          }

          if newLocation.horizontalAccuracy < 0 {
            return
          }
        
          var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
            if let location = location {
                distance = newLocation.distance(from: location)
          }

          if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {

            lastLocationError = nil
            location = newLocation

            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
              print("*** We're done!")
              stopLocationManager()
                
              if distance > 0 {
                performingReverseGeocoding = false
              }
                
            }
            updateLabels()
            ///Code for reverse geocoding
            if !performingReverseGeocoding {
                  print("*** Going to geocode")

                  performingReverseGeocoding = true

                    geocoder.reverseGeocodeLocation(newLocation) {placemarks, error in
                        self.lastGeocodingError = error
                        if error == nil, let places = placemarks, !places.isEmpty {
                          self.placemark = places.last!
                        } else {
                          self.placemark = nil
                        }

                        self.performingReverseGeocoding = false
                        self.updateLabels()
                    }
                
            } else if distance < 1 {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 10 {
                  print("*** Force done!")
                  stopLocationManager()
                  updateLabels()
                }
            }
          }
    }
    
    // MARK: NAVIGATION to DetailVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "TagLocation" {
        let controller = segue.destination as! LocationDetailsViewController
        controller.coordinate = location!.coordinate
        controller.placemark = placemark
        controller.managedObjectContext = managedObjectContext /// Pass coreData context to LocationDetailsVC
      }
    }
    
    // MARK: - Helper Methods
    func showLocationServicesDeniedAlert() {
      let alert = UIAlertController(
        title: "Location Services Disabled",
        message: "Please enable location services for this app in Settings.",
        preferredStyle: .alert)

      let okAction = UIAlertAction(
        title: "OK",
        style: .default,
        handler: nil)
      alert.addAction(okAction)

      present(alert, animated: true, completion: nil)
    }

}

