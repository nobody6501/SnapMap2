//
//  AnnotationViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 4/25/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import CoreData

class AnnotationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postMessage: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    
    var post: Post? = nil
    var savedPost: NSManagedObject? = nil
    var comments: NSMutableArray? = nil
    var alertController: UIAlertController? = nil
    var commentBox: UITextField? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = false
        
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
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Comments"
    }
    
    @IBAction func addCommentButtonPressed(sender: AnyObject) {
        self.alertController = UIAlertController(title: "Enter your comment below", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let postAction = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            // TODO: error check against empty input
            
            self.comments!.addObject((self.commentBox?.text)!)
            self.fetchData()
            self.savedPost?.setValue(self.comments, forKey: "comments")
            
            do {
                try managedContext.save()
            } catch {
                // what to do if an error occurs?
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo) in AnnotationView::addComment()")
                abort()
            }

            print("comment posted")
            
            self.commentTableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            print("message cancelled")
        }
        
        self.alertController!.addAction(cancelAction)
        self.alertController!.addAction(postAction)
        
        self.alertController!.addTextFieldWithConfigurationHandler(configureCommentField)
        presentViewController(self.alertController!, animated: true, completion: nil)
    }
    
    func configureCommentField(textField: UITextField){
        textField.placeholder = "Comment..."
        commentBox = textField
    }
    
    // Mark: Core Data
    
    func fetchData () {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"Post")
        
        // TODO: Fetch by a unique identifier
        fetchRequest.predicate = NSPredicate(format: "title = %@", post!.title!)
        var fetchedPosts:[NSManagedObject]? = nil
        
        do {
            try fetchedPosts = managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if let results = fetchedPosts {
            savedPost = results[0]
        }
            
        else {
            print("Could not fetch")
        }

    }
    
    // Mark: Helper Functions

}
