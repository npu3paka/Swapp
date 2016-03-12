//
//  SpaceKit.swift
//  SpaceKit
//
//  Created by Steliyan Hadzhidenev on 9/30/15.
//  Copyright © 2015 Steliyan Hadzhidenev. All rights reserved.
//

import UIKit

class SKCache: NSCache {
    
    /// read only property in which the queue for the read/write actions will be stored
    let diskQueue = dispatch_queue_create("spacekit.cache", DISPATCH_QUEUE_SERIAL)
    
    /// read only property in which the file manager will be stored
    let fileManager = NSFileManager()
    
    /// read only property which stores the main NSCache key
    static let mainCacheKey: String = NSBundle.mainBundle().bundleIdentifier!
    
    /// property to store the path to the Cache Directory of the device
    var directoryPath: String!
    
    /// class property declared as Singleton to hold only one instance of the NSCache
    class var sharedInstance: SKCache {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SKCache? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SKCache()
            Static.instance?.countLimit = 1024*1024
        }
        return Static.instance!
    }
    
    /**
     Class method to store a CacheObject in the NSCache
     
     - parameter object: A object of type SKCacheObject to be stored in the NSCache
     */
    class func add(objectToCache object: SKCacheObject) {
        
        /// access the dictionary stored in the NSCache
        var cacheDictionary = SKCache.sharedInstance.objectForKey(SKCache.mainCacheKey) as! [String:[AnyObject]]?
        
        /**
        *  Check if the dictionary is empty and if so reinitiolize it
        */
        if cacheDictionary == nil {
            cacheDictionary = [String:[AnyObject]]()
        }
        
        // check if a key exist in the dictionary
        if cacheDictionary!.indexForKey("\(object.type)") != nil {
            
            // if it exists add a new object to the values for that key
            var element = cacheDictionary!["\(object.type)"]
            
            element?.append(object)
            
            cacheDictionary!.updateValue(element!, forKey: "\(object.type)")
            
        } else {
            
            // if it doesn't create new array for the key
            cacheDictionary!.updateValue([object], forKey: "\(object.type)")
        }
        
        // finaly add the dictionary back to the NSCache
        SKCache.sharedInstance.setObject(cacheDictionary!, forKey: SKCache.mainCacheKey)
        
    }
    
    /**
     Class method to return an cached object for a given key as param
     
     - parameter key: A Key for which to search in the NSCache and return a object if one exists else return nil
     
     - returns: Object of any kind or nil
     */
    class func get(key: String) -> AnyObject? {
        
        // declaration of local property to hold finded object for the given key
        var cacheObject: AnyObject? = nil
        
        // access the dictionary stored in the NSCache
        let cachedDictionary = SKCache.sharedInstance.objectForKey(SKCache.mainCacheKey) as? [String:[AnyObject]]
        
        guard let dict = cachedDictionary else {
            return nil
        }
        
        // loop through all values for all keys in the dictionary
        for (_, value) in dict {
            
            // check each object for a match in the its key and the one given as param
            if let index = (value as? [SKCacheObject])?.indexOf({$0.key == key}) {
                // if such one exists extract the object at the found position and stop the check
                cacheObject = value[index]
                break
            }
            
        }
        
        return cacheObject
        
    }
    
    /**
     Class method to load the NSCache with content from the CacheDirectory of the device
     */
    class func loadCache() {
        
        // declaration of a local property to store all files located in the CacheDirectory
        var allFiles: [String] = [String]()
        
        // try to load all the files in the allFiles property
        do {
            allFiles = try SKCache.sharedInstance.fileManager.contentsOfDirectoryAtPath(SKCache.sharedInstance.directoryPath)
        } catch {
            print("God dam it! It died again ...")
        }
        
        // filter all the files from the CacheDirectory to select only the files with extension .cache
        let neededFiles = allFiles.filter( { $0.hasSuffix("cache") })
        
        // loop through all the filtered files
        for file in neededFiles {
            
            // generate the path for each file
            let filePath = (SKCache.sharedInstance.directoryPath as NSString).stringByAppendingPathComponent(file)
            
            // check if a file exists on a given path
            if SKCache.sharedInstance.fileManager.fileExistsAtPath(filePath) {
                
                // try to extract a CacheObject from the file
                let cacheObject = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? SKCacheObject
                
                // check the expiry date of the object
                if cacheObject!.isExpired() {
                    
                    // if the object is expired remove it from the directory and don't insert it in the NSCache
                    do {
                        try SKCache.sharedInstance.fileManager.removeItemAtPath(filePath)
                    } catch {
                        print("Darn! It never works as I expect ;( ")
                    }
                } else {
                    
                    // if the object isn't expired insert it to the NSCache
                    SKCache.add(objectToCache: cacheObject!)
                }
            }
        }
    }
    
    
    /**
     Class method to save the content of the NSCache to the Cache Directory of the device
     */
    class func saveCache() {
        
        /// extract the content for the main cache key from the NSCache
        guard let cacheDictionary = SKCache.sharedInstance.objectForKey(SKCache.mainCacheKey) as? [String:[AnyObject]] else {
            return
        }
        
        /**
        *  Loop throught all the values for all keys and save each one to the disk
        */
        for (_, value) in cacheDictionary {
            
            for object in value as! [SKCacheObject] {
                /**
                *  Do the saving job on a separated thread so the main UI won't be blocked
                */
                dispatch_async(SKCache.sharedInstance.diskQueue) { () -> Void in
                    
                    // generate unique path for each element in the cache
                    guard let key = object.key else {
                        return
                    }
                    
                    let path = SKCache.sharedInstance.pathForObject(object, forKey: key)
                    NSKeyedArchiver.archiveRootObject(object, toFile: path)
                }
            }
        }
        
        // TODO: - add to official library
        SKCache.sharedInstance.removeAllObjects()
    }
    
    /**
     Overriding the default init() method to set some properties to the NSCache
     
     */
    override init() {
        
        // call the init() method from the super class
        super.init()
        
        // initialize an empty dictionary for the main cache key
        self.setObject([String:[AnyObject]](), forKey: SKCache.mainCacheKey)
        
        // get the path to the cache directory of the device where the cache objects will be stored
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! as String
        
        // syntesize the directory path for the NSCache
        directoryPath = cacheDirectory.stringByAppendingFormat("/spacekit.cache/%@", "bemoircache")
        
        // check if such directory exists
        if !fileManager.fileExistsAtPath(directoryPath) {
            do {
                // if not try to create a new file in the directory
                try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Crap I just messed up again badly ;( ")
            }
        }
    }
    
    /**
     Private method to create an unique file name for each cache object
     
     - parameter object: An object of type SKCacheObject
     - parameter key:    A unique key for which a file name will be generated
     
     - returns: The generated file name as String
     */
    
    private func pathForObject(object: SKCacheObject, forKey key: String) -> String {
        let newKey = key.stringByReplacingOccurrencesOfString(":", withString: "-").stringByReplacingOccurrencesOfString("/", withString: "-")
        return ((SKCache.sharedInstance.directoryPath as NSString).stringByAppendingPathComponent("\(object.type)" + ".\(newKey)") as NSString).stringByAppendingPathExtension("cache")!
    }
    
    
}