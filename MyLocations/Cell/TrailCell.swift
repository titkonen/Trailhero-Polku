import UIKit

class TrailCell: UITableViewCell {
    
    // MARK: OUTLETS
    @IBOutlet var DateLabel: UILabel!
    @IBOutlet var DistanceLabel: UILabel!
    @IBOutlet weak var TrailThumbnailPhoto: UIImageView!
    
    
    
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
    
    
    
}
