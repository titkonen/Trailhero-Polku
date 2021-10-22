import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: PROPERTIES
    var window: UIWindow?

    // MARK: CORE DATA STACK
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MyLocations")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext = persistentContainer.viewContext

    // MARK: CORE DATA SAVING SUPPORT
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: FUNCTIONS -> Handling the Tab navigation
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let tabController = window!.rootViewController as! UITabBarController
         if let tabViewControllers = tabController.viewControllers {
            // First tab
             var navController = tabViewControllers[0] as! UINavigationController
             let controller1 = navController.viewControllers.first as! CurrentLocationViewController
             controller1.managedObjectContext = managedObjectContext
             // Second tab
             navController = tabViewControllers[1] as! UINavigationController
             let controller2 = navController.viewControllers.first as! LocationsViewController
             controller2.managedObjectContext = managedObjectContext
            // Third tab
            navController = tabViewControllers[2] as! UINavigationController
            let controller3 = navController.viewControllers.first as! MapViewController
            controller3.managedObjectContext = managedObjectContext
            // 4 tab
            navController = tabViewControllers[3] as! UINavigationController
            let controller4 = navController.viewControllers.first as! TrailsViewController
            controller4.managedObjectContext = managedObjectContext
         }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveContext()
    }

}

