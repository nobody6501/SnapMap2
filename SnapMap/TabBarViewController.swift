//
//  TabBarViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 3/22/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import CoreData

class TabBarViewController: UITabBarController {
    
    var id: NSString? = nil
    var clients = [NSManagedObject]()
    var client: NSManagedObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.addNotificationObservers()
        self.updateColors()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notification Observer(s)
    
    func addNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TabBarViewController.updateColors), name:SnapMapNotificationCenterConstants.TabBarColorProfileUpdatedName , object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Private Functions
    
    func updateColors() {
        fetchClients()
        
        self.tabBar
        
        self.tabBar.translucent = true;
        
        if let darkMode = client?.valueForKey("darkMode") as? Bool {
            if darkMode {
                print("Dark Mode enabled")
                self.tabBar.barTintColor = .blackColor()
                self.tabBar.tintColor = .whiteColor()
            } else {
                self.tabBar.tintColor = .redColor()
                self.tabBar.barTintColor = .whiteColor()
            }
        }
        
        dispatch_async(dispatch_get_main_queue(),{
            self.view.layoutIfNeeded()
        })
    }
    

    func fetchClients() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"Client")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if let results = fetchedResults {
            clients = results
        }
        
        else {
            print("Could not fetch")
        }
        
        // Do any additional setup after loading the view.
        
        for x in clients {
            if let identifier: NSString = x.valueForKey("id") as? NSString{
                if(identifier == id){
                    print("Client found in Settings View")
                    client = x
                }
            }
        }
    }

}
