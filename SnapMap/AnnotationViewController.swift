//
//  AnnotationViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 4/25/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class AnnotationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var post: Post? = nil
    var comments: NSMutableArray? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postMessage: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = false
        
        self.setBackgroundImage()
        imageView.image = post!.getImage()
        postTitle.text = post!.title
        postMessage.text = post!.message
        comments = post!.comments
        
        self.commentTableView.delegate = self
        self.commentTableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Mark: Comments Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        cell.textLabel!.text = self.comments![indexPath.row] as? String
//        cell.detailTextLabel!.text = candidate.valueForKey("party") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Comments"
    }
    
    @IBAction func addCommentButtonPressed(sender: AnyObject) {
        
    }
    
    
    // Mark: Helper Functions
    
    func setBackgroundImage () {
        let background = UIImage(named: "GrayTexture.png")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }


}
