import UIKit
import CoreData
import CoreLocation

class TrailsViewController: UITableViewController {
    
    // MARK: PROPERTIES
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController<Trail> = {
      let fetchRequest = NSFetchRequest<Trail>()

      let entity = Trail.entity()
      fetchRequest.entity = entity

//      let sortDescriptor = NSSortDescriptor(
//        key: "date",
//        ascending: true)
//      fetchRequest.sortDescriptors = [sortDescriptor]
      let sort1 = NSSortDescriptor(key: "paiva", ascending: true)
      let sort2 = NSSortDescriptor(key: "time", ascending: true)
      fetchRequest.sortDescriptors = [sort1, sort2]
        
      fetchRequest.fetchBatchSize = 20

      let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: self.managedObjectContext,
        sectionNameKeyPath: "time", /// category
        cacheName: "Trails")

      fetchedResultsController.delegate = self
      return fetchedResultsController
    }()
    
    // MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        navigationItem.rightBarButtonItem = editButtonItem /// Editing button
    }
    
    // MARK: FUNCTIONS
    func performFetch() {
      do {
        try fetchedResultsController.performFetch()
      } catch {
        fatalError("Error: updating \(error)")
      }
    }
    
    deinit {
      fetchedResultsController.delegate = nil
    }
    
    // MARK: Table View Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
      return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
          return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrailCell", for: indexPath) as! TrailCell

        let trail = fetchedResultsController.object(at: indexPath)
        cell.configure2(for: trail)

        return cell
    }
    
    // MARK: Navigation to the TrailDetailsVC
    
    /// ADD NAVIGATION
    
    
}

// MARK: - NSFetchedResultsController Delegate Extension
extension TrailsViewController: NSFetchedResultsControllerDelegate {
    
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerWillChangeContent")
    tableView.beginUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      print("*** NSFetchedResultsChangeInsert (object)")
      tableView.insertRows(at: [newIndexPath!], with: .fade)

    case .delete:
      print("*** NSFetchedResultsChangeDelete (object)")
      tableView.deleteRows(at: [indexPath!], with: .fade)

    case .update:
      print("*** NSFetchedResultsChangeUpdate (object)")
      if let cell = tableView.cellForRow(
        at: indexPath!) as? TrailCell {
        let trail = controller.object(
          at: indexPath!) as! Trail
        cell.configure2(for: trail)
      }

    case .move:
      print("*** NSFetchedResultsChangeMove (object)")
      tableView.deleteRows(at: [indexPath!], with: .fade)
      tableView.insertRows(at: [newIndexPath!], with: .fade)
      
    @unknown default:
      print("*** NSFetchedResults unknown type")
    }
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      print("*** NSFetchedResultsChangeInsert (section)")
      tableView.insertSections(
        IndexSet(integer: sectionIndex), with: .fade)
    case .delete:
      print("*** NSFetchedResultsChangeDelete (section)")
      tableView.deleteSections(
        IndexSet(integer: sectionIndex), with: .fade)
    case .update:
      print("*** NSFetchedResultsChangeUpdate (section)")
    case .move:
      print("*** NSFetchedResultsChangeMove (section)")
    @unknown default:
      print("*** NSFetchedResults unknown type")
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerDidChangeContent")
    tableView.endUpdates()
  }
}

