//
//  CameraViewController.swift
//  SnapMap
//
//  Created by Omar Mahmud on 4/1/16.
//  Copyright © 2016 cs378. All rights reserved.
//


import UIKit
import AVFoundation

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var originalphoto: UIImage? = nil

    @IBOutlet weak var anotherPicBtn: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    var ButtonRect: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        postBtn.hidden = true
        shareBtn.hidden = true
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
        shareBtn.hidden = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareToFB(sender: AnyObject){
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
