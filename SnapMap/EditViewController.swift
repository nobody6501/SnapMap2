//
//  EditiViewController.swift
//  SnapMap
//
//  Created by Omar Mahmud on 4/29/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var myImage: UIImageView!
    var pickerData: [String] = [String]()
    var beginImage: CIImage? = nil
    var newImage: UIImage? = nil
    var context: CIContext? = nil
    var cvc: CameraViewController? = nil
    var orientation: UIImageOrientation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.hidden = false
        
        self.navigationItem.title = "Adding Filters"
        
        self.picker.delegate = self
        self.picker.dataSource = self
        context = CIContext(options: nil)
        
        pickerData = ["None", "Black and White", "Sepia", "Invert", "Cool", "Comic", "Edges", "Sketch"]
        
        pickerView(picker, didSelectRow: 0, inComponent: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        cvc!.image.image = newImage
        self.navigationItem.title = ""
    }
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
            /*let filter = CIFilter(name: "CIPhotoEffectMono")
             filter?.setValue(beginImage, forKey: kCIInputImageKey)
             //filter?.setValue(0.9, forKey: kCIInputIntensityKey)
             
             let cgimage = context!.createCGImage((filter?.outputImage)!, fromRect: (filter?.outputImage!.extent)!)*/
            let cgimage = context!.createCGImage(beginImage!, fromRect: beginImage!.extent)
            newImage = UIImage(CGImage: cgimage, scale: CGFloat(1.0), orientation: orientation!)
            self.myImage.image = newImage
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
    
    func makePhotoFilter(nameOfFilter: String){
        let filter = CIFilter(name: nameOfFilter)
        filter?.setValue(beginImage, forKey: kCIInputImageKey)
        
        let cgimage = context!.createCGImage((filter?.outputImage)!, fromRect: (filter?.outputImage!.extent)!)
        newImage = UIImage(CGImage: cgimage, scale: CGFloat(1.0), orientation: orientation!)
        self.myImage.image = newImage
    }
    
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        cvc!.originalphoto = newImage
        cvc!.presentCamera = false
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //if(segue.identifier == "backtocamera"){
            let dvc = segue.destinationViewController as! CameraViewController
            dvc.originalphoto = newImage
            dvc.presentCamera = false
        //}
    }
    

}
