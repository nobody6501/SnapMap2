//
//  MapView.swift
//  SnapMap
//
//  Created by Martin Huang on 3/20/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CoreData
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var messageBtn: UIButton!

    @IBOutlet weak var messageTab: UITabBarItem!
    @IBOutlet weak var cameraTab: UITabBarItem!
    @IBOutlet weak var settingsTab: UITabBarItem!
    
    let ROOT = Firebase(url:"https://intense-inferno-7933.firebaseio.com/")
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var regionRadius: CLLocationDistance = 1000
    var clients = [NSManagedObject]()
    var client: NSManagedObject? = nil
    var id: NSString? = nil
    var alertController: UIAlertController? = nil
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    var uid:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.hidden = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        fetchClients()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        addNotificationObservers()
        updateRadius()
        fbCurrentUserID()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        mapView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height * 0.7)
        
        centerMapOnLocation(location!)
        
        //get the cooridnates
        longitude = location!.coordinate.longitude
        latitude = location!.coordinate.latitude
        var coordinates : [String:CLLocationDegrees] = [
            "longitude": longitude,
            "latitude": latitude
        ]
        //store the coordinates for user
        let locationRoot = ROOT!.childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("locations")
        locationRoot.setValue(coordinates)
        
//        self.addMessageAnnotation("This is a comment")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
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
                    print("Client found in Settings View")
                    client = x
                }
            }
        }
        regionRadius = client?.valueForKey("radius") as! Double
        print("Region radius: \(regionRadius)")
    }
    
    // This gets called for every annotation you add to the map. Returns the view for a given annotation.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Post {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.pinTintColor = UIColor.redColor()
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                view.animatesDrop = true
                let imageView: UIImageView = UIImageView.init(image: resizeImage(annotation.postImage(), newWidth: 50))
                view.leftCalloutAccessoryView = imageView
            }
            return view
        }
        return nil
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func addMessageAnnotation(comment: String) {
        let artwork = Post(title: comment,
                           locationName: client?.valueForKey("name") as! String!,
                           discipline: "Message",
                           coordinate: CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude),
                           image: UIImage(named: "CityNight.jpg")!)
        
        mapView.addAnnotation(artwork)
        
    }
    
//    func addPictureAnnotation(image: UIImage, comment: String) {
//        let artwork = Post(title: comment,
//                           locationName: client?.valueForKey("name") as! String!,
//                           discipline: "Picture",
//                           coordinate: CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude))
//        
//        mapView.addAnnotation(artwork)
//        
//    }
    
    func updateRadius () {
        regionRadius = client?.valueForKey("radius") as! Double
        print("Region radius reset to: \(regionRadius)")
        
        self.locationManager.startUpdatingLocation()
        
        dispatch_async(dispatch_get_main_queue(),{
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func postMessage(sender: AnyObject) {
        self.alertController = UIAlertController(title: "Message", message: "Type your message", preferredStyle: UIAlertControllerStyle.Alert)
        
        let postAction = UIAlertAction(title: "Post", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            print("message posted")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            print("message cancelled")
        }
        
        self.alertController!.addAction(postAction)
        self.alertController!.addAction(cancelAction)
        
        self.alertController!.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Enter your message"
        }
        
        presentViewController(self.alertController!, animated: true, completion: nil)
        
    }
    
    // MARK: Notification Observer(s)
    
    func addNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(MapViewController.updateRadius), name:SnapMapNotificationCenterConstants.RadiusProfileUpdatedName , object: nil)
    }
    
    //get user's facebook UID and store in firebase
    func fbCurrentUserID() {
        let userRoot = ROOT!.childByAppendingPath("users")
        var fbRequest = FBSDKGraphRequest(graphPath:"/me/", parameters: nil);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error == nil {
                self.uid = result.valueForKey("id") as! String
                let currentUser = userRoot.childByAppendingPath(self.uid)
                currentUser.setValue(self.uid)
                
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
    
}