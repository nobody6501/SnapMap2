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
    let user: String
    let message: String
    let coordinate: CLLocationCoordinate2D
    let image: UIImage?
    let comments: NSMutableArray?
    let uniqueID: String
    
    init(user: String, title: String, message: String, coordinate: CLLocationCoordinate2D, image: UIImage, comments: NSMutableArray, uniqueID: String) {
        self.title = title
        self.user = user
        self.message = message
        self.coordinate = coordinate
        self.image = image
        self.comments = comments
        self.uniqueID = uniqueID
        
        super.init()
    }
    
    var subtitle: String? {
        return user
    }
    
    func getImage() -> UIImage {
        return self.image!
    }
}