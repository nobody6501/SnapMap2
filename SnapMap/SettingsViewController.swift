//
//  SettingsViewController.swift
//  SnapMap
//
//  Created by Omar Mahmud on 3/23/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, FBSDKLoginButtonDelegate{

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var radius: UITextField!
    
    var id: NSString? = nil
    var client: NSManagedObject? = nil
    var clients = [NSManagedObject]()
    var alertController: UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "CityNight.jpg")!)
        
        let loginView: FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.delegate = self
        
        fetchClients()
        

        darkModeSwitch.setOn(client?.valueForKey("darkMode") as! Bool, animated: true)
        radius.text = String((client?.valueForKey("radius"))!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Facebook Login/Logout
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Logged In")
        performSegueWithIdentifier("backtologin", sender: self)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged Out")
        performSegueWithIdentifier("backtologin", sender: self)
    }
    
    // MARK: Update User Settings
    
    @IBAction func darkModeChanged(sender: AnyObject) {
        print("Saving Dark mode")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        // Set the attribute values
        client?.setValue(darkModeSwitch.on, forKey: "darkMode")
        
        // Commit the changes.
        do {
            try managedContext.save()
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        SnapMapNotificationCenter.postTabBarColorProfileUpdatedNotification()
    }
    
    @IBAction func radiusSet(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        print("Saving Radius")
        
        // Set the attribute values
        
        // TODO: enforce restrictions on radius
        
        client?.setValue(Double(radius.text!), forKey: "radius")
        
        // Commit the changes.
        do {
            try managedContext.save()
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        SnapMapNotificationCenter.mapViewUpdateNotification()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        view.endEditing(true)
    }
    
    // MARK: Core Data
    
    func fetchClients() {
        print("ID in SettingsView = \((id)!)S")

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
        } else {
            print("Could not fetch")
        }
        
        for x in clients {
            if let identifier: NSString = x.valueForKey("id") as? NSString{
                if(identifier == id){
                    print("Client found in Settings View")
                    client = x
                }
            }
        }
    }

    @IBAction func aboutButtonPressed(sender: AnyObject) {
        self.alertController = UIAlertController(title: "iOS Spring 2016 Project", message: "Group 15", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in print("")})
        self.alertController!.addAction(okAction)
    
        presentViewController(self.alertController!, animated: true, completion: nil)
    }
}
