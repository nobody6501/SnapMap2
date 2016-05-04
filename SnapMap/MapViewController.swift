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
    @IBOutlet weak var settingsTab: UITabBarItem!
    
    let root = User.currentUser().root
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var regionRadius: CLLocationDistance = 1000
    var clients = [NSManagedObject]()
    var client: NSManagedObject? = nil
    var posts = [NSManagedObject]()
    var id: NSString? = nil
    var alertController: UIAlertController? = nil
    var messageBox: UITextField? = nil
    var titleBox: UITextField? = nil
    var uid = User.currentUser().uid
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    var otherUserLong:CLLocationDegrees!
    var otherUserLat:CLLocationDegrees!
    var postTitle : String!
    var postMessage : String!
    var otherImage : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.hidden = true

    }
    
    override func viewDidAppear(animated: Bool) {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        addNotificationObservers()
        updateMap()
        
        setNilMessage()
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(MapViewController.getOtherMessagePosts), userInfo: nil, repeats: true)
        
    }
    
    
    // MARK: Notification Observer(s)
    
    func addNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(MapViewController.updateMap), name: SnapMapNotificationCenterConstants.MapViewUpdatedName, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Location Services
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        longitude = location!.coordinate.longitude
        latitude = location!.coordinate.latitude
        updateCoordinates(latitude, long: longitude)
        
        mapView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height * 0.7)
        
        centerMapOnLocation(location!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: Core Data
    
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
            self.addAnnotation(post)
        }
    }
    
    // MARK: Map Annotation
    
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
                view.leftCalloutAccessoryView = UIImageView.init(image: resizeImage(annotation.getImage(), newWidth: 50))
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
    
    @IBAction func postMessage(sender: AnyObject) {
        
        self.alertController = UIAlertController(title: "Post a message to the world!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let postAction = UIAlertAction(title: "Post", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: managedContext)
            
            let post = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            post.setValue(self.client!.valueForKey("name") as? String, forKey: "user")
            post.setValue(self.titleBox!.text, forKey: "title")
            post.setValue(self.messageBox!.text, forKey: "message")
            post.setValue(UIImageJPEGRepresentation(UIImage(named: "iMessageIcon.png")!, 1), forKey: "image")
            post.setValue(self.location!.coordinate.latitude as Double, forKey: "lat")
            post.setValue(self.location!.coordinate.longitude as Double, forKey: "long")
            
            var messageText = self.messageBox!.text
            var postRoot = User.currentUser().root.childByAppendingPath("users").childByAppendingPath(User.currentUser().uid).childByAppendingPath("posts").childByAppendingPath("messages")
            var storeMessage : [String: String] = ["title" : self.titleBox!.text!,
                "message" : self.messageBox!.text!]

            postRoot.updateChildValues(storeMessage)
            
            self.updateCoordinates(self.location!.coordinate.latitude, long: self.location!.coordinate.longitude)

            
            do {
                try managedContext.save()
            } catch {
                // what to do if an error occurs?
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo) in CameraView::savePost()")
                abort()
            }
            
            self.updateMap()
            
            print("message posted")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            print("message cancelled")
        }
        
        self.alertController!.addAction(postAction)
        self.alertController!.addAction(cancelAction)
        
        self.alertController!.addTextFieldWithConfigurationHandler(configureTitleField)
        self.alertController!.addTextFieldWithConfigurationHandler(configureMessageField)
        
        presentViewController(self.alertController!, animated: true, completion: nil)
    }
    
    func configureTitleField(textField: UITextField){
        textField.placeholder = "Add a title..."
        titleBox = textField
    }
    
    func configureMessageField(textField: UITextField){
        textField.placeholder = "Add a message..."
        messageBox = textField
    }
    
    func addAnnotation(post: NSManagedObject) {
        print("user name: in addAnnotation: \(post.valueForKey("user") as! String)")
        let artwork = Post(user: post.valueForKey("user") as! String,
                           title: post.valueForKey("title") as! String,
                           message: post.valueForKey("message") as! String,
                           coordinate: CLLocationCoordinate2D(latitude: post.valueForKey("lat") as! Double, longitude: post.valueForKey("long") as! Double),
                           image: UIImage(data: (post.valueForKey("image") as? NSData)!)!)
        
        mapView.addAnnotation(artwork)
    }
    
    func getOtherMessagePosts() {
        
        root.childByAppendingPath("users").queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
            snapshot in
            print(snapshot.key)
        
        self.root.childByAppendingPath("users").childByAppendingPath(snapshot.key).childByAppendingPath("locations").observeEventType(.ChildAdded, withBlock: {
                location in
            //get the other location coordinates
                if(location.key == "latitude") {
                    self.otherUserLat = location.value as! CLLocationDegrees
                } else {
                    self.otherUserLong = location.value as! CLLocationDegrees
                }
            })
        self.root.childByAppendingPath("users").childByAppendingPath(snapshot.key).childByAppendingPath("posts").childByAppendingPath("messages").observeEventType(.ChildAdded, withBlock: { messages in
            //get the messages if they have any
            
                if(messages.key == "message") {
                    self.postMessage = messages.value as! String
                } else {
                    self.postTitle = messages.value as! String
                }
            
            })
            if((self.postTitle != nil || self.postMessage != nil) && (self.postMessage != "empty" || self.postTitle != "empty") ) {
                self.dropOthersPin(self.otherUserLat, long: self.otherUserLong)
            }
            self.postMessage = nil
            self.postTitle = nil
            self.root.childByAppendingPath("users").childByAppendingPath(snapshot.key).childByAppendingPath("posts").childByAppendingPath("image").observeEventType(.ChildAdded, withBlock: { image in
                //get the images if they have any
                
                if(image.key == "string") {
                    self.otherImage = image.value as! String
                }
                
            })
            
        })
    }
    

    
    //drop other pins
    func dropOthersPin (lat: CLLocationDegrees, long: CLLocationDegrees) {
        
        let location = CLLocationCoordinate2DMake(lat, long)        // Drop a pin
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = self.postTitle
        dropPin.subtitle=self.postMessage
        mapView.addAnnotation(dropPin)
//        print("DROP!")
    }
    
    //update coordinates
    func updateCoordinates(lat: CLLocationDegrees, long: CLLocationDegrees) {
        var coordinates : [String:CLLocationDegrees] = [
            "longitude": long,
            "latitude": lat
        ]
        
        let locationRoot = root!.childByAppendingPath("users").childByAppendingPath(self.uid).childByAppendingPath("locations")
        locationRoot.updateChildValues(coordinates)
    }
    
    //setup firebase to empty
    func setNilMessage() {
        
        var postRoot = root.childByAppendingPath("users").childByAppendingPath(User.currentUser().uid).childByAppendingPath("posts").childByAppendingPath("messages")
        var storeMessage : [String: String] = ["title" : "empty",
                                               "message" : "empty"]
        postRoot.setValue(storeMessage)
        
        var quoteString = ["string": "empty"]
        var storeImage = ["image": quoteString]
        var imageRoot = root.childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("posts")
        imageRoot.updateChildValues(storeImage)
        
    }
    
    
    // Mark: Map Update
    
    func updateMap() {
        self.locationManager.startUpdatingLocation()
        
        fetchData()
        
        dispatch_async(dispatch_get_main_queue(),{
            self.view.layoutIfNeeded()
        })
    }
    
}