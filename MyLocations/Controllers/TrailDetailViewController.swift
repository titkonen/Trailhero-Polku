import UIKit
import CoreData

//MARK: CLASS OUTSIDE PROPERTY
private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMMM dd, YYYY HH:mm"
  return formatter
}()

class TrailDetailViewController: UIViewController {
 
    //MARK: OUTLETS
        
    //MARK: PROPERTIES
    var managedObjectContext: NSManagedObjectContext! /// Passing coredata context
    var date = Date()
    
    var trailDataCell: Trail! {
        didSet {
          //distanceLabel.text = String(noteData.distance)
            durationLabel.text = String(trailDataCell.time)
          //dateLabel.text = dateFormatter.string(from: noteData.timestamp ?? Date())
            dateLabel2.text = format(date: date)
        }
    }
    
    fileprivate lazy var dateLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
        label.text = dateFormatter.string(from: trailDataCell?.paiva ?? Date())
        //label.text = "HELLO HELLO 3"
        label.textAlignment = .left
        return label
    }()
    
    fileprivate lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
        //label.text = dateFormatter.string(from: Date())
        label.text = "This is time !!!"
        label.textAlignment = .right
        return label
    }()
    

    
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Testing
        setupUI()
        print("View Did load")
        
        /// Nää toimii niin, että näyttää default arvoja
        //timeLabel.text = String(juoksuAika)
        //dateLabel.text = format(date: date)
        
        view.backgroundColor = .blue
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//      super.viewWillAppear(animated)
//
//      view.backgroundColor = UIColor(red: 0/255, green: 59/255, blue: 59/255, alpha: 1)
//      //print("viewWillAppear is loaded 2")
//
//      dateLabel2.text = format(date: date)
//
//        durationLabel.text = String(trailDataCell.time)
//
//    }
    
    //MARK: ACTIONS
    
    //MARK: FUNCTIONS
    fileprivate func setupUI() {
        view.addSubview(dateLabel2)
        view.addSubview(durationLabel)
        
        dateLabel2.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        dateLabel2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        dateLabel2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      
        durationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 140).isActive = true
        durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        durationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        durationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -640).isActive = true
      
    }
    
    // MARK: - Helper Methods
    func format(date: Date) -> String {
      return dateFormatter.string(from: date)
    }
    
    
    // MARK: TABLE VIEW DELEGATES
    
    // MARK: NAVIGATION
}

// MARK: EXTENSIONS
