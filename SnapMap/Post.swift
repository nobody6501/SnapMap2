//
//  Post.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 4/5/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class Post: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let image: UIImage?
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, image: UIImage) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.image = image
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    func postImage() ->  UIImage {
        return self.image!
    }
}