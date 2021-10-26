//
//  Trail+CoreDataClass.swift
//  MyLocations
//
//  Created by Toni Itkonen on 14.10.2021.
//
//

import Foundation
import CoreData
import MapKit

@objc(Trail)
public class Trail: NSManagedObject {

    public var title: String? {
        if trailDescription!.isEmpty {
        return "(No Trail Description)"
      } else {
        return trailDescription
      }
    }
    
    public var subtitle: String? {
      return sportsType
    }
    
    ///Photo: This determines whether the Location object has a photo associated with it or not.
    var hasPhoto: Bool {
      return photoIDtrail != nil
    }
    
    ///Photo: This property computes the full URL for the JPEG file for the photo.
    var photoURL: URL {
      assert(photoIDtrail != nil, "No photo ID set")
      let filename = "Photo-\(photoIDtrail!.intValue).jpg"
      return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var photoImage2: UIImage? {
      return UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPhotoID() -> Int {
      let userDefaults = UserDefaults.standard
      let currentID = userDefaults.integer(forKey: "PhotoID") + 1
      userDefaults.set(currentID, forKey: "PhotoID")
      return currentID
    }
    
    func removePhotoFile() {
      if hasPhoto {
        do {
          try FileManager.default.removeItem(at: photoURL)
        } catch {
          print("Error removing file: \(error)")
        }
      }
    }
    
}
