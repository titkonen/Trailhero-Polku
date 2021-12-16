import UIKit
import CoreData
import CoreLocation /// Voi olla ylimääräinen

//MARK: CLASS OUTSIDE PROPERTY
private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMMM dd, YYYY HH:mm"
  return formatter
}()

class TrailDetailViewController: UIViewController {
 
    //MARK: OUTLETS
    //MARK: UI FILEPRIVATE PROPERTIES
    fileprivate lazy var dateLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
        label.textAlignment = .left
        return label
    }()
    
    fileprivate lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
        label.text = "This is time !!!"
        label.textAlignment = .left
        return label
    }()
    
    fileprivate lazy var addPhotoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Photo", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.frame = CGRect(x: 15, y: 450, width: 100, height: 50)
        return button
    }()
    
    fileprivate lazy var trailImageView: UIImageView = {
        let kuvapaikka = UIImageView()
        kuvapaikka.backgroundColor = .gray
        kuvapaikka.frame = CGRect(x: 32, y: 230, width: 320, height: 200)
        kuvapaikka.layer.cornerRadius = 12
        return kuvapaikka
    }()
    
    //MARK: PROPERTIES
    var managedObjectContext: NSManagedObjectContext! /// Passing coredata context
    var date = Date()
    var image: UIImage?
    
    /*var trailDataCell: Trail! {
        didSet {
            durationLabel.text = String(trailDataCell.time)
            //dateLabel2.text = format(date: date)
            dateLabel2.text = dateFormatter.string(from: trailDataCell?.paiva ?? Date())
        }
    }*/
    
    var trailToEdit: Trail? {
        didSet {
            if let trail = trailToEdit {
                durationLabel.text = "loppuaika" /// durationLabel.text = String(trailDataCell.time)
                dateLabel2.text = dateFormatter.string(from: trail.paiva ?? Date())///dateFormatter.string(from: trailDataCell?.paiva ?? Date())
            }
        }
    }
    
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        view.backgroundColor = .black

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonPressed), for: .touchUpInside)
        
        if let trail = trailToEdit {
            title = "Edit trail"
            /// IF there is photo -> Show photo
            if trail.hasPhoto {
              if let theImage = trail.photoImage2 {
                show(image: theImage)
              }
            }
        }
        
    }
    
    //MARK: IMAGE FUNCTIONS
    func show(image: UIImage) {
        trailImageView.image = image
        trailImageView.isHidden = false
        //addPhotoLabel.text = ""
       // imageHeight.constant = 260
       // tableView.reloadData()
    }
    
    //MARK: @objc FUNCTIONS
    @objc func addPhotoButtonPressed() {
        print("addPhotoButtonPressed")
        pickPhoto()
    }
    
    @objc func doneButtonPressed() {
        print("doneButtonPressed")
        
        guard let mainView = navigationController?.parent?.view else {
            return
        }
        
        let hudView = HudView.hud(inView: mainView, animated: true)
        
        let trail: Trail
        if let temp = trailToEdit {
          hudView.text = "Updated"
            trail = temp
        } else {
          hudView.text = "Tagged"
            trail = Trail(context: managedObjectContext)
            trail.photoIDtrail = nil /// Need to be so it won't overwrite when saving photo.
        }
        
        // MARK: Save image
        if let image = image {
          // 1
          if !trail.hasPhoto {
              trail.photoIDtrail = Trail.nextPhotoID() as NSNumber
            print("New nextPhotoIDtrail writed")
          }
          // 2
          if let data = image.jpegData(compressionQuality: 0.5) {
            // 3
            do {
              try data.write(to: trail.photoURLtrail, options: .atomic)
                print("writing succeed")
            } catch {
              print("Error writing file: \(error)")
            }
          }
        }
        
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
              hudView.hide()
              self.navigationController?.popViewController(animated: true)
            }
          } catch {
            fatalError("Error: saving content to coredata \(error)")
        }
        
    }
    
    //MARK: FUNCTIONS
    fileprivate func setupUI() {
        view.addSubview(dateLabel2)
        view.addSubview(durationLabel)
        view.addSubview(trailImageView)
        view.addSubview(addPhotoButton)
        
        dateLabel2.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        dateLabel2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        dateLabel2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      
        durationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 140).isActive = true
        durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        durationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        durationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -640).isActive = true
        
        trailImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 240).isActive = true
        trailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trailImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        trailImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -440).isActive = true
        
        addPhotoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 490).isActive = true
        addPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        addPhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        addPhotoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -400).isActive = true
      
    }
    
    // MARK: - Helper Methods
    func format(date: Date) -> String {
      return dateFormatter.string(from: date)
    }
    
    
    // MARK: TABLE VIEW DELEGATES
    
    // MARK: NAVIGATION
}

// MARK: EXTENSIONS

// MARK: EXTENSION FOR ADDING PHOTOS
extension TrailDetailViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // MARK: - Image Helper Methods
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        showPhotoMenu()
      } else {
        choosePhotoFromLibrary()
      }
    }

    func showPhotoMenu() {
      let alert = UIAlertController(
        title: nil,
        message: nil,
        preferredStyle: .actionSheet)

      let actCancel = UIAlertAction(
        title: "Cancel",
        style: .cancel,
        handler: nil)
      alert.addAction(actCancel)

      let actPhoto = UIAlertAction(
        title: "Take Photo",
        style: .default) { _ in
        self.takePhotoWithCamera()
      }
        
      alert.addAction(actPhoto)

      let actLibrary = UIAlertAction(
        title: "Choose From Library",
        style: .default) { _ in
          self.choosePhotoFromLibrary()
        }
      alert.addAction(actLibrary)

      present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Delegates
    ///This is for showing photo in view
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
          if let theImage = image {
            show(image: theImage) /// Calls show photo function
          }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
