//
//  AddFilterViewController.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 5/3/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class AddFilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var filteredImageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerData: [String] = [String]()
    var beginImage: CIImage? = nil
    var filteredImage: UIImage? = nil
    var context: CIContext? = nil
    var cvc: CameraViewController? = nil
    var orientation: UIImageOrientation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.title = "Add Filter"
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(AddFilterViewController.addFilter))
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        context = CIContext(options: nil)
        
        pickerData = ["None", "Black and White", "Sepia", "Invert", "Cool", "Comic", "Edges", "Sketch"]
        
        pickerView(pickerView, didSelectRow: 0, inComponent: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        cvc!.image.image = filteredImage
        self.navigationItem.title = ""
    }
    
    // Mark: Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let title = pickerData[row]
        if(title == "Sepia"){
            makePhotoFilter("CISepiaTone")
            
        }
        else if(title == "None"){
            let cgimage = context!.createCGImage(beginImage!, fromRect: beginImage!.extent)
            filteredImage = UIImage(CGImage: cgimage, scale: CGFloat(1.0), orientation: orientation!)
            self.filteredImageView.image = filteredImage
        }
        else if(title == "Black and White"){
            makePhotoFilter("CIPhotoEffectMono")
        }
        else if(title == "Invert"){
            makePhotoFilter("CIColorInvert")
        }
        else if(title == "Cool"){
            makePhotoFilter("CIPhotoEffectProcess")
        }
        else if(title == "Comic"){
            makePhotoFilter("CIComicEffect")
        }
        else if(title == "Edges"){
            makePhotoFilter("CIEdges")
        }
        else if(title == "Sketch"){
            makePhotoFilter("CILineOverlay")
        }
    }
    
    // Mark: Add Image Filter
    
    func makePhotoFilter(nameOfFilter: String){
        let filter = CIFilter(name: nameOfFilter)
        filter?.setValue(beginImage, forKey: kCIInputImageKey)
        
        let cgimage = context!.createCGImage((filter?.outputImage)!, fromRect: (filter?.outputImage!.extent)!)
        filteredImage = UIImage(CGImage: cgimage, scale: CGFloat(1.0), orientation: orientation!)
        self.filteredImageView.image = filteredImage
    }
    
    // MARK: Navigation
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        cvc!.originalphoto = filteredImage
        cvc!.presentCamera = false
    }
    
    func addFilter () {
        performSegueWithIdentifier("showCameraView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "showCameraView") {
            let dvc = segue.destinationViewController as! CameraViewController
            dvc.originalphoto = filteredImage
            dvc.presentCamera = false
        }
        
    }

}