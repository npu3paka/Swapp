//
//  SwappInfo.swift
//  Swapps
//
//  Created by Altimir Antonov on 3/1/16.
//  Copyright © 2016 Altimir Antonov. All rights reserved.
//

import Foundation

class SwappInfo: NSObject {
    let id: Int
    let url: String
    var canSee: Bool
    
    init(id: Int, url: String, canSee: Bool) {
        self.id = id
        self.url = url
        self.canSee = canSee
        
        print(self.url)
    }
//    
//    required init(response: NSHTTPURLResponse, representation: AnyObject) {
//        self.id = representation.valueForKeyPath("photo.id") as! Int
//        self.url = representation.valueForKeyPath("photo.image_url") as! String
//        
////        self.name = representation.valueForKeyPath("photo.name") as? String
//    }
    
    override func isEqual(object: AnyObject!) -> Bool {
        return (object as! SwappInfo).id == self.id
    }
    
    override var hash: Int {
        return (self as SwappInfo).id
    }
}