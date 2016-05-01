//
//  PictureViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 4/30/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
//    @IBOutlet var gestureOutlet: UITapGestureRecognizer!
    
    var post: Post? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = post!.getImage()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch")
        performSegueWithIdentifier("showAnnotation", sender: self)
    }
    
//    @IBAction func tapGesture(sender: AnyObject) {
//        print("tapGesture")
//        performSegueWithIdentifier("showAnnotation", sender: self)
//    }
//    
//    func handleTap(sender: UITapGestureRecognizer? = nil) {
//        // handling code
//        print("handleTap")
//    }

}
