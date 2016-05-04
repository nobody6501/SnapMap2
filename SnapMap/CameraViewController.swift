//
//  CameraViewController.swift
//  SnapMap
//
//  Created by Omar Mahmud on 4/1/16.
//  Copyright © 2016 cs378. All rights reserved.
//


import UIKit
import AVFoundation
import MapKit
import CoreData

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var imagePicker = UIImagePickerController()
    var originalphoto: UIImage? = nil
    var firstphoto: UIImage? = nil
    var alertController: UIAlertController? = nil
    var id: NSString? = nil
    var clients = [NSManagedObject]()
    var client: NSManagedObject? = nil
    var ButtonRect: CGRect!
    var saving = false
    var presentCamera = true
    
    @IBOutlet weak var titleBox: UITextField!
    @IBOutlet weak var commentBox: UITextField!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changeFilterOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        titleBox.delegate = self
        titleBox.placeholder = "Add title..."
        commentBox.delegate = self
        commentBox.placeholder = "Add comment..."
        
        showOrHideFields(true)
        
        addNotificationObservers()
        
        self.scrollView.frame = self.view.frame
        self.scrollView.contentSize = self.view.frame.size
        
        fetchClients()
        
        if (UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil && UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = .Photo
            imagePicker.modalPresentationStyle = .FullScreen
        }
            
        else {
            print("Sorry no Camera")
            return
        }
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!saving) {
            titleBox.placeholder = "Add title..."
            commentBox.placeholder = "Add comment..."
            showOrHideFields(true)
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: Notification Observer(s)
    
    func addNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // Register for when the keyboard is shown.
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        // Register for when the keyboard is hidden.
        notificationCenter.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: Camera
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        saving = true
        originalphoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        firstphoto = originalphoto
        performSegueWithIdentifier("showFilterView", sender: self)
        image.image = originalphoto
        showOrHideFields(false)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("showMap", sender: self)
    }
    
    @IBAction func cancelPost(sender: AnyObject) {
        saving = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Location Services
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last        
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: Map Annotation
    
    @IBAction func postPhoto(sender: AnyObject) {
        
        let returnToMap = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.commentBox.text = ""
            self.titleBox.text = ""
            SnapMapNotificationCenter.mapViewUpdateNotification()
            self.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("showMap", sender: self)
        })
        
        let retakePhoto = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            SnapMapNotificationCenter.mapViewUpdateNotification()
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        // Enforce titles to make sure the callouts on map annotations work
        if self.titleBox.text == "" {
            self.alertController = UIAlertController(title: "Error", message: "Your snap must have a title.", preferredStyle: UIAlertControllerStyle.Alert)
            self.alertController!.addAction(retakePhoto)
        }
        
        else if savePost() {
            self.alertController = UIAlertController(title: "Post Successful", message: "Nice shot!", preferredStyle: UIAlertControllerStyle.Alert)
            self.alertController!.addAction(returnToMap)
        }
        
        else {
            self.alertController = UIAlertController(title: "Post Failed!", message: "womp womp", preferredStyle: UIAlertControllerStyle.Alert)
            self.alertController!.addAction(retakePhoto)
        }
        
        presentViewController(self.alertController!, animated: true, completion: nil)
        saving = false
    }

    func savePost() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: managedContext)
        let post = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        post.setValue(client!.valueForKey("name") as? String, forKey: "user")
        post.setValue(titleBox!.text, forKey: "title")
        post.setValue(commentBox!.text, forKey: "message")
        post.setValue(UIImageJPEGRepresentation(originalphoto!, 1), forKey: "image")
        post.setValue(location!.coordinate.latitude as Double, forKey: "lat")
        post.setValue(location!.coordinate.longitude as Double, forKey: "long")
        let comments: NSMutableArray = []
        post.setValue(comments, forKey: "comments")
                
        do {
            try managedContext.save()
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo) in CameraView::savePost()")
            return false
        }
        
        SnapMapNotificationCenter.mapViewUpdateNotification()
        
        return true
    }
    
    // MARK: Facebook Share
    
    @IBAction func shareToFB(sender: AnyObject) {
        
        if client?.valueForKey("id") as! String == "1" {
            self.alertController = UIAlertController(title: "You must be logged in to share!", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in self.commentBox.text = ""})
            self.alertController!.addAction(okAction)
            presentViewController(self.alertController!, animated: true, completion: nil)
        }
        
        else {
            let photo: FBSDKSharePhoto = FBSDKSharePhoto()
            photo.image = originalphoto
            photo.userGenerated = true
            let content: FBSDKSharePhotoContent = FBSDKSharePhotoContent()
            content.photos = [photo]
        
            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
        }
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
        } else {
            print("Could not fetch")
        }
        
        for x in clients {
            if let identifier: NSString = x.valueForKey("id") as? NSString{
                if(identifier == id){
                    print("Client found in Camera View")
                    client = x
                }
            }
        }
    }
    
    // MARK: - Keyboard
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // Get keyboard frame from notification object.
        let info: NSDictionary = notification.userInfo!
        var keyboardFrame = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            // Set inset bottom, which will cause the scroll view to move up.
            self.scrollView.contentInset.bottom = keyboardFrame.size.height
            self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height, 0.0);
            }, completion: nil)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            // Restore starting insets.
            self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            }, completion: nil)
    }
    
    // Mark: Navigation:
    
    @IBAction func unwindToCameraView(segue: UIStoryboardSegue) {}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showFilterView"){
            let dvc = segue.destinationViewController as! AddFilterViewController
            dvc.orientation = firstphoto!.imageOrientation
            dvc.beginImage = CIImage(image: firstphoto!)
            dvc.cvc = self
        }
    }
    
    @IBAction func changeFilter(sender: AnyObject) {
        self.performSegueWithIdentifier("showFilterView", sender: self)
    }

    // Mark: Helper Functions
    
    func showOrHideFields (hide: Bool) {
        shareBtn.hidden = hide
        postBtn.hidden = hide
        cancelBtn.hidden = hide
        commentBox.hidden = hide
        titleBox.hidden = hide
        image.hidden = hide
        changeFilterOutlet.hidden = hide
    }
    
}