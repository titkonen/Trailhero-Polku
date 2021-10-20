import UIKit

class TrailCell: UITableViewCell {
    
    // MARK: OUTLETS
    @IBOutlet var DateLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var TrailThumbnailPhoto: UIImageView!
    
    // MARK: PROPERTIES
    lazy var paivaMuotoon: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      formatter.timeStyle = .medium
      return formatter
    }()
    
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
    /// You should read this if statement as, “if the trail has a photo, and I can unwrap trail.photoImage, then return the unwrapped image.”
//    func thumbnail2(for trail: Trail) -> UIImage {
//      if trail.hasPhoto, let image = trail.photoImage {
//        return image.resized(withBounds: CGSize(width: 52, height: 52)) ///This needs UIImage+Resize.swift
//      }
//      return UIImage()
//    }
    
    // MARK: - Helper Method -> ACTUAL CELL CONTENT
    func configure2(for trail: Trail) {
      if trail.time == 0 {
        TimeLabel.text = "(No Time)"
      } else {
        TimeLabel.text = String(trail.time)
      }
        
        let trailDate = trail.paiva
        DateLabel.text = paivaMuotoon.string(from: trailDate!)

    
        //TrailThumbnailPhoto.image = thumbnail2(for: trail) // Calling above function "thumbnail"
    }
    
    
}
