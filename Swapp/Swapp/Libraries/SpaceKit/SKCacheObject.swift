//
//  SKCacheObject.swift
//  SpaceKit
//
//  Created by Steliyan Hadzhidenev on 10/1/15.
//  Copyright © 2015 Steliyan Hadzhidenev. All rights reserved.
//

import UIKit


class SKCacheObject: NSObject, NSCoding {
    
    /// read only property to store the value of the object
    let value: AnyObject
    /// read only property to store the type of the value stored in the object
    let type: AnyObject
    /// read only property to store a unique key for the object
    let key: String?
    /// read only property to store the expiry time of the object
    let expiryDate: NSDate
    
    // MARK: - Override
    
    init(value: AnyObject?, type: Any, key: String?, date: NSDate?=nil) {
        
        var newValue: AnyObject? = nil
        
        /**
        *  check if the stored value is of type UIImage because, NSKeyedArchiver can't store it properly
        */
        if value is UIImage {
            
            // if it is UIImage convert it to NSData
            newValue = UIImageJPEGRepresentation((value as! UIImage), 1.0)
        } else {
            newValue = value
        }
        
        self.value = newValue!
        self.type = "\(type)"
        self.key = key!
        self.expiryDate = date ?? SKSettings.expiryDateForCache(expiryTime)
        
        super.init()
    }
    
    /**
     Method to return if a given object is expired
     
     - returns: True or False
     */
    func isExpired() -> Bool {
        
        let now = NSDate()
        
        return now.timeIntervalSinceNow > expiryDate.timeIntervalSinceNow
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        value = aDecoder.decodeObjectForKey("value")!
        type = aDecoder.decodeObjectForKey("type")!
        key = aDecoder.decodeObjectForKey("key") as? String
        expiryDate = aDecoder.decodeObjectForKey("expiryDate") as! NSDate
        
        super.init()
    }
    
    /**
     Method to encode cache object into a file
     
     - parameter aCoder: A NSCoder object
     */
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(value, forKey: "value")
        aCoder.encodeObject(type, forKey: "type")
        aCoder.encodeObject(key, forKey: "key")
        aCoder.encodeObject(expiryDate, forKey: "expiryDate")
    }
    
}