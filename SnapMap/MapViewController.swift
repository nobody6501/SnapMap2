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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var messageTab: UITabBarItem!
    @IBOutlet weak var cameraTab: UITabBarItem!
    @IBOutlet weak var settingsTab: UITabBarItem!
    
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.hidden = true
//        UINavigationItem.setHidesBackButton()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        //
        //        var longitude = location!.coordinate.longitude
        //        var latitude = location!.coordinate.latitude
        //
        //        var coordinates : [String:CLLocationDegrees] = [
        //            "longitude": longitude,
        //            "latitude": latitude
        //        ]
        
        mapView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height * 0.7)
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
    }
    
}