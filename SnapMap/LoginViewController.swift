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
    var clients = [NSManagedObject]()
    var identifier: NSString? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SnapMapTitle.image = UIImage(named: "SnapMapTitle.jpg")!
//        SnapMapTitle.backgroundColor = UIColor(patternImage: UIImage(named: "SnapMapTitle.jpg")!)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBackground.jpg")!)
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let loginView: FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.delegate = self
            fetchClients()
            createNewClient()
            performSegueWithIdentifier("LoginSegue", sender: self)
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
            fetchClients()
            createNewClient()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchClients(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
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
    }
    
    func createNewClient(){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            var already_in_list = false
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                
                if let id: NSString = result.valueForKey("id") as? NSString {
                    print("ID is: \(id)")
                    for x in self.clients{
                        let clientid = x.valueForKey("id") as? NSString
                        if(id == clientid){
                            already_in_list = true
                        }
                    }
                    if(!already_in_list){
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let managedContext = appDelegate.managedObjectContext
                        
                        let entity = NSEntityDescription.entityForName("Client", inManagedObjectContext: managedContext)
                        
                        let client = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                        
                        client.setValue(id, forKey: "id")
                        client.setValue(false, forKey: "darkMode")
                        client.setValue(false, forKey: "allowPush")
                        client.setValue(10.0, forKey: "radius")
                    }
                    print("id is \(id)")
                    self.identifier = id
                    print("identifier not segue is \(self.identifier!)")
                } else {
                    print("ID es null")
                }
                
                
            }
        })
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Logged In")
        if(error != nil)
        {
            //There was an error
        }
        else if result.isCancelled
        {
            //Cancelled
        }
        else
        {
         if result.grantedPermissions.contains("email")
         {
            fetchClients()
            createNewClient()
            performSegueWithIdentifier("LoginSegue", sender: self)            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged Out")
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "LoginSegue"){
            let dvc = segue.destinationViewController as! TabBarViewController
            let settings = dvc.viewControllers![3] as! SettingsViewController
            settings.id = self.identifier
            print("identifier segue = \(self.identifier)")
        }
    }
}


