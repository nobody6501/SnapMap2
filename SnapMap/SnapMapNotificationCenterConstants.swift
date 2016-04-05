//
//  SnapMapNotificationCenter.swift
//  SnapMap
//
//  Created by Vanilla Gorilla on 4/5/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

struct SnapMapNotificationCenterConstants {
    static let TabBarColorProfileUpdatedName = "kTabBarColorProfileUpdatedName"
    static let RadiusProfileUpdatedName = "kRadiusProfileUpdatedName"
}

class SnapMapNotificationCenter: NSObject {
    
    class func postTabBarColorProfileUpdatedNotification() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(SnapMapNotificationCenterConstants.TabBarColorProfileUpdatedName, object: nil)
    }
    
    class func postRadiusUpdateNotification() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(SnapMapNotificationCenterConstants.RadiusProfileUpdatedName, object: nil)
    }
}
