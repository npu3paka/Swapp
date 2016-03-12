//
//  ImageDownloader.swift
//  Bemoir
//
//  Created by Dimitar Kostov on 7/27/15.
//  Copyright (c) 2015 158ltd.com. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import AVKit

class ImageDownloader: NSObject {
    
    private static func downloadImage(withRequestOperation requestOperation: AFHTTPRequestOperation, forImageURL imageURL: String, shouldResize: Bool? = false, completion: (UIImage?) -> ()) {
        
        requestOperation.responseSerializer = AFImageResponseSerializer()
        requestOperation.responseSerializer.acceptableContentTypes = Set(["image/png", "image/jpg", "image/jpeg", "image/bmp", "image/gif"])
        requestOperation.setCompletionBlockWithSuccess({ (operation: AFHTTPRequestOperation, responseObject: AnyObject) -> Void in
            
            if let image = responseObject as? UIImage {
                SKCache.add(objectToCache: SKCacheObject(value: image, type: UIImage.self, key: imageURL))
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(image)
                }
            }
            
            }, failure: { (operation: AFHTTPRequestOperation, error: NSError) -> Void in
                
                if imageURL == "default.png" {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(UIImage(named: "Default"))
                    }
                }
        })
        
        requestOperation.start()
    }
    
    // MARK: - Public API
    
    // IMAGES
    
    /**
    This method will download image asynchronously for given ULR
    
    - parameter indexPath:  indexPath for the cell
    - parameter imageURL:   URL of the image
    - parameter completion: completion block to return the image
    */
    internal func getImage(imageURL imageURL: String?, shouldResize: Bool? = false, forIndexPath indexPath: NSIndexPath, completion: (UIImage?) -> ()) {
        
        // Check url for nil
        guard let url = imageURL else {
            return
        }
        
        let imageNSURL = NSURL(string: url)
        
        // Check in cache for image for this url else start downloading the image
        if let object = SKCache.get(url) {
            
            // Image size from cache is scaled to match the screen scale. That is why we need to adjust the scale factor of the new image
            // to the scale of the device screen. Source - http://stackoverflow.com/questions/29427998/xcode-nsdata-image-size-change ,
            // http://stackoverflow.com/questions/24656704/wrong-control-file-size-uiimage-when-it-is-obtained-from-nsdata
            // UIImage(CGImage: image!.CGImage!, scale: UIScreen.mainScreen().scale, orientation: image!.imageOrientation)
//            let screenScale = UIScreen.mainScreen().scale
            
            let image = UIImage(data: (object as! SKCacheObject).value as! NSData)
//            let cachedImage = UIImage(CGImage: image!.CGImage!, scale: screenScale, orientation: image!.imageOrientation)
            
//            image = nil
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(image)
            }
            
        } else {
            
            let requestOperation = AFHTTPRequestOperation(request: NSURLRequest(URL: imageNSURL!))
            
            ImageDownloader.downloadImage(withRequestOperation: requestOperation, forImageURL: url, shouldResize: shouldResize,completion: completion)
            
            tasks.append((indexPath, (url, requestOperation)))
        }
    }
    
    /**
     Cancels the image downloading for the given indexPath
     
     - parameter indexPath: IndexPath of the cell
     */
    internal func cancelImageDownloading(forIndexPath indexPath: NSIndexPath) {
        
        for (index, task) in tasks.enumerate() {
            
            if task.indexPath == indexPath {
                
                task.operationParams.operation.cancel()
                tasks.removeAtIndex(index)
                
                break
            }
        }
    }
    
    // VIDEOS
    
    /**
    This method will get thumbnail from given URL
    
    - parameter thumbNailURL: URL of the thumbnail
    - parameter indexPath:    indexPath of the cell
    - parameter completion:   completion block to return the image
    */
    internal func getVideoThumbnail(thumbNailURL: String?, indexPath: NSIndexPath, completion: (UIImage?) -> ()) {
        
        // Check string for nil
        guard let url = thumbNailURL else {
            return
        }
        
        // if the thumbnail was downloaded already take it from the cache
        if let object = SKCache.get(url) {
            
            let resizedImage = UIImage(data: (object as! SKCacheObject).value as! NSData)!
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(resizedImage)
            }
            
        } else {
            
            // create block operation to hold the blocks for generating the video thumbnail
            let block: NSBlockOperation = NSBlockOperation()
            
            // Add the execution block the block operations for adding to queue
            block.addExecutionBlock() {
                
                let videoNSURL = NSURL(string: url)
                let videoAsset = AVURLAsset(URL: videoNSURL!)
                let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
                // this line of code will make the generated images always be in portrain
                imageGenerator.appliesPreferredTrackTransform = true
                let time = CMTime(value: 1, timescale: 600)
                
                imageGenerator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime: time)], completionHandler: { (neededTime: CMTime, imageRef: CGImage?, time: CMTime, result: AVAssetImageGeneratorResult, error: NSError?) -> Void in
                    
                    if imageRef != nil {
                        
                        let image = UIImage(CGImage: imageRef!)
                        
                        SKCache.add(objectToCache: SKCacheObject(value: image, type: UIImage.self, key: url))
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(image)
                        }
                    }
                })
            }
            
            // add the execution block to the queue
            operationQueue.addOperation(block)
            
            // create tuple of the block and the indexPath and append it to the array of operation blocks
            operationBlocks.append((block: block, indexPath: indexPath))
        }
    }
    
    /**
     Cancel video thumbnail generating task for give indexPath
     
     - parameter indexPath: indexPath of the cell
     */
    internal func cancelVideoThumbnailDownloading(forIndexPath indexPath: NSIndexPath) {
        
        for (index, operation) in operationBlocks.enumerate() {
            if operation.indexPath == indexPath {
                operation.block.cancel()
                if operationBlocks.count > index {
                    operationBlocks.removeAtIndex(index)
                }
            }
        }
    }
    
    // MARK: - Private API
    
    /// and array of all image downloading tasks
    private var tasks = [(indexPath: NSIndexPath, operationParams: (url: String, operation: AFHTTPRequestOperation))]()
    
    /// This Queue will hold blocks of code that generate Video thumbnails
    private lazy var operationQueue: NSOperationQueue = {
        
        let _operationQueue = NSOperationQueue()
        _operationQueue.maxConcurrentOperationCount = 1
        
        return _operationQueue
    }()
    
    /// Blocks of code to generate Video thumbnail
    private var operationBlocks = [(block: NSBlockOperation, indexPath: NSIndexPath)]()
}

extension String {
    
    /**
     Method to return image from cache or from server if it isn't found in the cache
     
     - parameter completion: Completion handler executed when the fetch of the image is finished
     */
    func getImage(completion: (UIImage?) -> ()) {
        
        let imageNSURL = NSURL(string: self)
        
        if let object = SKCache.get(self) {
            
            let screenScale = UIScreen.mainScreen().scale
            
            var image = UIImage(data: (object as! SKCacheObject).value as! NSData)
            let cachedImage = UIImage(CGImage: image!.CGImage!, scale: screenScale, orientation: image!.imageOrientation)
            image = nil
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(cachedImage)
            }
            
        } else {
            
            let requestOperation = AFHTTPRequestOperation(request: NSURLRequest(URL: imageNSURL!))
            
            ImageDownloader.downloadImage(withRequestOperation: requestOperation, forImageURL: self, completion: completion)
        }
    }
}
