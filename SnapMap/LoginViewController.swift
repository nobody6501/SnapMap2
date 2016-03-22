//
//  LoginViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 2/28/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var SnapMapTitle: UIImageView!
    
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
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            performSegueWithIdentifier("LoginSegue", sender: self)            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged Out")
    }
}


