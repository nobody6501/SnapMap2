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
    
    let locationName: String?
    let title: String?
    let message: String
    let coordinate: CLLocationCoordinate2D
    let image: UIImage?
    
    init(user: String, title: String, message: String, coordinate: CLLocationCoordinate2D, image: UIImage) {
        self.locationName = user
        self.title = title
        self.message = message
        self.coordinate = coordinate
        self.image = image
        
        super.init()
    }
    
    func postImage() ->  UIImage {
        return self.image!
    }
}