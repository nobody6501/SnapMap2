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
    var presentCamera = true
    var alertController: UIAlertController? = nil
    var id: NSString? = nil
    var clients = [NSManagedObject]()
    var client: NSManagedObject? = nil
    
    @IBOutlet weak var commentBox: UITextField!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var anotherPicBtn: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postOutlet: UILabel!
    @IBOutlet weak var resnapOutlet: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    
    var ButtonRect: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.hidden = true
        
        let background = UIImage(named: "BlackMetal.jpg")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        backgroundView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        shareBtn.hidden = true
        postBtn.hidden = true
        anotherPicBtn.hidden = true
        commentBox.delegate = self
        commentBox.hidden = true
        postOutlet.hidden = true
        commentBox.placeholder = "Add title..."
        
        addNotificationObservers()
        
        self.scrollView.frame = self.view.frame
        self.scrollView.contentSize = self.view.frame.size
        
        fetchClients()
        
        if(presentCamera){
            dispatch_async(dispatch_get_main_queue(), {
                if (UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil && UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil) {
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                    self.imagePicker.cameraCaptureMode = .Photo
                    self.imagePicker.modalPresentationStyle = .FullScreen
                }
            
                else {
                    print("Sorry no Camera")
                    return
                }
        
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            })
        }
        else{
            image.image = originalphoto
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        image.image = originalphoto
    }
    // MARK: Notification Observer(s)
    
    func addNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // Register for when the keyboard is shown.
        notificationCenter.addObserver(self, selector: #selector(CameraViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        // Register for when the keyboard is hidden.
        notificationCenter.addObserver(self, selector: #selector(CameraViewController.keyboardDidHide(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Camera
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        originalphoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        firstphoto = originalphoto
        image.image = originalphoto
        postBtn.hidden = false
        anotherPicBtn.hidden = false
        shareBtn.hidden = false
        commentBox.hidden = false
        postOutlet.hidden = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        anotherPicBtn.hidden = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func takeAnotherPhoto(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Location Services
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last        
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: Map Annotation
    
    @IBAction func postPhoto(sender: AnyObject) {
        
        if savePost() {
            self.alertController = UIAlertController(title: "Post Successful!", message: "Nice shot!", preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        else {
            self.alertController = UIAlertController(title: "Post Failed!", message: "womp womp", preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in self.commentBox.text = ""})
        self.alertController!.addAction(okAction)
        
        presentViewController(self.alertController!, animated: true, completion: nil)
    }

    func savePost() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: managedContext)
        let post = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        post.setValue(client!.valueForKey("name") as? String, forKey: "user")
        post.setValue(commentBox!.text, forKey: "title")
        post.setValue(commentBox!.text, forKey: "message")
        post.setValue(UIImageJPEGRepresentation(originalphoto!, 1), forKey: "image")
        post.setValue(location!.coordinate.latitude as Double, forKey: "lat")
        post.setValue(location!.coordinate.longitude as Double, forKey: "long")
                
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
    
    // MARK: Facebook share
    
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
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //        self.view.endEditing(true)
    }
 
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // Get keyboard frame from notification object.
        let info:NSDictionary = notification.userInfo!
        var keyboardFrame = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        // Pad for some space between the field and the keyboard.
        let pad:CGFloat = 5.0;
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            // Set inset bottom, which will cause the scroll view to move up.
            self.scrollView.contentInset.bottom = keyboardFrame.size.height + pad
            self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height + pad, 0.0);
            }, completion: nil)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            // Restore starting insets.
            self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            }, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "editsegue"){
            let dvc = segue.destinationViewController as! EditViewController
            dvc.beginImage = CIImage(image: firstphoto!)
            dvc.cvc = self
        }
    }
    
}