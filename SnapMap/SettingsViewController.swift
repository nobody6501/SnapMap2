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

    @IBOutlet weak var allowPushSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    var clients = [NSManagedObject]()
    
    var id: NSString? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginView: FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.delegate = self
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //
        let fetchRequest = NSFetchRequest(entityName:"Client")
        
        //
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
        darkModeSwitch.addTarget(self, action: Selector("switchIsChanged:"), forControlEvents: UIControlEvents.ValueChanged)        // Do any additional setup after loading the view.
        for x in clients{
            print("id = \(id)")
            if let identifier: NSString = x.valueForKey("id") as? NSString{
            print("identifier = /(identifier)")
            if(identifier == id){
                if(x.valueForKey("darkMode") as! Bool == true){
                    print("found user")
                    darkModeSwitch.setOn(false, animated: false)
                }
                else{
                    print("user not found")
                    darkModeSwitch.setOn(true, animated: false)
                }
            }
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Logged In")

    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged Out")
        performSegueWithIdentifier("backtologin", sender: self)
    }
    
    
    func switchIsChanged(darkModeSwitch: UISwitch){
        if darkModeSwitch.on{
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            // Create the entity we want to save
            let entity =  NSEntityDescription.entityForName("Client", inManagedObjectContext: managedContext)
            
            let darkMode = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            
            // Set the attribute values
            darkMode.setValue(true, forKey: "darkMode")
            
            // Commit the changes.
            do {
                try managedContext.save()
            } catch {
                // what to do if an error occurs?
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
        else{
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            // Create the entity we want to save
            let entity =  NSEntityDescription.entityForName("Client", inManagedObjectContext: managedContext)
            
            let darkMode = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            
            // Set the attribute values
            darkMode.setValue(false, forKey: "darkMode")
            
            // Commit the changes.
            do {
                try managedContext.save()
            } catch {
                // what to do if an error occurs?
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
