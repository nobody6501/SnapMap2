//
//  LoginViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 2/28/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var SnapMapTitle: UIImageView!
    @IBOutlet weak var guestLoginButton: UIButton!

    var clients = [NSManagedObject]()
    var identifier: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.hidden = true
        
        self.fetchClients()
        
        let loginView: FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            loginView.readPermissions = ["email"]
            // loginView.readPermissions = ["public_profile", "email", "user_friends"]
        }
        
        fetchOrCreateClient()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Core Data
    
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
    }
    
    // MARK: Facebook Login
    
    func fetchOrCreateClient(){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            var already_in_list = false
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
                return
            }
                
            else {
                print("fetched user: \(result)")
                
                if let id: NSString = result.valueForKey("id") as? NSString {
                    print("ID is: \(id)")
                    
                    for x in self.clients{
                        let clientid = x.valueForKey("id") as? NSString
                        if(id == clientid){
                            already_in_list = true
                        }
                    }
                    
                    if (!already_in_list){
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let managedContext = appDelegate.managedObjectContext
                        
                        let entity = NSEntityDescription.entityForName("Client", inManagedObjectContext: managedContext)
                        
                        let client = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                        
                        client.setValue(id, forKey: "id")
                        client.setValue(result.valueForKey("name"), forKey: "name")
                        client.setValue(false, forKey: "darkMode")
                        client.setValue(false, forKey: "allowPush")
                        client.setValue(100.0, forKey: "radius")
                    }
                    
                    self.identifier = id as String
                    print("identifier after settings is \(self.identifier!)")
                    
                }
                
                else {
                    print("ID is null")
                }
            }
            self.performSegueWithIdentifier("LoginSegue", sender: self)
        })
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            print("Error with FB login")
        }
            
        else if result.isCancelled {
            print("User cancelled login")
        }
        
        else {
            print("Logged In")
            if result.grantedPermissions.contains("email") {
                fetchClients()
                fetchOrCreateClient()
            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged Out")
    }
    
    // MARK: Guest Login
    
    @IBAction func guestLoginButtonAction(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Client", inManagedObjectContext: managedContext)
        
        let client = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        let id = "1"
        client.setValue(id, forKey: "id")
        client.setValue("Guest", forKey: "name")
        client.setValue(false, forKey: "darkMode")
        client.setValue(false, forKey: "allowPush")
        client.setValue(100.0, forKey: "radius")
        
        self.identifier = id as String
        print("identifier after settings is \(self.identifier!)")
        
        self.performSegueWithIdentifier("LoginSegue", sender: self)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (self.identifier == nil) {
            print("ID is nil in prepare for segue")
            return
        }
        
        if(segue.identifier == "LoginSegue"){
            let dvc = segue.destinationViewController as! TabBarViewController
            let settings = dvc.viewControllers![2] as! SettingsViewController
            let map = dvc.viewControllers![0] as! MapViewController
            let camera = dvc.viewControllers![1] as! CameraViewController
            dvc.id = self.identifier!
            settings.id = self.identifier!
            map.id = self.identifier!
            camera.id = self.identifier!
            
            print("identifier in segue = \(self.identifier!)")
        }
    }

}


