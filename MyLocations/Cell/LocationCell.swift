import UIKit

/// Adding photo to cell:
/// create and connect UIImageView outlet
/// create "thumbnail" function
/// Call it in configure function

class LocationCell: UITableViewCell {

    // MARK: PROPERTIES
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    // MARK: VIEW LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: FUNCTIONS
    /// You should read this if statement as, “if the location has a photo, and I can unwrap location.photoImage, then return the unwrapped image.”
    func thumbnail(for location: Location) -> UIImage {
      if location.hasPhoto, let image = location.photoImage {
        return image.resized(withBounds: CGSize(width: 52, height: 52)) ///This needs UIImage+Resize.swift
      }
      return UIImage()
    }
    
    
    // MARK: - Helper Method -> ACTUAL CELL CONTENT
    func configure(for location: Location) {
      if location.locationDescription.isEmpty {
        descriptionLabel.text = "(No Description)"
      } else {
        descriptionLabel.text = location.locationDescription
      }

      if let placemark = location.placemark {
          var text = ""
          text.add(text: placemark.subThoroughfare)
          text.add(text: placemark.thoroughfare, separatedBy: " ")
          text.add(text: placemark.locality, separatedBy: ", ")
          addressLabel.text = text
      } else {
        addressLabel.text = String(
          format: "Lat: %.8f, Long: %.8f",
          location.latitude,
          location.longitude)
      }
      photoImageView.image = thumbnail(for: location) // Calling above function "thumbnail"
    }

}
