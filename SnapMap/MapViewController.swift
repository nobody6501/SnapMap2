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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var messageBtn: UIButton!

    @IBOutlet weak var messageTab: UITabBarItem!
    @IBOutlet weak var cameraTab: UITabBarItem!
    @IBOutlet weak var settingsTab: UITabBarItem!
    
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var regionRadius: CLLocationDistance = 1000
    var clients = [NSManagedObject]()
    var client: NSManagedObject? = nil
    var posts = [NSManagedObject]()
    var id: NSString? = nil
    var alertController: UIAlertController? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.hidden = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
                
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        addNotificationObservers()
        updateMap()
    }
    
    // MARK: Notification Observer(s)
    
    func addNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(MapViewController.updateMap), name: SnapMapNotificationCenterConstants.MapViewUpdatedName, object: nil)
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
        
//        self.addMessageAnnotation("This is a comment")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func fetchData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchClients = NSFetchRequest(entityName:"Client")
        var fetchedClients:[NSManagedObject]? = nil
        
        do {
            try fetchedClients = managedContext.executeFetchRequest(fetchClients) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if let results = fetchedClients {
            clients = results
        }
        
        else {
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
        
        let fetchPosts = NSFetchRequest(entityName:"Post")
        var fetchedPosts:[NSManagedObject]? = nil
        
        do {
            try fetchedPosts = managedContext.executeFetchRequest(fetchPosts) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if let results = fetchedPosts {
            posts = results
        }
        
        else {
            print("Could not fetch")
        }
        
        for post in posts {
            let artwork = Post(user: post.valueForKey("user") as! String,
                                title: post.valueForKey("title") as! String,
                                message: post.valueForKey("message") as! String,
                                coordinate: CLLocationCoordinate2D(latitude: post.valueForKey("lat") as! Double, longitude: post.valueForKey("long") as! Double),
                                image: UIImage(data: (post.valueForKey("image") as? NSData)!)!)
            
            mapView.addAnnotation(artwork)
        }
    }
    
    // This gets called for every annotation you add to the map. Returns the view for a given annotation.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Post {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            
            else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.pinTintColor = UIColor.redColor()
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                view.animatesDrop = true
                view.leftCalloutAccessoryView = UIImageView.init(image: resizeImage(annotation.postImage(), newWidth: 50))
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
    
//    func addMessageAnnotation(comment: String) {
//        let artwork = Post(user: "user",
//                           title: comment,
//                           message: "message",
//                           coordinate: CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!),
//                           image: UIImage(named: "CityNight.jpg")!)
//        
//        mapView.addAnnotation(artwork)
//    }
    
    func addAnnotation(post: NSManagedObject) {
        let artwork = Post(user: post.valueForKey("user") as! String,
                           title: post.valueForKey("title") as! String,
                           message: post.valueForKey("message") as! String,
                           coordinate: CLLocationCoordinate2D(latitude: post.valueForKey("lat") as! Double, longitude: post.valueForKey("long") as! Double),
                           image: UIImage(data: (post.valueForKey("image") as? NSData)!)!)
        
        mapView.addAnnotation(artwork)
    }
    
    func updateMap() {
        fetchData()
        
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
    
}