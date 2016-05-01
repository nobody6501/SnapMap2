//
//  PictureViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 4/30/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var gestureOutlet: UITapGestureRecognizer!
    
    var post: Post? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.imageView.image = post!.getImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch")
        performSegueWithIdentifier("showAnnotation", sender: self)
    }
    
    // Mark: Scroll View
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    // Mark: Gesture Recognizer
    
    @IBAction func tapGesture(sender: AnyObject) {
        print("tapGesture")
        performSegueWithIdentifier("showAnnotation", sender: self)
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        print("handleTap")
    }

}
