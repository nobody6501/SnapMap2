//
//  User.swift
//  SnapMap
//
//  Created by Martin Huang on 4/15/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation
import Firebase


class User {
    
    let root = Firebase(url:"https://intense-inferno-7933.firebaseio.com/")

    var uid: String?
    
    private static var cUser : User = User()
    
    static func currentUser() -> User{
        return cUser
    }
    
}