//
//  AnnotationViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 4/25/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class AnnotationViewController: UIViewController {
    
    var post: Post? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postMessage: UILabel!
    @IBOutlet weak var postUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackgroundImage()
        
        self.navigationController?.navigationBar.hidden = false
        
        imageView.image = post!.getImage()
        postTitle.text = post!.title
        postMessage.text = post!.message
        postUserName.text = post!.user
        
    }
    
    override func viewDidAppear(animated: Bool) {
//        imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Helper Functions
    
    func setBackgroundImage () {
        let background = UIImage(named: "WhiteTexture.jpg")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
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
