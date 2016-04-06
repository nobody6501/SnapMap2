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

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var imagePicker = UIImagePickerController()
    var originalphoto: UIImage? = nil
    var alertController: UIAlertController? = nil
    
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil
    
    @IBOutlet weak var commentBox: UITextField!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var anotherPicBtn: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    
    var ButtonRect: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        locationManager.delegate = self
//        locationManager.requestAlwaysAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
        
        shareBtn.hidden = true
        postBtn.hidden = true
        anotherPicBtn.hidden = true
        commentBox.delegate = self
        commentBox.hidden = true
        commentBox.placeholder = "Add comment..."
        if (UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil && UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = .Photo
            imagePicker.modalPresentationStyle = .FullScreen
        }
        else{
            print("Sorry no Camera")
        }
        
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        originalphoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        image.image = originalphoto
        postBtn.hidden = false
        anotherPicBtn.hidden = false
        shareBtn.hidden = false
        commentBox.hidden = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        anotherPicBtn.hidden = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareToFB(sender: AnyObject) {
        let photo: FBSDKSharePhoto = FBSDKSharePhoto()
        photo.image = originalphoto
        photo.userGenerated = true
        let content: FBSDKSharePhotoContent = FBSDKSharePhotoContent()
        content.photos = [photo]
        
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
    
    @IBAction func takeAnotherPhoto(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func postPhoto(sender: AnyObject) {
        self.alertController = UIAlertController(title: "Post Successful!", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in self.commentBox.text = ""
        })
        
        self.alertController!.addAction(okAction)
        
        presentViewController(self.alertController!, animated: true, completion: nil)
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        location = locations.last        
//        self.locationManager.stopUpdatingLocation()
//    }
    
    /*  // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     if(segue.identifier == "confirmationsegue"){
     let dvc = segue.destinationViewController as! PhotoConfirmationViewController
     dvc.originalphoto = self.photo
     
     }
     }*/
    
    
}