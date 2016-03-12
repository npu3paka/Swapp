//
//  SpaceKitSettings.swift
//  SpaceKit
//
//  Created by Steliyan Hadzhidenev on 9/30/15.
//  Copyright © 2015 Steliyan Hadzhidenev. All rights reserved.
//

import Foundation

/**
 Enum to indicate the live time of each time in the cache
 
 - Never:   option to never expire the cache object
 - EveryDay: option to expire at the end of the day
 - EveryWeek: option to expiry after a week
 - EveryMonth: option to set the expiry date each month
 */
enum CacheExpiryTime {
    case Never
    case EveryDay
    case EveryWeek
    case EveryMonth
    case Seconds(NSTimeInterval)
}

/// global property to hold the expire time of each cache object. By default it is set to .Never
var expiryTime: CacheExpiryTime = .Never

class SKSettings {
    
    
    
    /**
     Method to return a date when the cache will expire
     
     - parameter expiry: A parameter of type CacheExpiryTime to indicate the live time of a cache object
     
     - returns: Date when the cache object will expire
     */
    class func expiryDateForCache(expiry: CacheExpiryTime) -> NSDate {
        
        switch expiry {
            
        case .Never:
            
            return NSDate.distantFuture()
        case .EveryDay:
            
            return NSDate().endOfDay!
        case .EveryWeek:
            
            return SKSettings.dateAfterAPeriodOfTime(daysPeriod: 7)
        case .EveryMonth:
            
            return SKSettings.dateAfterAPeriodOfTime(daysPeriod: 30)
            
        case .Seconds(let seconds):
            
            return NSDate().dateByAddingTimeInterval(seconds)
        }
    }
    
    /**
     Private method to return a date after days given as params
     
     - parameter days: Number of days to calcularte the new date
     
     - returns: New Date after the given period
     */
    private class func dateAfterAPeriodOfTime(daysPeriod days: Int) -> NSDate {
        
        let today = NSDate()
        
        return NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: days,
            toDate: today,
            options: NSCalendarOptions(rawValue: 0))!
    }
    
    /**
     Method to set the expire time
     
     - parameter expiry: A parameter of type CacheExpiryTime to indicate the live time of a cache object
     */
    
    class func setExpireDate(expiry: CacheExpiryTime) {
        expiryTime = expiry
    }
    
}

extension NSDate {
    
    var startOfDay: NSDate {
        return NSCalendar.currentCalendar().startOfDayForDate(NSDate())
    }
    
    var endOfDay: NSDate? {
        let components = NSDateComponents()
        components.day = 1
        components.second = -1
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions())
    }
}