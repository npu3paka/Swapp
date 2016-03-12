















//
//  constants.swift
//  Swapps
//
//  Created by Altimir Antonov on 3/1/16.
//  Copyright © 2016 Altimir Antonov. All rights reserved.
//

import Foundation

public struct Notifications {
    static let AddTag = "com.andrewcbancroft.specialNotificationKey"
    static let RecSw = "com.andrewcbancroft.RecSw"
    static let SentSw = "com.andrewcbancroft.SentSw"
}

public struct URLSettings {
    static let BaseURL: String = "http://alti.xn----8sbarabrujldb2bdye.eu/"
}

public struct DashboardRequestImages {
    
    static let getImages: String = URLSettings.BaseURL + ""
    /**
     *  All Keys for Login Request
     */
    public struct Keys {
        static let userId: String = "userID"
        static let fbID: String = "fb_id"
    }
    
    /**
    * All Parameters
    */
}